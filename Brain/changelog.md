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
