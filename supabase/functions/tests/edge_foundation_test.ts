/**
 * FitKarma Edge Function Foundation Unit Tests
 * Governing Docs: Brain/api_contract.md, Brain/error_handling.md, Brain/security.md
 */

import test from 'node:test';
import assert from 'node:assert/strict';

import {
  parseRequestEnvelope,
  createSuccessResponse,
  createErrorResponse,
  mapErrorCodeToHttpStatus,
  EnvelopeParseError,
} from '../_shared/envelopes.ts';
import { verifyAuthToken } from '../_shared/auth_helper.ts';
import {
  InMemoryIdempotencyStore,
  withIdempotency,
} from '../_shared/idempotency.ts';
import { verifyWebhookSignature } from '../_shared/webhook_verifier.ts';
import { InMemoryRateLimiter } from '../_shared/rate_limiter.ts';
import { getServiceCredentials } from '../_shared/credentials.ts';
import { handleHealthCheck } from '../health-check/index.ts';

// ------------------------------------------------------------------------------
// 1. Request Envelope Tests
// ------------------------------------------------------------------------------
test('Request Envelope: parses valid POST request with complete envelope', async () => {
  const req = new Request('https://edge.fitkarma.test/v1/test', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      request_id: 'client_req_001',
      idempotency_key: 'idem_key_abc',
      payload: { food_name: 'Khichdi', calories: 250 },
    }),
  });

  const parsed = await parseRequestEnvelope<{ food_name: string; calories: number }>(req);
  assert.equal(parsed.request_id, 'client_req_001');
  assert.equal(parsed.idempotency_key, 'idem_key_abc');
  assert.equal(parsed.payload.food_name, 'Khichdi');
  assert.equal(parsed.payload.calories, 250);
});

test('Request Envelope: generates fallback request_id when omitted', async () => {
  const req = new Request('https://edge.fitkarma.test/v1/test', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ item: 'Apple' }),
  });

  const parsed = await parseRequestEnvelope(req);
  assert.ok(parsed.request_id);
  assert.ok(parsed.request_id.length > 5);
});

test('Request Envelope: extracts request_id and idempotency_key from headers', async () => {
  const req = new Request('https://edge.fitkarma.test/v1/test', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-Request-Id': 'header_req_999',
      'Idempotency-Key': 'header_idem_888',
    },
    body: JSON.stringify({ action: 'sync' }),
  });

  const parsed = await parseRequestEnvelope(req);
  assert.equal(parsed.request_id, 'header_req_999');
  assert.equal(parsed.idempotency_key, 'header_idem_888');
});

test('Request Envelope: throws FK-2001 on invalid JSON body', async () => {
  const req = new Request('https://edge.fitkarma.test/v1/test', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: 'this-is-not-valid-json{',
  });

  await assert.rejects(
    async () => parseRequestEnvelope(req),
    (err: unknown) => {
      assert.ok(err instanceof EnvelopeParseError);
      assert.equal(err.code, 'FK-2001');
      return true;
    }
  );
});

// ------------------------------------------------------------------------------
// 2. Response and Error Envelope Tests
// ------------------------------------------------------------------------------
test('Response Envelope: formats standard success response with HTTP 200', async () => {
  const res = createSuccessResponse({
    data: { plan: 'karma_pro' },
    requestId: 'req_123',
    warnings: ['Promo applied'],
  });

  assert.equal(res.status, 200);
  const json = await res.json();
  assert.equal(json.request_id, 'req_123');
  assert.deepEqual(json.data, { plan: 'karma_pro' });
  assert.deepEqual(json.warnings, ['Promo applied']);
  assert.equal(json.error, null);
});

test('Response Envelope: formats error response using FK-xxxx taxonomy', async () => {
  const res = createErrorResponse({
    code: 'FK-1001',
    message: 'Authentication session expired',
    requestId: 'req_err_01',
    retryable: false,
  });

  assert.equal(res.status, 401);
  const json = await res.json();
  assert.equal(json.request_id, 'req_err_01');
  assert.equal(json.data, null);
  assert.deepEqual(json.error, {
    code: 'FK-1001',
    message: 'Authentication session expired',
    retryable: false,
    request_id: 'req_err_01',
  });
});

