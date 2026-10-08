/**
 * FitKarma Health-Check Edge Function
 * Governing Docs: Brain/api_contract.md, Brain/security.md
 *
 * Note: Only a health-check function is allowed in TASK 012C.
 * All concrete feature routes remain PROPOSED until their respective feature tasks.
 */

import { CORS_HEADERS, createErrorResponse, createSuccessResponse, parseRequestEnvelope, EnvelopeParseError } from '../_shared/envelopes.ts';
import { getServiceCredentials } from '../_shared/credentials.ts';

export interface HealthCheckData {
  status: 'healthy';
  service: 'fitkarma-edge';
  version: string;
  timestamp: string;
  environment: string;
  nodeOrDeno: string;
}

export async function handleHealthCheck(req: Request): Promise<Response> {
  // 1. CORS Preflight Handling
  if (req.method === 'OPTIONS') {
    return new Response(null, {
      status: 204,
      headers: CORS_HEADERS,
    });
  }

  let requestId = 'unknown';

  try {
    // 2. Parse Request Envelope
    const envelope = await parseRequestEnvelope(req);
    requestId = envelope.request_id;

    // 3. Environment & Runtime inspection
    const creds = getServiceCredentials('anon', requestId);
    // @ts-ignore
    const runtimeName = (typeof Deno !== 'undefined') ? 'deno' : 'node';

    const healthData: HealthCheckData = {
      status: 'healthy',
      service: 'fitkarma-edge',
      version: '1.0.0',
      timestamp: new Date().toISOString(),
      environment: creds.environment,
      nodeOrDeno: runtimeName,
    };

    // 4. Return standard response envelope
    return createSuccessResponse({
      data: healthData,
      requestId,
      warnings: [],
      status: 200,
    });
  } catch (err: unknown) {
    if (err instanceof EnvelopeParseError) {
      return createErrorResponse({
        code: err.code,
        message: err.message,
        requestId: err.requestId,
      });
    }

    const errorMsg = (err instanceof Error) ? err.message : 'Unknown internal error';
    return createErrorResponse({
      code: 'FK-9999',
      message: `Health check error: ${errorMsg}`,
      requestId,
      status: 500,
    });
  }
}

// Default export / serve entry point for Deno Edge Functions
// @ts-ignore: Deno serve detection
if (typeof Deno !== 'undefined' && Deno.serve) {
  // @ts-ignore
  Deno.serve(handleHealthCheck);
}
