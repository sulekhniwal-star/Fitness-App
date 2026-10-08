# FitKarma Documentation Changelog

## 2026-10-08 — Documentation architecture expansion

- Preserved the main master documentation as the high-level source.
- Created dedicated domain specifications under `Brain/`.
- Incorporated India-first nutrition, WhatsApp, family health, fasting, AQI, Ayurveda, women's health and DIP strategy from the competitive analysis.
- Moved adaptive TDEE earlier in the strategic roadmap.
- Formalized Razorpay + UPI + UPI AutoPay as the active payment direction.
- Documented the historical migration from RevenueCat to Razorpay in `decisions.md`; RevenueCat is not an active architecture dependency.
- Classified undefined implementation details as `PROPOSED` or `OPEN DECISION`.
- Added testing, security, CI/CD, production and AI-agent rules.

## 2026-10-08 — TASK 001: Greenfield repository and environment audit

- Completed greenfield repository and environment audit in `Brain/implementation_audit.md`.
- Confirmed repository is in clean greenfield state with no application code, schema, or tests.
- Audited toolchain: Flutter 3.47.6, Dart 3.13.5, Android SDK 37.0.0, OpenJDK 25.0.3, Node v24.18.0.
- Synchronized `Todo.md` with v1.1 build plan and restored `.agent/skills/SKILL.md`.
- Marked all historical source baseline claims as UNVERIFIED.

## 2026-10-08 — TASK 001A: Documentation wiring and doc-lint gate

- Verified all 18 Brain documentation files, `.agent/skills/SKILL.md`, and `FitKarma_Master_Documentation_v1.md` resolve correctly.
- Reconciled documentation folder naming (legacy docs path updated to `Brain/`).
- Added automated link-check and doc-lint script in `scripts/doc_lint.js` (microtasks DOC-001, DOC-002), wired to `npm run doc:lint`.
- Validated RevenueCat exclusion: isolated strictly to historical migration context in `decisions.md` and `changelog.md`.
- Explicitly documented historical baseline claims (160/160 tests, zero analyzer issues, 28-table deletion cascade, pgTAP validation) as UNVERIFIED across `testing.md`, `security.md`, and `implementation_audit.md`.
- Ran doc-lint check: 67/67 checks passed.

## 2026-10-08 — TASK 002: Bootstrap Flutter application

- Initialized clean Flutter application with package ID `com.sulekhniwal.fitkarma` and Android/iOS targets.
- Configured application metadata with Dart 3.13.5 / Flutter 3.47.6.
- Created minimal dark-theme bootstrap shell in `lib/main.dart` with zero business logic or unnecessary packages.
- Added and verified bootstrap smoke test in `test/widget_test.dart`.
- Passed `flutter pub get`, `dart format`, `flutter analyze` (0 issues), `flutter test` (all tests passed), and `flutter build bundle`.

## 2026-10-08 — TASK 003: Establish Git ignore, environment, and secret boundaries

- Updated `.gitignore` with comprehensive rules ignoring all `.env*` files (preserving `.env.example`), signing keys, keystores, platform secrets, node_modules, and local Supabase runtime files.
- Created `.env.example` defining client-safe configuration (`APP_ENV`, `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SENTRY_DSN`) while documenting strict server-side quarantine for server secrets.
- Implemented strongly-typed `AppConfig` in `lib/core/config/app_config.dart` with programmatic validation and `SecurityViolationException` rejecting any server secret keys (`SUPABASE_SERVICE_ROLE_KEY`, `RAZORPAY_KEY_SECRET`, `GROQ_API_KEY`, etc.).
- Added unit tests in `test/core/config/app_config_test.dart` asserting configuration validation and secret boundary enforcement (8/8 tests passing).
- Documented environment and secret boundaries in `Brain/security.md`.

## 2026-10-08 — TASK 004: Establish project folder architecture