test('Error Mapping: correctly maps FK codes to HTTP statuses', () => {
  assert.equal(mapErrorCodeToHttpStatus('FK-1001'), 401);
  assert.equal(mapErrorCodeToHttpStatus('FK-1002'), 403);
  assert.equal(mapErrorCodeToHttpStatus('FK-2001'), 400);
  assert.equal(mapErrorCodeToHttpStatus('FK-3003'), 409);
  assert.equal(mapErrorCodeToHttpStatus('FK-5002'), 401);
  assert.equal(mapErrorCodeToHttpStatus('FK-9999'), 500);
});

// ------------------------------------------------------------------------------
// 3. JWT & Authentication Verification Tests
// ------------------------------------------------------------------------------
function createMockJwt(claims: Record<string, unknown>): string {
  const header = Buffer.from(JSON.stringify({ alg: 'none', typ: 'JWT' })).toString('base64url');
  const payload = Buffer.from(JSON.stringify(claims)).toString('base64url');
  return `${header}.${payload}.mock_sig`;
}

test('Auth Helper: verifies valid Bearer token and extracts user_id', async () => {
  const validToken = createMockJwt({
    sub: '00000000-0000-0000-0000-000000000001',
    role: 'authenticated',
    email: 'test@fitkarma.internal',
    exp: Math.floor(Date.now() / 1000) + 3600,
  });

  const req = new Request('https://edge.fitkarma.test/v1/profile', {
    headers: { Authorization: `Bearer ${validToken}` },
  });

  const authCtx = await verifyAuthToken(req);
  assert.equal(authCtx.userId, '00000000-0000-0000-0000-000000000001');
  assert.equal(authCtx.role, 'authenticated');
  assert.equal(authCtx.email, 'test@fitkarma.internal');
});

test('Auth Helper: rejects request missing Authorization header with FK-1001', async () => {
  const req = new Request('https://edge.fitkarma.test/v1/profile');

  await assert.rejects(
    async () => verifyAuthToken(req),
    (err: unknown) => {
      assert.ok(err instanceof EnvelopeParseError);
      assert.equal(err.code, 'FK-1001');
      return true;
    }
  );
});

test('Auth Helper: rejects expired JWT with FK-1001', async () => {
  const expiredToken = createMockJwt({
    sub: 'user_123',
    role: 'authenticated',
    exp: Math.floor(Date.now() / 1000) - 100, // expired in past
  });

  const req = new Request('https://edge.fitkarma.test/v1/profile', {
    headers: { Authorization: `Bearer ${expiredToken}` },
  });

  await assert.rejects(
    async () => verifyAuthToken(req),
    (err: unknown) => {
      assert.ok(err instanceof EnvelopeParseError);
      assert.equal(err.code, 'FK-1001');
      assert.match(err.message, /expired/i);
      return true;
    }
  );
});

// ------------------------------------------------------------------------------
// 4. Idempotency Helper Tests
// ------------------------------------------------------------------------------
test('Idempotency Helper: executes once and caches subsequent replayed requests', async () => {
  const store = new InMemoryIdempotencyStore();
  let executionCount = 0;

  const testHandler = async () => {
    executionCount++;
    return {
      request_id: 'req_1',
      data: { order_id: 'ord_999', executionCount },
      warnings: [],
      error: null,
    };
  };

  // First call
  const first = await withIdempotency({
    key: 'order_key_001',
    requestId: 'req_1',
    store,
    handler: testHandler,
  });

  assert.equal(first.isReplay, false);
  assert.equal(executionCount, 1);
  assert.equal(first.response.data?.executionCount, 1);

  // Second call with same key (Replay)
  const second = await withIdempotency({
    key: 'order_key_001',
    requestId: 'req_2',
    store,
    handler: testHandler,
  });

  assert.equal(second.isReplay, true);
  assert.equal(executionCount, 1); // Handler was NOT executed again!
  assert.equal(second.response.data?.executionCount, 1);
  assert.ok(second.response.warnings.some(w => w.includes('Idempotent replay')));
});

