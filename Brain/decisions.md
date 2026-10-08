# FitKarma Architecture & Product Decision Records

## ADR-001 — Offline-first architecture
**Status:** Accepted  
**Decision:** Drift + SQLCipher local persistence with outbox synchronization.  
**Reason:** Tier-2/Tier-3 and unreliable-network use cases require usable offline behavior.

## ADR-002 — Supabase backend
**Status:** Accepted  
**Decision:** Supabase for Postgres, Auth, Storage, Realtime and Edge Functions.  
**Reason:** Current product baseline and cost-effective integrated backend.

## ADR-003 — Drift + SQLCipher
**Status:** Accepted  
**Decision:** encrypted local SQLite through Drift/SQLCipher.  
**Reason:** offline source of truth and local privacy.

## ADR-004 — OS health aggregators first
**Status:** Accepted  
**Decision:** Health Connect and Apple Health/HealthKit are P0 before numerous direct wearable integrations.  
**Reason:** broad device coverage with lower engineering cost.

## ADR-005 — India-first nutrition
**Status:** Accepted  
**Decision:** Indian foods, household portions, cooking state and family-meal logic are core domain concepts.  
**Reason:** strategic differentiation and local usability.

## ADR-006 — WhatsApp as low-friction interface
**Status:** Accepted  
**Decision:** WhatsApp text/voice logging is a major P0/P1 interface.  
**Reason:** removes app-opening friction and supports Hinglish/vernacular behavior.

## ADR-007 — RevenueCat removal / historical payment dependency
**Status:** Accepted  
**Decision:** RevenueCat is not part of the active architecture; the previous dependency is removed.  
**Reason:** India-first UPI/Razorpay strategy.  
**Historical note:** RevenueCat is retained only as migration history in this ADR; it must not appear as an active payment dependency.

## ADR-008 — Razorpay adoption
**Status:** Accepted strategic direction  
**Decision:** Razorpay owns active payment processing.  
**Reason:** UPI-first Indian payment infrastructure and recurring mandate support.

## ADR-009 — UPI-first payments
**Status:** Accepted strategic direction  
**Decision:** UPI is a first-class payment method.  
**Reason:** product strategy targets Indian payment behavior.

## ADR-010 — UPI AutoPay
**Status:** Accepted strategic direction  
**Decision:** support recurring UPI mandate flows through Razorpay where available and legally/commercially enabled.  
**Reason:** subscription convenience and Indian payment fit.

## ADR-011 — Ayurveda wellness positioning
**Status:** Accepted  
**Decision:** Ayurveda is a cultural/wellness personalization layer, not medical treatment.  
**Reason:** preserve cultural relevance without unsupported medical claims.

## ADR-012 — Family Health strategy
**Status:** Accepted strategic direction  
**Decision:** build toward a consent-based Family Care Dashboard.  
**Reason:** household-centered health decisions and aging-parent care use case.

## ADR-013 — Dynamic TDEE moved earlier
**Status:** Accepted strategic roadmap change  
**Decision:** adaptive TDEE is brought into the India-first differentiation phase.  
**Reason:** static calorie targets are less adaptive and competitors demonstrate value in dynamic adjustment.

## ADR-014 — AI photo logging as P1
**Status:** Accepted strategic roadmap change  
**Decision:** build photo-based Indian food recognition with confirmation and uncertainty handling.  
**Reason:** reduces logging friction and improves retention potential.

## ADR-015 — Scope reduction / deferred features
**Status:** Accepted  
**Decision:** defer custom social feed, proprietary hardware, heavy video production and high-cost pose estimation from the core roadmap.  
**Reason:** protect solo-founder execution focus and the core nutrition/OS moat.

## ADR-016 — FitKarma Design System Tokens & Tactile Primitives
**Status:** Accepted (Task 009)  
**Decision:** Standardize dark-mode primary aesthetic (`#0D0F12`), high-contrast slate surfaces (`#161A22`, `#1F2430`), Neon Mint (`#00E599`) and Saffron Gold (`#FF9933`) accents, 8dp spacing scale with strict 48dp minimum accessible touch targets, frosted glass (`GlassContainer`), and modular Bento cards (`BentoCard`) with spring-physics touch feedback (`AppMotion.springBounce`, 150ms).  
**Reason:** Ensures strong text legibility across older/tier-2 demographics while establishing a differentiated, modern, tactile Bento-grid UI. Custom bundled offline font typography assets remain `OPEN DECISION` until pre-launch packaging (Phase 13).