- Structured modular directory boundaries (`app/`, `core/`, `shared/`, `features/`) adhering to `Brain/architecture.md`.
- Implemented bootstrap architecture in `lib/app/bootstrap.dart` and `lib/app/fitkarma_app.dart`, cleanly separating entry point orchestration from UI definitions.
- Scaffolded core boundaries (`constants/`, `errors/`, `services/`, `database/`, `sync/`) and shared presentation primitives.
- Established feature domain modules (`auth/`, `profile/`, `dashboard/`, `nutrition/`, `health_tracking/`, `family/`, `payments/`, `data_vault/`).
- Added testing helper `test/helpers/pump_app.dart`.
- Documented folder hierarchy and strict dependency-direction rules in `Brain/architecture.md`.

## 2026-10-08 — TASK 005: Riverpod application architecture

- Integrated `flutter_riverpod: ^2.6.1` adhering to the TRD and Master Documentation v1 Riverpod 2.x baseline.
- Implemented root dependency injection via `ProviderScope` and `bootstrap.dart`.
- Created core providers in `lib/core/providers/core_providers.dart`: `appConfigProvider`, `loggingServiceProvider`, `localDatabaseProvider`, and `syncEngineProvider`.
- Implemented `AppProviderObserver` for centralized lifecycle monitoring, diagnostic logging, and error capture with PII redaction.
- Created `test/core/providers/provider_architecture_test.dart` asserting that all root dependencies are cleanly overridable in tests and that UI widgets observe provider state changes without hard-coded external clients.

## 2026-10-08 — TASK 006: Navigation and route architecture

- Integrated `go_router: ^18.0.2` and wired declarative routing through Riverpod (`appRouterProvider`, `authNavStatusProvider`, `routerNotifierProvider`).
- Established centralized route paths in `lib/core/routing/app_routes.dart` covering both unauthenticated entry points (`/onboarding`, `/auth/login`, `/auth/otp`) and authenticated top-level product areas (`/dashboard`, `/nutrition`, `/nutrition/log`, `/workouts`, `/sleep`, `/recovery`, `/ai/meal-analyze`, `/family`, `/subscriptions`, `/settings`, `/data-vault`).
- Implemented reactive auth-aware route guarding (unauthenticated access redirects to onboarding; authenticated sessions route to dashboard).
- Created modular placeholder shells in `lib/core/routing/placeholder_screens.dart` with semantic test keys for every top-level area.
- Added comprehensive navigation tests in `test/core/routing/app_router_test.dart` asserting auth-guard redirects and traversal to all product areas (17/17 tests passing).
- Documented the confirmed route skeleton and guard behavior in `Brain/ui_spec.md`.

## 2026-10-08 — TASK 007: Error and result primitives

- Implemented `AppFailure` sealed class taxonomy in `lib/core/errors/failures.dart` mapping all `FK-xxxx` codes from `Brain/error_handling.md` (`FK-1001` to `FK-7001` and `FK-9999`).
- Created standard JSON serialization and deserialization matching the documented error envelope (`code`, `message`, `retryable`, `request_id`).
- Implemented user message sanitization logic stripping stack traces, SQL error substrings, and credential leaks.
- Implemented functional `Result<T>` container in `lib/core/errors/result.dart` with `Success<T>` and `FailureResult<T>`, supporting pattern-matching (`when`), `map`, `flatMap`, and `getOrElse`.
- Added unit test suite in `test/core/errors/failures_and_result_test.dart` (7 tests covering code mapping, recovery rules, serialization, message sanitization, and Result mechanics; total 24/24 tests green).

## 2026-10-08 — TASK 008: Logging and observability foundation

