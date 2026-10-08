/**
 * FitKarma Edge Function Type Definitions
 * Governing Docs: Brain/api_contract.md, Brain/error_handling.md, Brain/security.md
 */

export type AppErrorCode =
  | 'FK-1001' // Auth: authentication required/expired
  | 'FK-1002' // AuthZ: access denied
  | 'FK-2001' // Validation: invalid user input
  | 'FK-3001' // Offline: queued locally
  | 'FK-3002' // Sync: transient sync failure
  | 'FK-3003' // Conflict: reconciliation required
  | 'FK-4001' // AI: provider/unparseable AI result
  | 'FK-4002' // AI: low-confidence result needs confirmation
  | 'FK-5001' // Payment: provider request failed
  | 'FK-5002' // Payment: verification failed
  | 'FK-5003' // Payment: mandate/payment failed
  | 'FK-5004' // Payment: webhook duplicate/already processed
  | 'FK-6001' // External: third-party dependency unavailable
  | 'FK-7001' // Privacy: deletion/export operation failed
  | 'FK-9999'; // System: unexpected error

export interface RequestEnvelope<T = Record<string, unknown>> {
  request_id: string;
  idempotency_key?: string;
  payload: T;
}

export interface ErrorEnvelope {
  code: AppErrorCode;
  message: string;
  retryable: boolean;
  request_id: string;
}

export interface ResponseEnvelope<T = unknown> {
  request_id: string;
  data: T | null;
  warnings: string[];
  error: ErrorEnvelope | null;
}

export type RateLimitBucket =
  | 'auth'
  | 'ai'
  | 'whatsapp'
  | 'data_export'
  | 'sync'
  | 'payment';

export interface RateLimitResult {
  allowed: boolean;
  remaining: number;
  resetAt: number; // Unix timestamp ms
}

export interface JwtClaims {
  sub: string;
  role: string;
  email?: string;
  exp: number;
  iat?: number;
  aud?: string;
  [key: string]: unknown;
}
