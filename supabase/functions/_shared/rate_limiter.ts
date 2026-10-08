/**
 * FitKarma Rate-Limit Bucket Interface
 * Governing Docs: Brain/security.md Section 11, Brain/api_contract.md Section 9
 *
 * NOTE: Exact threshold values remain OPEN DECISION in Brain/security.md and Brain/api_contract.md.
 * This interface establishes the rate-limiting contract and token bucket abstraction.
 */

import type { RateLimitBucket, RateLimitResult } from './types.ts';

export interface BucketConfig {
  capacity: number;      // Maximum burst requests allowed
  refillRatePerSec: number; // Tokens added per second
}

/**
 * Baseline default configurations for rate limit buckets.
 * Explicitly marked as OPEN DECISION baselines subject to production telemetry tuning.
 */
export const DEFAULT_BUCKET_CONFIGS: Record<RateLimitBucket, BucketConfig> = {
  auth: { capacity: 10, refillRatePerSec: 0.2 },         // ~12 requests / minute (OPEN DECISION)
  ai: { capacity: 5, refillRatePerSec: 0.1 },            // ~6 requests / minute (OPEN DECISION)
  whatsapp: { capacity: 20, refillRatePerSec: 1.0 },     // ~60 requests / minute (OPEN DECISION)
  data_export: { capacity: 2, refillRatePerSec: 0.01 },  // ~1 request / 100 seconds (OPEN DECISION)
  sync: { capacity: 30, refillRatePerSec: 0.5 },         // ~30 requests / minute (OPEN DECISION)
  payment: { capacity: 10, refillRatePerSec: 0.2 },      // ~12 requests / minute (OPEN DECISION)
};

export interface RateLimiter {
  checkLimit(key: string, bucket: RateLimitBucket): Promise<RateLimitResult>;
}

interface BucketState {
  tokens: number;
  lastRefillTime: number;
}

/**
 * In-memory Token Bucket rate limiter for local Edge Function execution and tests.
 */
export class InMemoryRateLimiter implements RateLimiter {
  private states = new Map<string, BucketState>();
  private configs: Record<RateLimitBucket, BucketConfig>;

  constructor(customConfigs?: Partial<Record<RateLimitBucket, BucketConfig>>) {
    this.configs = {
      ...DEFAULT_BUCKET_CONFIGS,
      ...(customConfigs || {}),
    };
  }

  async checkLimit(key: string, bucket: RateLimitBucket): Promise<RateLimitResult> {
    const config = this.configs[bucket] || DEFAULT_BUCKET_CONFIGS[bucket];
    const compositeKey = `${bucket}:${key}`;
    const now = Date.now();

    let state = this.states.get(compositeKey);
    if (!state) {
      state = {
        tokens: config.capacity,
        lastRefillTime: now,
      };
      this.states.set(compositeKey, state);
    }

    // Calculate token refill since last check
    const elapsedSeconds = (now - state.lastRefillTime) / 1000;
    const tokensToAdd = elapsedSeconds * config.refillRatePerSec;
    state.tokens = Math.min(config.capacity, state.tokens + tokensToAdd);
    state.lastRefillTime = now;

    // Check availability
    if (state.tokens >= 1.0) {
      state.tokens -= 1.0;
      const remaining = Math.floor(state.tokens);
      const resetAt = now + Math.ceil((1.0 / config.refillRatePerSec) * 1000);
      return {
        allowed: true,
        remaining,
        resetAt,
      };
    } else {
      const waitSeconds = (1.0 - state.tokens) / config.refillRatePerSec;
      const resetAt = now + Math.ceil(waitSeconds * 1000);
      return {
        allowed: false,
        remaining: 0,
        resetAt,
      };
    }
  }

  reset(): void {
    this.states.clear();
  }
}

export const defaultRateLimiter = new InMemoryRateLimiter();
