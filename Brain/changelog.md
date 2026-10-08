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