- Implemented DPDP-compliant `DataRedactor` in `lib/core/observability/redaction.dart` providing recursive sanitization across maps, lists, and strings for authentication credentials, payment details, raw sensitive health observations (glucose, BP, HR, medications), and personal data (phones, emails, Aadhaar, PAN).
- Created `LoggingService` contract and `DiagnosticEvent` model in `lib/core/observability/logging_service.dart`.
- Enhanced `ConsoleLoggingService` with environment-awareness (suppressing debug logs in production) and parameter scrubbing.
- Scaffolded `SentryCrashReportingBoundary` in `lib/core/observability/crash_reporting_service.dart` with client-side scrubbing hooks for breadcrumbs and exception extras, safely operating without production secrets.
- Wired `dataRedactorProvider` and `crashReportingServiceProvider` into Riverpod core providers.
- Added comprehensive unit tests in `test/core/observability/redaction_and_observability_test.dart` (10 tests; total 34/34 tests green).

## 2026-10-08 — TASK 008A: Feature flags and backend-configurable remote config

- Implemented dynamic commercial subscription models in `lib/core/config/remote_config.dart` (`SubscriptionPlan`, `BillingCadence`) ensuring plan names, prices, and entitlements are never hard-coded architectural constants.
- Created `RemoteConfig` supporting feature flags, emergency kill switches, safe deterministic offline defaults (`RemoteConfig.defaults()`), and JSON serialization with runtime secret detection (`SecurityViolationException`).
- Implemented `ConfigCacheStorage` and `RemoteConfigService` in `lib/core/config/remote_config_service.dart` providing offline-cached remote config restoration, dynamic feature-flag resolution, and emergency kill switches (`kill_switch_ai_routing`, `kill_switch_whatsapp_logging`, `kill_switch_external_providers`) that immediately disable associated capabilities.
- Gated P1/P2/PROPOSED capabilities by default (`photo_food_logging`, `aqi_weather_context`, `tamil_telugu_support`, `family_care_dashboard`, `cgm_pipeline`).
- Exposed `remoteConfigServiceProvider` in `lib/core/providers/core_providers.dart` for Riverpod dependency injection.
- Added comprehensive unit tests in `test/core/config/remote_config_test.dart` (13 tests verifying defaults, serialization, secret rejection, caching, offline fallback, flag evaluation, kill switch overrides, and Riverpod registration; total 47/47 tests green).
- Completed Phase 0 engineering foundation gate.

## 2026-10-08 — TASK 009: FitKarma design system

- Created centralized design tokens under `lib/shared/presentation/theme/`:
  - `AppColors`: Primary dark background (`#0D0F12`), dark surfaces (`#161A22`, `#1F2430`), Neon Mint (`#00E599`), Saffron Gold (`#FF9933`), Tech Blue (`#38BDF8`), and high-contrast text (`#F8FAFC`, `#94A3B8`).
  - `AppTypography`: High-contrast, mobile-first font scale with tabular metric numerals.
  - `AppSpacing`: 8dp layout scale with WCAG 2.1 compliant 48dp minimum touch target (`minTouchTarget`).
  - `AppRadii`: Bento standard radii (`roundedMd: 16`, `roundedLg: 24`, `roundedFull: 999`).
  - `AppMotion`: Tactile spring-physics curves and durations (`fast: 150ms`, `normal: 250ms`, `slow: 400ms`).
  - `FitKarmaTheme`: Complete dark Material 3 theme configuration applied across `FitKarmaApp`.
- Implemented accessible shared UI primitives under `lib/shared/presentation/widgets/`:
  - `AppButton`: Tactile spring feedback, primary mint / secondary / saffron / ghost variants, loading spinner, and 48dp accessible touch target.
  - `AppTextField`: Dark styled text input with glass border, prefix/suffix icons, helper/error states.
  - `GlassContainer` & `BentoCard`: Frosted glass blur container (`BackdropFilter`) and modular Bento grid card primitive with headers, icons, trailing widgets, and spring touch animations.
  - `AppChip` & `AppStatusBadge`: Multi-selection filter chip and non-color-only accessible status badges.
  - `AppProgressBar`: Smooth animated progress bar with clamped values and nutrient / step meter gradients.
  - `StateViews`: `AppLoadingView`, `AppEmptyStateView`, and `AppErrorStateView` with `FK-xxxx` error code support and retry action.
