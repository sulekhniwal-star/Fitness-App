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

## ADR-021 — Phone OTP Authentication Architecture & Session Persistence
**Status:** Accepted (Task 014)  
**Decision:** Implement phone OTP authentication using Supabase Auth SMS OTP (`signInWithOtp`, `verifyOtp`) backed by:
1. Strict Indian E.164 phone normalization (`+91` prefix, 10 national digits starting with 6-9, `^[6-9]\d{9}$`).
2. Reactive state controller (`PhoneAuthController`, `PhoneAuthState`) with 30-second resend cooldown timer and granular error state tracking (`FK-1001` AuthFailure, `FK-2001` ValidationFailure).
3. Dedicated accessible screens (`PhoneEntryScreen` and `OtpVerificationScreen`) utilizing `OtpPinInput` 6-cell Bento PIN display, spring physics, and inline error feedback.
4. Reactive router integration linking `authNavStatusProvider` to `isAuthenticatedProvider`, enabling automatic session persistence and route redirection to `/dashboard`.
5. Strict scope boundary: Google Sign-In is deferred to Task 015.  
**Reason:** Delivers a secure, India-first, privacy-compliant, accessible authentication flow with deterministic error handling, session persistence, and zero credential leakage.

## ADR-022 — Google Sign-In Architecture, User Deduplication & Logout
**Status:** Accepted (Task 015)  
**Decision:** Integrate Google authentication with the Supabase Auth architecture:
1. `ISupabaseAuthService.signInWithGoogle` supporting both native Google ID tokens and browser OAuth redirection via PKCE.
2. Strict user deduplication: accounts authenticating with the same verified email address reuse existing user records across multiple sign-in sessions and auth providers, preventing orphaned user profiles and split history.
3. User cancellation handling: voluntary dismissal of the Google account picker is categorized as a non-fatal cancellation state rather than an error condition.
4. Provider error mapping: OAuth failures and connectivity errors are scrubbed and translated via `SupabaseFailureMapper` into standard `FK-1001` or `FK-6001` error envelopes.
5. Unified session logout (`signOut`): invalidates local tokens, clears authentication state, and triggers declarative GoRouter redirection back to unauthenticated public routes.  
## ADR-023 — User Profile Domain Model & Local-First Repository Architecture
**Status:** Accepted (Task 016)  
**Decision:** Establish the core user profile domain model and repository boundary adhering to `Brain/data_model.md`, `Brain/pdr.md`, and `Brain/security.md`:
1. Domain Entities & Enums:
   - `BiologicalSex` with clinical Mifflin-St Jeor BMR constant offsets (+5 kcal male, -161 kcal female, -78 kcal other).
   - `ActivityLevel` with standard physical activity level (PAL) multipliers (1.20 to 1.90).
   - `FitnessGoal` with evidence-based recommended calorie adjustments (-500 to +300 kcal, clamped safely to >= 1200 kcal).
   - `DietaryIdentity` supporting Indian culinary and ethical taxonomy (`pureVeg`, `jain`, `vegetarian`, `eggetarian`, `vegan`, `nonVegetarian`, `pescatarian`) with helper predicates (`excludesEggs`, `excludesMeat`).
   - `NutritionPreferences` managing macro distributions (default 50% carbs / 25% protein / 25% fat), meal frequency, allergies, and fasting protocols.
   - `NotificationPreferences` managing daily DIP digest, meal, hydration, fasting, and workout cadences.
2. Clinical & Metabolic Computation:
   - BMI calculation (`kg / m²`).
   - Mifflin-St Jeor Basal Metabolic Rate (`BMR`).
   - Total Daily Energy Expenditure (`TDEE = BMR × PAL`).
   - Target calorie computation respecting primary goals and metabolic safety floors.
3. Domain Validation:
   - `UserProfileValidator` enforcing strict physiological ranges (age 13-120, height 50-250cm, weight 20-400kg, non-empty goals, macro ratio sum 1.0, meals 1-10, display name 2-60).