// ------------------------------------------------------------------------------
// 5. Signed-Webhook Verification Tests
// ------------------------------------------------------------------------------
test('Webhook Verifier: validates genuine HMAC-SHA256 signature', async () => {
  const secret = 'super_secret_webhook_key_123';
  const payload = JSON.stringify({ event: 'payment.captured', order_id: 'ord_555' });

  // Compute expected signature
  const cryptoKey = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  );
  const sigBuffer = await crypto.subtle.sign('HMAC', cryptoKey, new TextEncoder().encode(payload));
  const hexSignature = Array.from(new Uint8Array(sigBuffer))
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');

  // Verification succeeds
  const isValid = await verifyWebhookSignature({
    rawPayload: payload,
    signature: hexSignature,
    secret,
  });
  assert.equal(isValid, true);
});

test('Webhook Verifier: rejects tampered webhook payload with FK-5002', async () => {
  const secret = 'secret_abc';
  const payload = 'original_payload';
  const tamperedPayload = 'tampered_payload';

  const cryptoKey = await crypto.subtle.importKey(
    'raw',
    new TextEncoder().encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['sign']
  );
  const sigBuffer = await crypto.subtle.sign('HMAC', cryptoKey, new TextEncoder().encode(payload));
  const hexSignature = Array.from(new Uint8Array(sigBuffer))
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');

  await assert.rejects(
    async () =>
      verifyWebhookSignature({
        rawPayload: tamperedPayload,
        signature: hexSignature,
        secret,
      }),
    (err: unknown) => {
      assert.ok(err instanceof EnvelopeParseError);
      assert.equal(err.code, 'FK-5002');
      return true;
    }
  );
});

// ------------------------------------------------------------------------------
// 6. Rate Limiter Tests
// ------------------------------------------------------------------------------
test('Rate Limiter: enforces burst capacity and blocks over-limit requests', async () => {
  const limiter = new InMemoryRateLimiter({
    ai: { capacity: 2, refillRatePerSec: 0.1 },
  });

  // Request 1: Allowed
  const r1 = await limiter.checkLimit('user_test', 'ai');
  assert.equal(r1.allowed, true);

  // Request 2: Allowed
  const r2 = await limiter.checkLimit('user_test', 'ai');
  assert.equal(r2.allowed, true);

  // Request 3: Blocked (capacity 2 exhausted)
  const r3 = await limiter.checkLimit('user_test', 'ai');
  assert.equal(r3.allowed, false);
  assert.equal(r3.remaining, 0);
  assert.ok(r3.resetAt > Date.now());
});

// ------------------------------------------------------------------------------
// 7. Least-Privilege Credential Tests
// ------------------------------------------------------------------------------
test('Credentials: returns anon credentials by default without service key', () => {
  const creds = getServiceCredentials('anon');
  assert.ok(creds.supabaseUrl);
  assert.ok(creds.supabaseAnonKey);
  assert.equal(creds.supabaseServiceRoleKey, undefined);
});

// ------------------------------------------------------------------------------
// 8. Health-Check Edge Function Tests
// ------------------------------------------------------------------------------
test('Health Check: GET request returns 200 with standard response envelope', async () => {
  const req = new Request('https://edge.fitkarma.test/health-check', { method: 'GET' });
  const res = await handleHealthCheck(req);

  assert.equal(res.status, 200);
  const json = await res.json();
  assert.equal(json.data.status, 'healthy');
  assert.equal(json.data.service, 'fitkarma-edge');
  assert.equal(json.data.version, '1.0.0');
  assert.equal(json.error, null);
});

test('Health Check: OPTIONS request returns 204 with CORS headers', async () => {
  const req = new Request('https://edge.fitkarma.test/health-check', { method: 'OPTIONS' });
  const res = await handleHealthCheck(req);

  assert.equal(res.status, 204);
  assert.ok(res.headers.get('Access-Control-Allow-Origin'));
});

test('Health Check: POST request echoes request_id', async () => {
  const req = new Request('https://edge.fitkarma.test/health-check', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ request_id: 'health_req_special' }),
  });
  const res = await handleHealthCheck(req);

  assert.equal(res.status, 200);
  const json = await res.json();
  assert.equal(json.request_id, 'health_req_special');
  assert.equal(json.data.status, 'healthy');
});
