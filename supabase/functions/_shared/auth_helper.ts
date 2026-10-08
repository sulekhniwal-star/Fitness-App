/**
 * FitKarma Edge Function Authentication & JWT Verification Helper
 * Governing Docs: Brain/security.md, Brain/api_contract.md, Brain/error_handling.md
 */

import type { JwtClaims } from './types.ts';
import { EnvelopeParseError } from './envelopes.ts';

export interface AuthContext {
  userId: string;
  role: string;
  email?: string;
  claims: JwtClaims;
}

/**
 * Extracts and verifies the JWT token from the Authorization header of an incoming request.
 * Throws an EnvelopeParseError with FK-1001 if token is missing, invalid, or expired.
 */
export async function verifyAuthToken(
  req: Request,
  options?: {
    jwtSecret?: string;
    allowedRoles?: string[];
    requestId?: string;
  }
): Promise<AuthContext> {
  const reqId = options?.requestId || req.headers.get('x-request-id') || 'unknown_req';
  const authHeader = req.headers.get('Authorization') || req.headers.get('authorization');

  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    throw new EnvelopeParseError(
      'FK-1001',
      'Authentication required: Missing or malformed Bearer token in Authorization header',
      reqId
    );
  }

  const token = authHeader.substring(7).trim();
  if (token.length === 0) {
    throw new EnvelopeParseError(
      'FK-1001',
      'Authentication required: Empty Bearer token',
      reqId
    );
  }

  const parts = token.split('.');
  if (parts.length !== 3) {
    throw new EnvelopeParseError(
      'FK-1001',
      'Invalid token: Malformed JWT structure',
      reqId
    );
  }

  // Parse Header and Payload
  let payload: JwtClaims;
  try {
    const payloadJson = decodeBase64Url(parts[1]);
    payload = JSON.parse(payloadJson) as JwtClaims;
  } catch (_e) {
    throw new EnvelopeParseError(
      'FK-1001',
      'Invalid token: Unable to decode JWT claims payload',
      reqId
    );
  }

  // Verify expiration
  if (typeof payload.exp === 'number') {
    const nowSec = Math.floor(Date.now() / 1000);
    if (payload.exp < nowSec) {
      throw new EnvelopeParseError(
        'FK-1001',
        'Authentication expired: JWT token has expired',
        reqId
      );
    }
  }

  // Cryptographic signature verification if secret is provided
  if (options?.jwtSecret && options.jwtSecret.length > 0) {
    const isValidSignature = await verifyHmacSha256(
      `${parts[0]}.${parts[1]}`,
      parts[2],
      options.jwtSecret
    );
    if (!isValidSignature) {
      throw new EnvelopeParseError(
        'FK-1001',
        'Invalid token: Cryptographic signature verification failed',
        reqId
      );
    }
  }

  // Check required user ID (sub)
  if (!payload.sub || typeof payload.sub !== 'string') {
    throw new EnvelopeParseError(
      'FK-1001',
      'Invalid token: Missing subject (sub) claim',
      reqId
    );
  }

  // Check role authorization if restricted
  const role = payload.role || 'authenticated';
  if (options?.allowedRoles && !options.allowedRoles.includes(role)) {
    throw new EnvelopeParseError(
      'FK-1002',
      `Access denied: Role '${role}' not authorized for this resource`,
      reqId
    );
  }

  return {
    userId: payload.sub,
    role,
    email: payload.email,
    claims: payload,
  };
}

/**
 * Decodes a base64url string to UTF-8 text using standard Web APIs.
 */
function decodeBase64Url(str: string): string {
  let base64 = str.replace(/-/g, '+').replace(/_/g, '/');
  while (base64.length % 4 !== 0) {
    base64 += '=';
  }
  const binaryStr = atob(base64);
  const bytes = new Uint8Array(binaryStr.length);
  for (let i = 0; i < binaryStr.length; i++) {
    bytes[i] = binaryStr.charCodeAt(i);
  }
  return new TextDecoder().decode(bytes);
}

/**
 * Verifies HMAC-SHA256 signature using Web Crypto API.
 */
async function verifyHmacSha256(data: string, signatureB64Url: string, secret: string): Promise<boolean> {
  const encoder = new TextEncoder();
  const key = await crypto.subtle.importKey(
    'raw',
    encoder.encode(secret),
    { name: 'HMAC', hash: 'SHA-256' },
    false,
    ['verify']
  );

  let base64 = signatureB64Url.replace(/-/g, '+').replace(/_/g, '/');
  while (base64.length % 4 !== 0) {
    base64 += '=';
  }
  const binarySig = atob(base64);
  const sigBytes = new Uint8Array(binarySig.length);
  for (let i = 0; i < binarySig.length; i++) {
    sigBytes[i] = binarySig.charCodeAt(i);
  }

  return await crypto.subtle.verify(
    'HMAC',
    key,
    sigBytes,
    encoder.encode(data)
  );
}