4. Sensitive Data Handling & DPDP Compliance:
   - `UserProfile.toRedactedJson` masks sensitive physical attributes (weight, age, display name) using `DataRedactor.redactedPlaceholder` (`[REDACTED]`), preventing leaks into telemetry or application logs.
5. Local-First Repository Pattern:
   - `IUserProfileRepository` and `LocalFirstProfileRepository` immediately persist changes to memory/cache and emit via broadcast stream before performing background Supabase sync.
   - Preserves offline state when remote synchronization is unavailable or network is severed.
   - Server synchronization is encapsulated entirely behind the repository boundary.
6. Supabase Relational Mapping:
   - Integrates cleanly with existing `public.profiles` schema by serializing domain-specific metabolic parameters into the documented JSONB `metadata` column.  
**Reason:** Decouples user profile domain logic and physiological calculations from UI and remote transport while guaranteeing DPDP-compliant data handling and local-first resilience.

## ADR-024 — FitKarma Onboarding Experience, Consent & Guest Architecture
**Status:** Accepted (Task 017)  
**Decision:** Implement the comprehensive 10-step FitKarma onboarding flow per `Brain/pdr.md`, `Brain/ui_spec.md`, `Brain/security.md`, and `Brain/api_contract.md`:
1. Flow Sequence & Wizard Structure:
   - Step 1: Welcome & Value Proposition (India-first nutrition, privacy by default, offline-first architecture, holistic fasting).
   - Step 2: Language Selection (English, Hindi dynamic switching; Tamil, Telugu, Kannada preview chips).
   - Step 3: Consent & DPDP Privacy Explanation (Local-first processing notice, data ownership declaration, affirmative consent requirement, medical disclaimer).
   - Step 4: Basic Profile (Display name, biological sex selection for Mifflin-St Jeor calculations, age 13–120, height 50–250cm, weight 20–400kg).
   - Step 5: Fitness Goals (Interactive Bento cards covering all 7 `FitnessGoal` values).
   - Step 6: Dietary Identity & Fasting (Indian taxonomy: pureVeg, Jain, vegan, vegetarian, eggetarian, nonVeg; meal frequency slider; fasting protocols: 16:8, 14:10, Circadian, Ekadashi).
   - Step 7: Activity Baseline (Sedentary, lightly active, moderately active, very active, extremely active with PAL multiplier indicators).
   - Step 8: Optional Ayurveda & Prakriti Personalization (Saffron gold dosha cards for Vata, Pitta, Kapha, Tridoshic with skip option).
   - Step 9: Permissions & Integrations (Notification preferences and Health Connect / HealthKit aggregate entry point).
   - Step 10: Account Setup (Phone OTP, Google Sign-In, and "Explore as Guest" offline mode).
2. Unsupported Medical Claim Safeguards:
   - Mandatory visible medical disclaimer in Consent and Ayurveda steps stating FitKarma provides lifestyle and wellness suggestions, not medical diagnoses or treatment.
   - Ayurvedic Prakriti insights explicitly framed as lifestyle and dietary guidance per classical taxonomy without clinical therapeutic claims.
3. Guest & Local-First Completion Architecture:
   - Supports anonymous guest exploration via `signInAnonymously()` generating a valid local session with `{'is_anonymous': true}` metadata.
   - UserProfile is assembled and stored locally via `IUserProfileRepository` before transitioning to `/dashboard`, allowing immediate, unhindered usage.
4. Navigation & State Management:
   - Managed via Riverpod `OnboardingController` maintaining step validation, error messaging, and bidirectional navigation.  
**Reason:** Provides a compliant, culturally nuanced onboarding experience that validates domain models, respects user privacy under DPDP, ensures seamless onboarding into the main application, and prevents unsupported medical claims.

