# FitKarma Multi-Environment Supabase Architecture

## 1. Environment Tiering

| Environment | Purpose | Supabase Instance | Database Target | Secret Storage |
|---|---|---|---|---|
| **Local / Dev** | Feature development, fast iterations, unit/widget tests | Local Docker container via `supabase start` | `127.0.0.1:54322` | `.env.local` (Git-ignored) |
| **CI / Test** | Automated test pipelines, migration validation, PR checks | Ephemeral Docker or branch project | Local / CI-hosted Postgres | GitHub Actions Repository Secrets |
| **Staging** | QA, pre-release verification, mock Razorpay UPI testing | Hosted Supabase project (`fitkarma-staging`) | Dedicated staging Postgres | Supabase Dashboard / Vault / CI secrets |
| **Production** | Live end-user traffic, DPDP compliance, live payments | Hosted Supabase project (`fitkarma-prod`) | Dedicated production Postgres | Supabase Vault / Encrypted production secrets |

## 2. Strict Boundary Rules

1. **Zero Secret Leakage to Client:**
   - Client builds only ever bundle public endpoints (`SUPABASE_URL`, `SUPABASE_ANON_KEY`).
   - Privileged server secrets (`SUPABASE_SERVICE_ROLE_KEY`, `RAZORPAY_KEY_SECRET`, `GROQ_API_KEY`, `WHATSAPP_ACCESS_TOKEN`) are configured strictly in Supabase Edge Functions environment variables via `supabase secrets set`.
   - The Flutter mobile client enforces this boundary via `AppConfig` and throws a `SecurityViolationException` if any server-side secret is detected in the client environment.

2. **Isolated Database State:**
   - Staging never connects to Production data stores.
   - Seed scripts (`supabase/seed.sql`) have automated assertions preventing execution in any environment whose database name contains `prod` or `live`.

3. **Deterministic Deployments:**
   - Schema modifications are applied through `supabase db push` or CI migration runners.
   - Manual schema edits in Supabase Studio or psql console are strictly prohibited in staging and production.