- Built internal Storybook showcase screen in `lib/shared/presentation/showcase/design_system_showcase_screen.dart` wired to public route `/showcase`.
- Added unit and widget tests in `test/shared/presentation/theme_and_components_test.dart` (15 tests covering tokens, touch target accessibility, component interactions, and showcase rendering; total 62/62 tests green).
- Finalized design tokens in `Brain/ui_spec.md` and recorded ADR-016 in `Brain/decisions.md`. Offline bundled brand font files noted as OPEN DECISION until pre-launch packaging in Phase 13.

## 2026-10-08 — TASK 010: Localization foundation

- Implemented centralized localization architecture in `lib/core/localization/`:
  - `AppSupportedLocale`: Encompasses active Phase 1 languages (English, Hindi) and prepared expansion languages (Tamil, Telugu, Gujarati, Bengali, Marathi, Punjabi).
  - `AppStrings`: Strongly-typed interface for UI string catalogs, completely separating static UI localization from AI-generated conversational phrasing.
  - `EnglishStrings` & `HindiStrings`: Native string catalogs covering navigation, common actions, health metrics, status badges, and error/recovery states.
  - `AppLocalizations`: Centralized Flutter delegate with safe, deterministic fallback to English for missing keys or expansion languages.
  - `appLocaleProvider` & `appStringsProvider`: Reactive Riverpod state management enabling live locale switching without application restart.
- Implemented `AiPhrasingConfig` in `lib/core/localization/ai_conversational_phrasing.dart`:
  - Decoupled AI conversational generation from UI strings.
  - Models `AiConversationalDialect` (including natural Hinglish, regional Indian languages), `HinglishMixRatio` (subtle 15%, balanced 45%, vernacularHeavy 75%), coaching tone (supportive elder, peer buddy, clinical specialist), and fasting awareness directives.
- Updated `FitKarmaApp` in `lib/app/fitkarma_app.dart` with `flutter_localizations` delegates and reactive `appLocaleProvider`.
- Enhanced `DesignSystemShowcaseScreen` with interactive live language switcher and localization showcase section (Section 9).
- Added comprehensive unit and widget tests in `test/core/localization/localization_test.dart` (10 tests asserting locale enumeration, string parity, fallback behavior, immediate widget updates without app restart, and strict separation between UI i18n and AI conversational directives; total 72/72 tests green).

## 2026-10-08 — TASK 011: Accessibility foundation

- Implemented reusable accessibility utilities and wrappers under `lib/shared/presentation/accessibility/`:
  - `AccessibilityHelpers`: WCAG 2.1 AA luminance contrast calculations (`meetsWcagAa`), minimum 48x48dp touch target constraints (`minTouchTargetConstraints`), and system reduced-motion duration resolution (`getAccessibleDuration`).
  - `AccessibleTouchTarget`: Widget wrapper guaranteeing 48x48dp minimum bounds without altering child layout.
  - `SemanticReadingOrder`: Traversal ordering wrapper attaching `OrdinalSortKey` for logical screen-reader navigation across Bento tiles and health cards.
  - `AdaptiveTextScaleContainer`: Layout protection wrapper clamping dynamic text scaling gracefully (up to 200%) and preventing layout clipping.
  - `AccessibleFocusIndicator`: Accessible focus decoration wrapping interactive elements with a distinct high-contrast Neon Mint border and glow for keyboard and switch-access navigation.
- Enhanced shared UI components for accessibility compliance:
  - `AppButton` & `BentoCard`: Integrated system reduced-motion checks (`AccessibilityHelpers.getAccessibleDuration`) collapsing tap animations to `Duration.zero` when `disableAnimations` is active.
  - `BentoCard`: Expanded title and subtitle wrapping (`maxLines: 2`) to eliminate truncation and RenderFlex overflow at 200% text scale.