## ADR-025 — Ayurveda & Prakriti Wellness Personalization Layer & Decoupling
**Status:** Accepted (Task 018)  
**Decision:** Implement the Ayurveda / Dosha feature as a separate, testable wellness personalization layer distinct from clinical health measurements, adhering to ADR-011, `Brain/pdr.md`, and `Brain/security.md`:
1. Strict Layer Decoupling:
   - Evidence-based health measurements: BMR (Mifflin-St Jeor), TDEE (BMR × PAL), BMI, target calories, and macro gram allocations are derived purely from clinical equations and remain 100% mathematically invariant to Ayurvedic constitutional states.
   - Traditional wellness layer: Prakriti tendencies (Vata, Pitta, Kapha, Tridoshic), questionnaire responses, and lifestyle suggestions operate strictly as an advisory self-reflection layer.
2. Deterministic Scoring Engine (`DoshaWellnessService`):
   - Assesses 7 classical Prakriti dimensions: Physical Frame, Skin & Temperature, Appetite & Digestion, Physical Energy, Sleep Pattern, Stress Response, and Climate Affinity.
   - Calculates point totals, percentages, and constitutional balance.
   - Tridoshic equilibrium: assigned when score range (max - min) is <= 15% or all percentages fall within the balanced 25%–40% range.
   - Dual-Dosha constitution: assigned when the top two doshas are within 15% of each other with secondary dosha identified.
   - Single dominant constitution: assigned when the highest dosha strictly exceeds runner-up by > 15%.
   - Classical tie-breaking: deterministic priority order (Vata -> Pitta -> Kapha).
3. Non-Medical Claim Safeguards:
   - Mandatory visible medical disclaimer (`WellnessProfile.nonMedicalDisclaimer`) embedded in the profile model and displayed prominently across UI screens: *"FitKarma Ayurvedic insights provide traditional lifestyle, dietary quality, and daily routine self-reflection suggestions. They are NOT clinical diagnoses, medical treatments, or healthcare advice. Always consult a licensed physician for any medical or nutritional concerns."*
   - Recommendations explicitly carry `isMedicalClaim: false` and focus on dietary gunas, seasonal adaptation (Ritucharya), daily rhythm (Dinacharya), and mindful movement.
4. Storage, Skip, and Revisitability:
   - Managed via `IWellnessProfileRepository` and `LocalFirstWellnessRepository` with reactive stream (`watchWellnessProfile`), local-first in-memory cache, and parent `UserProfile.dosha` synchronization.
   - Users can skip the assessment without blocking and can revisit, retake, or reset their profile at any time via `/wellness/dosha` (`DoshaWellnessScreen`).  
## ADR-026 — Account Lifecycle, DPDP Deletion Client Boundary & Local Data Wipe
**Status:** Accepted (Task 019)  
**Decision:** Implement comprehensive client-side account lifecycle management adhering to the Digital Personal Data Protection (DPDP) Act 2023, `Brain/security.md`, and `Brain/pdr.md`:
1. Complete Logout & Local Cache Cleanup:
   - `AccountLifecycleServiceImpl.logout(wipeLocalData: bool)` coordinates session termination via `ISupabaseAuthService.signOut()`.
   - When `wipeLocalData: true`, orchestrates sequential cross-store purging across `LocalDataWipeCoordinator`.
2. Safe Session Expiration Behavior:
   - Handles expired tokens/sessions gracefully. Clears sensitive local profile and health cache immediately before terminating the session (`FitKarmaAuthSession`), preventing data leakage across shared or recycled devices.
3. Session Restoration on Bootstrap:
   - `restoreSession()` inspects existing session state on app launch. Returns structured `SessionRestorationResult` (`restored`, `noSession`, `expired`, `failed`) to drive root routing deterministically.