## ADR-017 — Supabase Backend Workspace, Migration Protocol & Environment Separation
**Status:** Accepted (Task 012A)  
**Decision:** Standardize on Supabase CLI (`supabase/config.toml`, `project_id = "fitkarma"`) with strictly versioned timestamped migrations (`<YYYYMMDDHHMMSS>_<name>.sql` in `supabase/migrations/`), zero manual remote schema mutations, production-guarded seed fixtures (`supabase/seed.sql` and `supabase/seeds/`), strict multi-environment separation (local/dev, CI, staging, production with zero server secrets in client binaries), and automated CI migration validation (`npm run db:lint`). Product tables are intentionally deferred to TASK 012B.  
**Reason:** Guarantees deterministic database deployments, prevents configuration drift across team/CI/production environments, and enforces strict secret boundaries in alignment with DPDP and security architecture.

## ADR-018 — Baseline Relational Schema, Universal Default-Deny RLS & Cascading Erasure
**Status:** Accepted (Task 012B)  
**Decision:** Establish 15 baseline tables in `supabase/migrations/20261008000001_baseline_schema_and_rls.sql` covering all 14 CONFIRMED concepts in `Brain/data_model.md`. Enforce:
1. Universal default-deny Row Level Security on every table with zero permissive anonymous access.
2. Owner-only isolation (`auth.uid() = user_id`) for authenticated users.
3. Every user-owned table carries `user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE`.
4. Dedicated private Supabase Storage buckets (`meal_photos`, `medical_reports`, `voice_notes`, `data_exports`) with path-based owner RLS.
5. `public.delete_user_data(target_user_id uuid)` function implementing auditable cascading erasure foundation for DPDP compliance.
6. pgTAP test harness (`supabase/tests/00000_rls_isolation_test.sql`) verifying schema existence, universal RLS, anonymous denial, and multi-tenant isolation.
All concrete physical columns are recorded as `PROPOSED` specifications in `Brain/data_model.md` to avoid inferring unconfirmed historic schemas.  
**Reason:** Enforces least-privilege tenant isolation, prevents IDOR vulnerabilities, and establishes the verifiable foundation for DPDP cascading erasure.

## ADR-019 — Supabase Edge Function Architecture & API Contract Envelopes
**Status:** Accepted (Task 012C)  
**Decision:** Standardize Edge Functions under `supabase/functions/` in TypeScript using:
1. Strict Request Envelope (`request_id`, `idempotency_key`, `payload`) and Response Envelope (`request_id`, `data`, `warnings`, `error`).
2. Error envelopes mapped directly to the `FK-xxxx` taxonomy from `Brain/error_handling.md`.
3. Standardized JWT/Auth verification (`verifyAuthToken`) rejecting unauthenticated access with `FK-1001`.
4. Idempotency storage and replay helper (`withIdempotency`) preventing duplicate side-effects.
5. Provider-agnostic signed-webhook verification (`verifyWebhookSignature`) using constant-time HMAC comparison.
6. Rate-limit bucket interface (`RateLimiter` / `InMemoryTokenBucket`) with thresholds documented as `OPEN DECISION`.
7. Least-privilege credential extraction (`getServiceCredentials`) preventing leakage of service role secrets.
8. Only the `health-check` function is instantiated; all concrete application routes remain `PROPOSED` until their respective feature tasks.  
**Reason:** Enforces a clean, observable serverless boundary preventing contract drift, replay attacks, and secret leakage across mobile client and third-party provider integrations.

## ADR-020 — Client-Side Supabase Integration Boundary & Offline Mock Bootstrap
**Status:** Accepted (Task 013)  
**Decision:** Wrap the Flutter Supabase SDK in a typed service boundary (`ISupabaseService`, `ISupabaseAuthService`, `ISupabaseFunctionsService`, `ISupabaseStorageService`) backed by `SupabaseClientService` for production and `MockSupabaseService` for testing and offline development. Enforce:
1. Safe bootstrap fallback: app boots gracefully against placeholder credentials or without network.
2. Zero privileged server secrets in client binaries (enforced via `AppConfig.assertNoServerSecrets`).
3. Centralized failure mapping (`SupabaseFailureMapper`) translating SDK exceptions into user-safe `AppFailure` codes (`FK-1001` to `FK-9999`) and scrubbing technical database internals.
4. Reactive Riverpod auth providers (`supabaseServiceProvider`, `supabaseAuthServiceProvider`, `supabaseAuthStateProvider`, `currentUserProvider`, `isAuthenticatedProvider`).  
**Reason:** Enables testable, offline-first mobile client architecture without coupling development or automated testing to live hosted Supabase infrastructure, while maintaining strict secret boundaries.