- Added comprehensive accessibility tests in `test/shared/presentation/accessibility_test.dart` (13 tests verifying WCAG contrast ratios, 48dp touch bounds, screen-reader semantics, reading order traversal, focus indicator behavior, reduced motion compliance, and RenderFlex safety at 2.0x text scale; total 85/85 tests green).

## 2026-10-08 — TASK 012: Shared UI states and components

- Implemented comprehensive reusable UI primitives under `lib/shared/presentation/widgets/`:
  - `AppScaffold`: Screen wrapper integrating safe area, background gradient styling, customizable `AppTopBar`, floating bottom navigation slot, offline indicator banner, and connectivity status awareness.
  - `AppTopBar`: Theme-aware top navigation bar with back navigation, action buttons, title/subtitle support, and frosted glass effect.
  - `OfflineIndicatorBanner`: Animated, high-visibility connectivity indicator banner notifying users of offline status and pending sync queue items.
  - `AppBottomNavBar`: Bottom navigation shell with active/inactive tab states, badge counters, glass styling, and spring tap feedback.
  - `AppSectionHeader`: Structured section title with optional subtitle, trailing action ("See all" / CTA button), and semantic heading hierarchy.
  - `MetricCard`: Bento-style health and fitness metric display featuring tabular numeral typography, unit labeling, trend indicator badges (positive/negative/neutral), subtitle context, and optional progress bar.
  - `SkeletonLoader`, `SkeletonLine`, `SkeletonCard`: Pulse-animated loading skeletons with reduced-motion awareness and overflow-safe layouts for cards, lines, and bento grids.
  - `AppSnackBar`: Floating toast notifications supporting success, error, warning, and info variants with high-contrast icons, dismiss actions, and WCAG AA contrast.
  - `AppConfirmationDialog`: Modal confirmation dialog with standard and destructive variants, customized action buttons, and keyboard escape handling.
  - `AppConsentDialog`: DPDP Act 2023 compliant data-processing consent modal supporting explicit opt-in, itemized purpose lists, and data usage disclosures.
  - `AppErrorPanel`: Inline dismissible error card supporting error codes (`FK-xxxx`), user-friendly sanitized messages, and customizable retry actions.
- Re-exported all new primitives through `lib/shared/presentation/widgets/shared_widgets.dart`.
- Added comprehensive widget test suite in `test/shared/presentation/shared_ui_components_test.dart` (12 tests covering AppScaffold, AppTopBar, OfflineIndicatorBanner, AppBottomNavBar, AppSectionHeader, MetricCard, SkeletonLoader, AppSnackBar, AppConfirmationDialog, AppConsentDialog, and AppErrorPanel; total 97/97 tests green).

## 2026-10-08 — TASK 012A: Supabase project, local stack and versioned migrations

- Initialized greenfield Supabase CLI configuration in `supabase/config.toml` with `project_id = "fitkarma"`, standard local ports (API 54321, DB 54322, Studio 54323), auth rate limits, and seed paths.
- Established versioned migrations directory `supabase/migrations/` using monotonic timestamp naming convention `<YYYYMMDDHHMMSS>_<name>.sql`.
- Created initial database extension migration `supabase/migrations/20261008000000_init_extensions.sql` enabling baseline PostgreSQL extensions (`uuid-ossp`, `pgcrypto`, `citext`, `pg_trgm`). Product tables intentionally deferred to TASK 012B.
- Created seed and test fixture architecture under `supabase/seeds/` (`01_reference_catalogs.sql`, `02_test_personas.sql`) coordinated via root `supabase/seed.sql` with automated safety assertions preventing execution against production databases.
- Documented multi-environment tiering and secret isolation (local, CI, staging, production) in `supabase/environments/README.md` and template `supabase/.env.example`.
- Implemented automated migration and workspace validator `scripts/validate_migrations.js` (wired to `npm run db:lint` / `npm run db:validate`) verifying filename patterns, monotonic timestamp order, SQL non-emptiness, production safety guards, and absence of committed secrets.
- Recorded ADR-017 in `Brain/decisions.md`.

