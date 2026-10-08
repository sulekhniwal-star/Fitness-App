/**
 * FitKarma Request and Response Envelope Utilities
 * Governing Docs: Brain/api_contract.md, Brain/error_handling.md
 */

import type { AppErrorCode, ErrorEnvelope, RequestEnvelope, ResponseEnvelope } from './types.ts';

export const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-request-id, idempotency-key, x-idempotency-key',
  'Access-Control-Allow-Methods': 'GET, POST, PUT, PATCH, DELETE, OPTIONS',
};

/**
 * Parses and validates an incoming HTTP Request against the FitKarma RequestEnvelope contract.
 * Automatically provisions a UUID request_id if not present in the body or headers.
 */
export async function parseRequestEnvelope<T = Record<string, unknown>>(
  req: Request
): Promise<RequestEnvelope<T>> {
  const headerRequestId = req.headers.get('x-request-id') || req.headers.get('request-id');
  const headerIdempotencyKey = req.headers.get('idempotency-key') || req.headers.get('x-idempotency-key');

  const generatedRequestId = globalThis.crypto?.randomUUID
    ? globalThis.crypto.randomUUID()
    : `req_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`;

  // For GET or requests without bodies
  if (req.method === 'GET' || req.method === 'HEAD') {
    return {
      request_id: headerRequestId || generatedRequestId,
      idempotency_key: headerIdempotencyKey || undefined,
      payload: {} as T,
    };
  }

  const rawText = await req.text();
  if (!rawText || rawText.trim().length === 0) {
    return {
      request_id: headerRequestId || generatedRequestId,
      idempotency_key: headerIdempotencyKey || undefined,
      payload: {} as T,
    };
  }

  let bodyJson: Record<string, unknown>;
  try {
    bodyJson = JSON.parse(rawText);
  } catch (_e) {
    throw new EnvelopeParseError(
      'FK-2001',
      'Malformed JSON payload in request body',
      headerRequestId || generatedRequestId
    );
  }

  // Extract fields following contract: { request_id, idempotency_key, payload }
  const requestId = (typeof bodyJson.request_id === 'string' && bodyJson.request_id.length > 0)
    ? bodyJson.request_id
    : (headerRequestId || generatedRequestId);

  const idempotencyKey = (typeof bodyJson.idempotency_key === 'string' && bodyJson.idempotency_key.length > 0)
    ? bodyJson.idempotency_key
    : (headerIdempotencyKey || undefined);

  // If payload is explicitly nested under 'payload', extract it; otherwise treat body as payload
  const payload = (bodyJson.payload !== undefined)
    ? (bodyJson.payload as T)
    : (bodyJson as unknown as T);

  return {
    request_id: requestId,
    idempotency_key: idempotencyKey,
    payload,
  };
}

/**
 * Creates a standard JSON Response conforming to the ResponseEnvelope contract.
 */
export function createSuccessResponse<T>(params: {
  data: T;
  requestId: string;
  warnings?: string[];
  status?: number;
  headers?: Record<string, string>;
}): Response {
  const envelope: ResponseEnvelope<T> = {
    request_id: params.requestId,
    data: params.data,
    warnings: params.warnings || [],
    error: null,
  };

  return new Response(JSON.stringify(envelope), {
    status: params.status || 200,
    headers: {
      'Content-Type': 'application/json',
      ...CORS_HEADERS,
      ...(params.headers || {}),
    },
  });
}

/**
 * Creates a standard JSON Response conforming to the ErrorEnvelope contract.
 */
export function createErrorResponse(params: {
  code: AppErrorCode;
  message: string;
  requestId: string;
  retryable?: boolean;
  status?: number;
  headers?: Record<string, string>;
}): Response {
  const errorObj: ErrorEnvelope = {
    code: params.code,
    message: params.message,
    retryable: params.retryable ?? false,
    request_id: params.requestId,
  };

  const envelope: ResponseEnvelope<null> = {
    request_id: params.requestId,
    data: null,
    warnings: [],
    error: errorObj,
  };

  return new Response(JSON.stringify(envelope), {
    status: params.status || mapErrorCodeToHttpStatus(params.code),
    headers: {
      'Content-Type': 'application/json',
      ...CORS_HEADERS,
      ...(params.headers || {}),
    },
  });
}

/**
 * Custom error class wrapping envelope parse errors with FK-xxxx code.
 */
export class EnvelopeParseError extends Error {
  code: AppErrorCode;
  requestId: string;
  constructor(code: AppErrorCode, message: string, requestId: string) {
    super(message);
    this.name = 'EnvelopeParseError';
    this.code = code;
    this.requestId = requestId;
  }
}

/**
 * Maps standard FitKarma error taxonomy codes to appropriate HTTP status codes.
 */
export function mapErrorCodeToHttpStatus(code: AppErrorCode): number {
  switch (code) {
    case 'FK-1001':
      return 401; // Unauthorized
    case 'FK-1002':
      return 403; // Forbidden
    case 'FK-2001':
      return 400; // Bad Request
    case 'FK-3001':
      return 202; // Accepted (Queued)
    case 'FK-3002':
      return 503; // Service Unavailable (Transient)
    case 'FK-3003':
      return 409; // Conflict
    case 'FK-4001':
    case 'FK-4002':
      return 422; // Unprocessable Entity
    case 'FK-5001':
    case 'FK-5003':
      return 502; // Bad Gateway
    case 'FK-5002':
      return 401; // Payment verification failed
    case 'FK-5004':
      return 200; // Webhook duplicate acknowledged
    case 'FK-6001':
      return 503; // Third party unavailable
    case 'FK-7001':
      return 500; // Privacy operation failed
    case 'FK-9999':
    default:
      return 500; // Internal Server Error
  }
}
