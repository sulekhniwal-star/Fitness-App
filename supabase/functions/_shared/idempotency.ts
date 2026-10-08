/**
 * FitKarma Idempotency Storage and Replay Helper
 * Governing Docs: Brain/api_contract.md, Brain/error_handling.md
 */

import type { ResponseEnvelope } from './types.ts';
import { EnvelopeParseError } from './envelopes.ts';

export interface IdempotencyRecord<T = unknown> {
  key: string;
  requestId: string;
  status: 'processing' | 'completed' | 'failed';
  response?: ResponseEnvelope<T>;
  createdAt: number;
  expiresAt: number;
}

export interface IdempotencyStore {
  get(key: string): Promise<IdempotencyRecord | null>;
  set(key: string, record: IdempotencyRecord): Promise<void>;
}

/**
 * In-memory implementation of IdempotencyStore for local dev and unit tests.
 */
export class InMemoryIdempotencyStore implements IdempotencyStore {
  private records = new Map<string, IdempotencyRecord>();

  async get(key: string): Promise<IdempotencyRecord | null> {
    const record = this.records.get(key);
    if (!record) return null;

    if (Date.now() > record.expiresAt) {
      this.records.delete(key);
      return null;
    }
    return record;
  }

  async set(key: string, record: IdempotencyRecord): Promise<void> {
    this.records.set(key, record);
  }

  clear(): void {
    this.records.clear();
  }
}

// Global default store instance
export const defaultIdempotencyStore = new InMemoryIdempotencyStore();

/**
 * Executes a mutating operation with strict idempotency protection.
 * If the key has already been completed, returns the cached response without re-executing.
 */
export async function withIdempotency<T>(params: {
  key?: string;
  requestId: string;
  store?: IdempotencyStore;
  ttlMs?: number; // Defaults to 24 hours (86,400,000 ms)
  handler: () => Promise<ResponseEnvelope<T>>;
}): Promise<{ response: ResponseEnvelope<T>; isReplay: boolean }> {
  const { key, requestId, handler } = params;

  // If no idempotency key was supplied, execute handler directly without caching
  if (!key || key.trim().length === 0) {
    const res = await handler();
    return { response: res, isReplay: false };
  }

  const store = params.store || defaultIdempotencyStore;
  const ttl = params.ttlMs || 86400000; // 24 hours default retention
  const now = Date.now();

  const existing = await store.get(key);

  if (existing) {
    if (existing.status === 'processing') {
      throw new EnvelopeParseError(
        'FK-3003',
        'Conflict: An operation with this idempotency key is currently in flight',
        requestId
      );
    }

    if (existing.status === 'completed' && existing.response) {
      // Replay cached response
      const replayedResponse: ResponseEnvelope<T> = {
        ...(existing.response as ResponseEnvelope<T>),
        warnings: [
          ...(existing.response.warnings || []),
          `Idempotent replay: operation originally executed at ${new Date(existing.createdAt).toISOString()}`,
        ],
      };
      return { response: replayedResponse, isReplay: true };
    }
  }

  // Mark status as processing
  await store.set(key, {
    key,
    requestId,
    status: 'processing',
    createdAt: now,
    expiresAt: now + ttl,
  });

  try {
    const result = await handler();

    // Cache completed result
    await store.set(key, {
      key,
      requestId,
      status: 'completed',
      response: result,
      createdAt: now,
      expiresAt: now + ttl,
    });

    return { response: result, isReplay: false };
  } catch (error) {
    // Mark failed or clear on error
    await store.set(key, {
      key,
      requestId,
      status: 'failed',
      createdAt: now,
      expiresAt: now + ttl,
    });
    throw error;
  }
}