## 2026-10-08 — TASK 012B: Baseline schema and universal RLS

- Created migration `supabase/migrations/20261008000001_baseline_schema_and_rls.sql` covering all 14 CONFIRMED concepts in `Brain/data_model.md`:
  - `profiles`, `food_catalog`, `recipes`, `cooking_multipliers`, `health_observations`, `food_logs`, `workouts`, `sleep_recovery_logs`, `habits`, `medications`, `family_health_relationships`, `entitlements`, `push_tokens`, `storage_assets`, `audit_deletion_operations`.
- Enforced universal default-deny Row Level Security (`ALTER TABLE ... ENABLE ROW LEVEL SECURITY`) on all 15 public tables with zero permissive anonymous access policies.
- Enforced authenticated owner-only access (`auth.uid() = user_id`) and `ON DELETE CASCADE` foreign keys linking user-owned rows to `auth.users(id)`.
- Configured 4 private Supabase Storage buckets (`meal_photos`, `medical_reports`, `voice_notes`, `data_exports`) with `public = false` and path-based user ownership RLS.
- Created `public.delete_user_data(target_user_id uuid)` `SECURITY DEFINER` function establishing the auditable cascading deletion foundation for DPDP compliance.
- Established pgTAP test harness in `supabase/tests/00000_rls_isolation_test.sql` (37 assertions covering table existence, universal RLS, anonymous rejection, and tenant isolation where User B cannot read or alter User A data).
- Updated `Brain/data_model.md` explicitly classifying all concrete physical columns as PROPOSED specifications.
- Recorded ADR-018 in `Brain/decisions.md`.
- Updated `scripts/validate_migrations.js` to assert RLS, cascading foreign keys, pgTAP suites, and private storage buckets in CI.

## 2026-10-08 — TASK 012C: Edge Function scaffold and API contract baseline

- Established shared Deno/TypeScript Edge Function modules under `supabase/functions/_shared/`:
  - `types.ts`: Defined `RequestEnvelope`, `ResponseEnvelope`, `ErrorEnvelope`, `RateLimitBucket`, `JwtClaims`, and `AppErrorCode` taxonomy (`FK-1001` through `FK-9999`).
  - `envelopes.ts`: Implemented `parseRequestEnvelope`, `createSuccessResponse`, `createErrorResponse`, and `mapErrorCodeToHttpStatus` adhering to `Brain/api_contract.md`.
  - `auth_helper.ts`: Implemented `verifyAuthToken` extracting Bearer JWTs, parsing claims, enforcing expiration checks, and denying unauthenticated access with `FK-1001`.
  - `idempotency.ts`: Implemented `withIdempotency` wrapper with `InMemoryIdempotencyStore` caching mutating operation responses and safely replaying duplicates.
  - `webhook_verifier.ts`: Implemented provider-agnostic `verifyWebhookSignature` using constant-time HMAC-SHA256 comparison for signed provider webhooks.
  - `rate_limiter.ts`: Implemented `RateLimiter` interface with `InMemoryTokenBucket` token bucket, explicitly marking rate limit thresholds as OPEN DECISION.
  - `credentials.ts`: Implemented `getServiceCredentials` enforcing least privilege and preventing server secrets from leaking into client payloads or logs.
- Created standalone `health-check` function in `supabase/functions/health-check/index.ts` handling `GET`, `OPTIONS`, and `POST` using standard envelopes. All concrete application endpoints remain PROPOSED until their respective feature tasks.
- Added 18 function-level unit tests in `supabase/functions/tests/edge_foundation_test.ts` wired to `npm run test:edge`.
- Recorded ADR-019 in `Brain/decisions.md`.
- Completed Phase 1 (Backend, Database, and Data Access Foundation).
