/**
 * FitKarma Least-Privilege Credential & Environment Helper
 * Governing Docs: Brain/security.md Section 5, Brain/api_contract.md
 */

import { EnvelopeParseError } from './envelopes.ts';

export type CredentialScope = 'anon' | 'service_role';

export interface EdgeEnvironmentCredentials {
  supabaseUrl: string;
  supabaseAnonKey: string;
  supabaseServiceRoleKey?: string;
  environment: string;
}

/**
 * Safely accesses runtime environment variables across Deno and Node runtimes.
 */
function getEnvVar(key: string): string | undefined {
  // @ts-ignore: Deno global detection
  if (typeof Deno !== 'undefined' && Deno.env?.get) {
    // @ts-ignore
    return Deno.env.get(key);
  }
  // @ts-ignore: Node process detection
  if (typeof process !== 'undefined' && process.env) {
    // @ts-ignore
    return process.env[key];
  }
  return undefined;
}

/**
 * Retrieves Supabase credentials conforming to the principle of least privilege.
 * Only returns the service role key if explicitly requested with scope 'service_role'.
 */
export function getServiceCredentials(
  scope: CredentialScope = 'anon',
  requestId: string = 'env_init'
): EdgeEnvironmentCredentials {
  const supabaseUrl = getEnvVar('SUPABASE_URL') || 'http://127.0.0.1:54321';
  const supabaseAnonKey = getEnvVar('SUPABASE_ANON_KEY') || 'mock-anon-key-local';
  const environment = getEnvVar('APP_ENV') || getEnvVar('SUPABASE_ENV') || 'local';

  if (!supabaseUrl) {
    throw new EnvelopeParseError(
      'FK-6001',
      'Configuration error: Missing SUPABASE_URL environment variable',
      requestId
    );
  }

  if (scope === 'service_role') {
    const serviceRoleKey = getEnvVar('SUPABASE_SERVICE_ROLE_KEY');
    if (!serviceRoleKey && environment !== 'local') {
      throw new EnvelopeParseError(
        'FK-1002',
        'Authorization error: Service role credentials required for privileged operation',
        requestId
      );
    }

    return {
      supabaseUrl,
      supabaseAnonKey,
      supabaseServiceRoleKey: serviceRoleKey || 'mock-service-role-local',
      environment,
    };
  }

  // Default: anon scope only (least privilege)
  return {
    supabaseUrl,
    supabaseAnonKey,
    environment,
  };
}
