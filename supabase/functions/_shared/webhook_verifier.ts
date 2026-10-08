/**
 * FitKarma Provider-Agnostic Signed Webhook Verification Helper
 * Governing Docs: Brain/security.md, Brain/api_contract.md, Brain/error_handling.md
 */

import { EnvelopeParseError } from './envelopes.ts';

export interface WebhookVerificationParams {
  rawPayload: string;
  signature: string;
  secret: string;
  algorithm?: 'SHA-256' | 'SHA-1' | 'SHA-512';
  expectedPrefix?: string; // e.g., 'sha256=' for Meta/WhatsApp or GitHub
  format?: 'hex' | 'base64'; // Default 'hex' (used by Razorpay, Meta, etc.)
  requestId?: string;
}

/**
 * Verifies an incoming signed webhook using constant-time HMAC comparison.
 * Provider-agnostic: supports Razorpay (hex), WhatsApp/Meta (sha256=hex), and generic providers.
 */
export async function verifyWebhookSignature(
  params: WebhookVerificationParams
): Promise<boolean> {
  const {
    rawPayload,
    signature,
    secret,
    algorithm = 'SHA-256',
    expectedPrefix,
    format = 'hex',
    requestId = 'webhook_req',
  } = params;

  if (!signature || signature.trim().length === 0) {
    throw new EnvelopeParseError(
      'FK-5002',
      'Webhook verification failed: Missing signature header',
      requestId
    );
  }

  if (!secret || secret.trim().length === 0) {
    throw new EnvelopeParseError(
      'FK-5002',
      'Webhook verification failed: Server secret not configured',
      requestId
    );
  }

  // Strip prefix if expected (e.g. 'sha256=...')
  let normalizedSignature = signature.trim();
  if (expectedPrefix && normalizedSignature.startsWith(expectedPrefix)) {
    normalizedSignature = normalizedSignature.substring(expectedPrefix.length);
  }

  // Compute expected HMAC
  const encoder = new TextEncoder();
  const key = await crypto.subtle.importKey(
    'raw',
    encoder.encode(secret),
    { name: 'HMAC', hash: algorithm },
    false,
    ['sign']
  );

  const signatureBuffer = await crypto.subtle.sign(
    'HMAC',
    key,
    encoder.encode(rawPayload)
  );

  const computedSig = (format === 'hex')
    ? bufferToHex(signatureBuffer)
    : bufferToBase64(signatureBuffer);

  const isValid = timingSafeEqualString(computedSig.toLowerCase(), normalizedSignature.toLowerCase());

  if (!isValid) {
    throw new EnvelopeParseError(
      'FK-5002',
      'Webhook verification failed: Invalid cryptographic signature',
      requestId
    );
  }

  return true;
}

/**
 * Converts ArrayBuffer to hex string.
 */
function bufferToHex(buffer: ArrayBuffer): string {
  const bytes = new Uint8Array(buffer);
  return Array.from(bytes)
    .map(b => b.toString(16).padStart(2, '0'))
    .join('');
}

/**
 * Converts ArrayBuffer to Base64 string.
 */
function bufferToBase64(buffer: ArrayBuffer): string {
  const bytes = new Uint8Array(buffer);
  let binary = '';
  for (let i = 0; i < bytes.byteLength; i++) {
    binary += String.fromCharCode(bytes[i]);
  }
  return btoa(binary);
}

/**
 * Constant-time string comparison to prevent timing attacks on signatures.
 */
function timingSafeEqualString(a: string, b: string): boolean {
  if (a.length !== b.length) {
    return false;
  }
  let mismatch = 0;
  for (let i = 0; i < a.length; i++) {
    mismatch |= a.charCodeAt(i) ^ b.charCodeAt(i);
  }
  return mismatch === 0;
}