4. DPDP-Compliant Deletion Client Boundary:
   - `requestAccountDeletion({String? reason, bool confirmDataLoss})` enforces explicit user confirmation (`confirmDataLoss == true`) before initiating deletion.
   - Dispatches client erasure request to the backend boundary (`POST /v1/data-erasure` with idempotency token). Full server-side purge execution remains deferred to backend tasks.
   - Issues `AccountDeletionReceipt` establishing a 30-day statutory grace period (`isGracePeriodActive`, `scheduledPurgeAt`) during which deletion can be cancelled (`cancelAccountDeletion`).
   - Triggers immediate local data wiping to safeguard device privacy while cloud purge is queued.
5. Local Data Wipe Coordinator:
   - `ILocalDataWipeCoordinator` and `LocalDataWipeCoordinator` provide a sequential, fault-tolerant registration boundary (`registerWipeableStore`) across all local storage domains (`user_profile`, `wellness_profile`, `auth_session`).
   - Safely isolates failures in individual stores while ensuring all other stores continue wiping.
6. Account Recovery Hooks:
   - `initiateAccountRecovery(AccountRecoveryRequest)` provides phone SMS OTP and email magic link hooks into `ISupabaseAuthService.signInWithOtp`.
7. Accessible UI & Intentional Confirmation:
   - `DeleteAccountDialog` enforces intentional deletion confirmation with an explicit data loss checkbox, optional reason capture, and DPDP grace period disclaimer.  
**Reason:** Guarantees user sovereignty, compliance with the Digital Personal Data Protection Act 2023, prevents sensitive health data leakage on expired sessions, and provides clean client-side orchestration for future backend erasure pipelines.

## ADR-027 — Drift + SQLCipher Local Encrypted Persistence Foundation
**Status:** Accepted (Task 020)  
**Decision:** Establish the local encrypted persistence foundation using Drift and SQLCipher adhering to ADR-001, ADR-003, `Brain/architecture.md`, and `Brain/data_model.md`:
1. Core Database & SQLCipher Encryption:
   - Configured `AppDatabase` with `DatabaseConnectionFactory` generating file-backed SQLite connections encrypted via SQLCipher (`PRAGMA key = '...'` with escaping) and in-memory isolated test connections.
   - Enforces `PRAGMA foreign_keys = ON;` and `PRAGMA cipher_memory_security = ON;`.
2. Foundation Schemas (Phase 3 Baseline):
   - `LocalProfiles` (`profiles_table.dart`): User profiles with physiological metrics, dietary identity, goals, and sync flags.
   - `LocalWellnessProfiles` (`wellness_profiles_table.dart`): Ayurveda/Dosha constitutional states and recommendations.
   - `LocalSyncOutbox` (`sync_outbox_table.dart`): Offline outbox queue for atomic synchronization, status tracking, and retry handling.
   - `LocalAppSettings` (`app_settings_table.dart`): Key-value store for application flags and offline states.
3. Schema Versioning & Migration Framework:
   - Baseline initialized at `schemaVersion = 1`.
   - Structured `MigrationStrategy` with `_applyMigrationStep` supporting deterministic, step-by-step version upgrades and foreign key validation upon database opening.
4. Repository Access Boundary & Data Access Objects (DAOs):
   - Created clean, strongly-typed DAOs: `ProfileDao`, `WellnessProfileDao`, `SyncOutboxDao`, and `AppSettingsDao`.
   - Exposed reactive Streams for realtime UI updates (`watchProfileByUserId`, `watchWellnessProfileByUserId`).
5. Atomic Transactions & Local Data Wipe:
   - `LocalDatabase.runInTransaction` / `AppDatabase.transaction` guarantees ACID atomicity with automated rollback on unhandled exceptions.
   - `LocalDatabase.wipeLocalData()` and `AppDatabase.wipeAllData()` atomically delete all local records across all tables within a single transaction, supporting DPDP Act 2023 compliance.  
**Reason:** Establishes the offline-first encrypted storage foundation required for resilient tier-2/3 network operation, local-first data ownership, zero plain-text disk leakage, and seamless transition to sync engine outbox processing.


