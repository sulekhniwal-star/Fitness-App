# FitKarma — From-Scratch Implementation TODO
## Version 1.1 — Greenfield Build Plan (improved, aligned with Brain docs and Master Documentation v1)

> This TODO is for a **completely new FitKarma application built from scratch**.
> Assume there is currently **no application code** unless the repository inspection proves otherwise.
>
> The implementation agent must use:
>
> - `.agent/skills/SKILL.md` as the highest-level agent skill/instruction file
> - `FitKarma_Master_Documentation_v1.md` as the root-level master specification
> - `Brain/` as the detailed product/technical documentation set
>
> Do **not** assume that an old Flutter codebase, database, API layer, widgets, services, migrations, or tests already exist.
>
> The agent must inspect the repository before every major phase and implement only the current task.

---

# HOW TO USE THIS FILE

Paste **one task at a time** into Antigravity IDE.

Recommended first message after the Master Prompt:

```text
Execute TASK 001 from Todo.md only.

Read .agent/skills/SKILL.md, FitKarma_Master_Documentation_v1.md, the relevant Brain documentation, and inspect the repository before making changes.

Do not continue to the next task automatically.
```

After a task finishes, paste the next task.

The agent must never silently implement later tasks.

---

# HOW THIS FILE IS ORGANISED (v1.1)

Every task now carries a metadata block:

| Field | Meaning |
|---|---|
| **Roadmap** | `R1` Phase 1 Competitive MVP (months 1–3) · `R2` Phase 2 India-First Differentiation (months 4–6) · `R3` Phase 3 Category Leadership (months 7–12) · `PL` pre-launch gate · tasks never implemented are listed under *Deferred* |
| **Priority** | `P0` must-have · `P1` high · `P2` expansion · `P3` deferred-until-ready (per Master Documentation §4) |
| **Depends on** | task IDs that must be COMPLETE first |
| **Brain docs** | documents the agent must read for that task (in addition to `master_rules.md`) |
| **Microtasks** | matching IDs in `Brain/microtasks.md` |
| **Done when** | the task-specific acceptance line (the Definition of Done below still applies) |

Task numbers 001–122 are **unchanged** from v1.0. New tasks use a letter suffix (for example `012A`) so existing references stay valid. Each phase also has a **Phase gate**: do not start the next phase until the gate is true.

## Known ordering notes (read before executing)

1. **Backend before auth.** Tasks `012A–012C` (Supabase workspace, baseline schema + RLS, Edge Function scaffold) must be completed before TASK 013. Authentication, sync, payments and WhatsApp all depend on them.
2. **Local database before profile.** TASK 016 (profile, local-first) depends on TASK 020 (Drift + SQLCipher). Execute 020–022 before 016, or implement 016 against the repository interface and plug persistence in afterwards.
3. **Payments foundation is Roadmap R1.** The Master Documentation puts the Razorpay/UPI foundation in Phase 1. Tasks 079–081, 083–084 and 084A are therefore R1 even though they appear in Phase 14; schedule them right after Phase 8. Only UPI AutoPay (TASK 082) is R2.
4. **Photo logging (TASK 062) is P1**, WhatsApp text/voice and AI meal analysis are P0 for Roadmap R2. Do not start 062 before 060 and 063A.
5. **Do not assume repository facts.** Source-reported baselines (160/160 tests, zero analyzer issues, 28-table `delete_user_data` cascade, pgTAP RLS validation) must be re-verified in this greenfield repository.

---

# GLOBAL EXECUTION RULES

Every task must follow this sequence:

1. Read `.agent/skills/SKILL.md`.
2. Read the root `FitKarma_Master_Documentation_v1.md`.
3. Read the Brain documents relevant to the task.
4. Inspect the current repository state.
5. State the implementation plan briefly.
6. Implement only the current task.
7. Add/update tests appropriate to the task.
8. Run formatting, static analysis, and relevant tests.
9. Fix issues caused by the task.
10. Update relevant documentation when implementation decisions change.
11. Review the final diff for unrelated changes.
12. Report:
   - files created/changed
   - functionality implemented
   - tests/checks run
   - failures/blockers
   - documentation updated
13. Stop.

### Greenfield rule

Because this project is being built from scratch:

- Prefer a clean architecture over trying to preserve nonexistent legacy code.
- Do not create compatibility layers for systems that do not exist.
- Do not invent old behavior.
- Do not add dependencies without documenting why they are needed.
- Do not create duplicate abstractions for the same responsibility.
- Build foundational layers before feature modules.
- Keep the app shippable after every major phase.

### Documentation rule

The documentation is the product/technical contract, but the repository is the implementation source of truth.

When a documented behavior is not technically defined, do not invent it as fact. Use:

`PROPOSED`

or

`OPEN DECISION`

and update `Brain/decisions.md` when a major architecture decision is made.

### Security rule

Health data, family data, AI data, WhatsApp data, payment data, and authentication data must be treated as sensitive.

Never put secrets in source control.

Never trust the client as the authority for payment entitlements.

Never bypass authorization/RLS merely to make a feature work.

### Offline-first rule

User-created health/nutrition/workout data should be designed around:

Local write
→ outbox
→ synchronization
→ server reconciliation

where the applicable feature is defined as offline-capable.

### Scope rule

Do not turn the first release into a giant feature dump.

The strategic priorities are:

1. foundational offline-first Health OS
2. Indian nutrition
3. Health Connect / Apple Health
4. WhatsApp logging
5. AI meal analysis
6. Dynamic TDEE
7. Family functionality
8. payments/monetization
9. privacy/trust
10. category-leadership integrations

### API and data-contract rule (added in v1.1)

- Public application APIs use JSON over HTTPS; authenticated calls carry Supabase JWT identity.
- Mutating requests accept or generate an idempotency key; responses follow the envelope in `Brain/api_contract.md`.
- Endpoint paths in `Brain/api_contract.md` are `PROPOSED` until the implementing task confirms them.
- Errors use the `FK-xxxx` taxonomy in `Brain/error_handling.md`; never expose stack traces, secrets or provider internals.

### Feature-lifecycle rule (added in v1.1)

Never silently remove a feature. Classify it as active, deferred, future or not recommended and record the change in `Brain/decisions.md` and `Brain/changelog.md`.

### Task-size and Git rule (added in v1.1)

- One branch per task; small commits; descriptive messages that include the task ID.
- If a task cannot finish in one session, split it into sub-steps, report which sub-step is complete, and stop. Do not leave the app unbuildable.

---

# PHASE 0 — REPOSITORY INITIALIZATION & ENGINEERING FOUNDATION

> **Phase gate:** Repo audited, Flutter app boots, secrets boundary + folder/Riverpod/routing/error/logging foundations tested, doc wiring verified.

## TASK 001 — Repository and Environment Audit

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** —  
> **Brain docs:** master_rules.md, architecture.md, trd.md, changelog.md · **Microtasks:** DOC-001, DOC-002  
> **Done when:** Audit documented; toolchain verified; no feature code added

Prompt:

```text
Perform a complete greenfield repository audit for FitKarma.

Read:
- .agent/skills/SKILL.md
- FitKarma_Master_Documentation_v1.md
- Brain/master_rules.md
- Brain/pdr.md
- Brain/trd.md
- Brain/architecture.md
- Brain/decisions.md
- Brain/data_model.md
- Brain/api_contract.md
- Brain/data_sources.md
- Brain/ui_spec.md
- Brain/security.md
- Brain/error_handling.md
- Brain/testing.md
- Brain/production_checklist.md
- Brain/github_actions.md
- Brain/admob_spec.md
- Brain/scrapping_spec.md
- Brain/changelog.md
- Brain/microtasks.md

Then inspect:
- repository tree
- Git state
- existing files
- pubspec/package metadata
- platform folders
- environment files
- CI configuration
- README/configuration
- available Flutter/Dart versions
- Android/iOS tooling
- existing SDK configuration

Assume there is no usable application code unless inspection proves otherwise.

Do NOT implement product features yet.

Create a concise Greenfield Repository Audit in the repository documentation describing:
- what actually exists
- what is missing
- detected Flutter/Dart versions
- detected platform/toolchain constraints
- immediate blockers
- recommended bootstrap sequence

If the repository is effectively empty, explicitly record that.

Do not move to TASK 002 automatically.
```

Acceptance criteria:
- repository state is documented
- toolchain is verified
- no feature code is introduced

---

## TASK 001A — Documentation Wiring and Doc-Lint Gate

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 001 · 🆕 **Added in v1.1**  
> **Brain docs:** master_rules.md, architecture.md, trd.md · **Microtasks:** DOC-001, DOC-002  
> **Done when:** All Brain docs resolvable; link-check + doc-lint scripts pass; baseline claims marked unverified

Prompt:

```text
Verify and wire the documentation contract before any code is written.

Check that these exist and resolve from the repository root:
- .agent/skills/SKILL.md
- FitKarma_Master_Documentation_v1.md
- Brain/: master_rules, pdr, trd, architecture, data_model, api_contract, data_sources, ui_spec, security, error_handling, testing, production_checklist, github_actions, admob_spec, scrapping_spec, decisions, changelog, microtasks

Then:
- reconcile the documentation folder name (Brain/ vs /docs) and fix stale paths
- add a documentation link-check script and a lightweight doc-lint (DOC-001, DOC-002)
- record source-reported baselines (160/160 tests, zero analyzer issues, delete_user_data across 28 tables, pgTAP RLS validation) as UNVERIFIED until re-run in this repository
- scan for RevenueCat; it may remain only as historical migration context in decisions/changelog

No product code. Update Brain/changelog.md.
```

Acceptance criteria:
- see "Done when" above and the Definition of Done

---

## TASK 002 — Bootstrap Flutter Application

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 001  
> **Brain docs:** master_rules.md, architecture.md, trd.md · **Microtasks:** —  
> **Done when:** Debug build launches; smoke test, analyze and test pass

Prompt:

```text
Create the FitKarma Flutter application from scratch.

Use the repository audit plus the master/trd/architecture documentation.

Requirements:
- Android and iOS targets
- package/bundle identifiers consistent with the master documentation where applicable
- Flutter/Dart versions compatible with the documented baseline and the installed toolchain
- clean project generation
- debug build must launch
- no unnecessary packages yet
- maintainable project structure
- no feature implementation yet

Do not add business logic.

Add a minimal smoke test proving the generated application starts.

Run:
- flutter pub get
- dart format
- flutter analyze
- flutter test

Stop after bootstrap is healthy.
```

---

## TASK 003 — Establish Git Ignore, Environment, and Secret Boundaries

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 002  
> **Brain docs:** master_rules.md, architecture.md, trd.md, security.md · **Microtasks:** —  
> **Done when:** Secrets ignored by Git; .env.example documented; config boundary tested

Prompt:

```text
Set up secure environment/configuration boundaries for the greenfield FitKarma application.

Implement:
- .gitignore rules
- local development environment handling
- example environment configuration
- separation between public client configuration and server secrets
- documentation of required variables

Do not place:
- Supabase service-role keys
- Razorpay secret keys
- webhook secrets
- AI provider secrets
- WhatsApp secrets
- other private credentials

in the Flutter client.

Add tests/checks where practical and document the configuration model in the appropriate Brain document.
```

---

## TASK 004 — Establish Project Folder Architecture

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 002  
> **Brain docs:** master_rules.md, architecture.md, trd.md · **Microtasks:** —  
> **Done when:** Folder layout and dependency-direction rules documented

Prompt:

```text
Implement the agreed greenfield Flutter folder/module architecture from Brain/architecture.md.

Create the structural boundaries for:
- app/bootstrap
- core
- shared UI
- feature modules
- data layer
- domain layer
- infrastructure/services
- local persistence
- synchronization
- routing
- configuration
- testing helpers

Do not implement feature logic yet.

Use dependency-direction rules so feature modules do not become a tangled monolith.

Document the final repository structure.
```

---

## TASK 005 — Riverpod Application Architecture

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 004  
> **Brain docs:** master_rules.md, architecture.md, trd.md · **Microtasks:** —  
> **Done when:** App boots via Riverpod; dependencies overridable in tests

Prompt:

```text
Establish the FitKarma Riverpod architecture.

Implement:
- application-level providers
- dependency injection pattern
- environment/config provider
- repository/service provider boundaries
- lifecycle-safe provider conventions
- testable dependency overrides

Do not implement actual feature repositories yet.

Add architecture tests or representative provider tests proving:
- dependencies can be overridden in tests
- providers do not directly hard-code external clients
- the app can boot through Riverpod
```

---

## TASK 006 — Navigation and Route Architecture

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 005  
> **Brain docs:** master_rules.md, architecture.md, trd.md, ui_spec.md · **Microtasks:** —  
> **Done when:** Auth-aware route skeleton with placeholders for every top-level area

Prompt:

```text
Create the FitKarma navigation foundation.

Implement:
- authenticated vs unauthenticated navigation boundaries
- route naming conventions
- placeholder routes for major top-level product areas
- deep-link-safe route structure where practical
- centralized navigation definitions

Do not build full screens yet.

Navigation must be modular so onboarding, dashboard, nutrition, workouts, sleep, recovery, AI, family, subscriptions, settings, and Data Vault can be added without rewriting the navigation system.
```

---

## TASK 007 — Error and Result Primitives

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 004  
> **Brain docs:** master_rules.md, architecture.md, trd.md, error_handling.md · **Microtasks:** —  
> **Done when:** Result/error types map to FK-xxxx codes; user-safe messages tested

Prompt:

```text
Implement the shared application error/result foundation according to Brain/error_handling.md.

Create consistent primitives for:
- success
- validation failure
- authentication failure
- authorization failure
- offline failure
- synchronization failure
- network failure
- AI failure
- third-party provider failure
- payment failure
- unknown/internal failure

Do not implement feature-specific error handling yet.

Add unit tests for serialization/mapping/display-safe error behavior.

No sensitive data should leak into user-facing messages or logs.
```

---

## TASK 008 — Logging and Observability Foundation

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 007  
> **Brain docs:** master_rules.md, architecture.md, trd.md, security.md · **Microtasks:** —  
> **Done when:** Redaction tests pass; Sentry boundary wired without secrets

Prompt:

```text
Create the shared logging/observability foundation.

Prepare clean interfaces for:
- application logs
- crash reporting
- structured diagnostic events
- redaction of sensitive values
- environment-aware logging

Prepare integration boundaries for Sentry and other documented observability services, but do not activate production secrets.

Add tests proving sensitive-looking fields are redacted from logs where applicable.
```

---

## TASK 008A — Feature Flags and Backend-Configurable Remote Config

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 005, 008 · 🆕 **Added in v1.1**  
> **Brain docs:** master_rules.md, architecture.md, trd.md, pdr.md · **Microtasks:** —  
> **Done when:** Prices/plans/features resolved from backend config with offline cached defaults

Prompt:

```text
Implement the remote configuration / feature-flag foundation.

Requirements:
- plan names, prices, billing cadence and feature entitlements are backend-configurable; never hard-coded constants
- flags gate P1/P2/PROPOSED features (photo logging, AQI, Tamil/Telugu, family dashboard, CGM)
- kill switches for AI, WhatsApp and external-provider features
- cached last-known config so the app works offline
- safe defaults when config is unavailable
- config contains no secrets

Add unit tests for fallback, caching and flag evaluation.
```

Acceptance criteria:
- see "Done when" above and the Definition of Done

---

# PHASE 1 — DESIGN SYSTEM & UI FOUNDATION

> **Phase gate:** Dark-theme design system, EN/HI localization, accessibility helpers and shared UI primitives exist with widget tests; backend workspace (012A-012C) is ready before Phase 2 starts.

## TASK 009 — FitKarma Design System

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 005  
> **Brain docs:** ui_spec.md, trd.md · **Microtasks:** —  
> **Done when:** Theme tokens + showcase screen; undefined tokens logged OPEN DECISION

Prompt:

```text
Implement the FitKarma design system from Brain/ui_spec.md and the master documentation.

Establish:
- primary dark theme
- documented colors
- typography system
- spacing scale
- radius/elevation conventions
- button styles
- input styles
- cards
- chips
- progress indicators
- empty states
- loading states
- error states
- semantic accessibility labels

Respect the documented glassmorphism, spring-physics, Bento-grid visual direction without making every component visually excessive.

Create Storybook-like/internal showcase screens or component tests if appropriate.

Do not build the full product dashboard yet.
```

---

## TASK 010 — Localization Foundation

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 009  
> **Brain docs:** ui_spec.md, trd.md · **Microtasks:** —  
> **Done when:** EN/HI switching and fallback tested; AI phrasing separated from UI i18n

Prompt:

```text
Implement the localization architecture.

Initial languages:
- English
- Hindi

Prepare the system for:
- Hinglish AI-generated conversational content
- Tamil
- Telugu
- Gujarati
- Bengali
- Marathi
- Punjabi

Separate UI localization from AI-generated conversational phrasing.

Add tests for:
- locale switching
- missing translation fallback
- no hard-coded user-facing strings in newly created UI
```

---

## TASK 011 — Accessibility Foundation

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 009  
> **Brain docs:** ui_spec.md, trd.md · **Microtasks:** —  
> **Done when:** Helpers pass widget tests at large text scale

Prompt:

```text
Implement shared accessibility conventions for FitKarma.

Cover:
- text scaling
- contrast
- semantic labels
- touch target sizing
- screen-reader ordering
- meaningful focus behavior
- reduced motion considerations

Add reusable accessibility helpers where needed and representative widget tests.

Do not attempt to remediate nonexistent feature screens yet.
```

---

## TASK 012 — Shared UI States and Components

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 009, 010, 011  
> **Brain docs:** ui_spec.md, trd.md · **Microtasks:** —  
> **Done when:** Primitives theme-aware, localization-ready, widget-tested

Prompt:

```text
Build the reusable UI primitives needed by future FitKarma screens:

- AppScaffold
- top bars
- bottom navigation shell
- section headers
- Bento cards
- metric cards
- action buttons
- snackbars/toasts
- loading skeletons
- offline indicators
- empty states
- confirmation dialogs
- error panels
- consent dialogs

Ensure components are theme-aware and localization-ready.
Add widget tests.
```

---

## TASK 012A — Supabase Project, Local Stack and Versioned Migrations

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 003 · 🆕 **Added in v1.1**  
> **Brain docs:** security.md, api_contract.md, pdr.md, decisions.md · **Microtasks:** —  
> **Done when:** Local Supabase stack runs; migrations versioned; env separation documented

Prompt:

```text
Establish the Supabase backend workspace (greenfield; do not assume any existing project).

Implement:
- Supabase CLI configuration and local development stack
- versioned migrations directory and naming convention
- seed-data convention (seed/test data clearly marked)
- separation of dev/staging/production configuration without committing secrets
- migration validation step runnable in CI

Record the decision in Brain/decisions.md. Do not create product tables yet.
```

Acceptance criteria:
- see "Done when" above and the Definition of Done

---

## TASK 012B — Baseline Schema and Universal RLS

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 012A · 🆕 **Added in v1.1**  
> **Brain docs:** security.md, api_contract.md, pdr.md, data_model.md · **Microtasks:** —  
> **Done when:** Baseline tables with default-deny RLS; pgTAP harness green

Prompt:

```text
Create the baseline relational schema for the entities that Brain/data_model.md marks CONFIRMED:
users/auth identity, profiles, recipes and Indian food catalog, cooking multipliers, health observations, food logs, workouts, sleep/recovery, habits, medications, family health relationships, entitlements, push tokens, storage assets, audit/deletion operations.

Rules:
- do NOT infer columns the documentation does not define; record needed extras as PROPOSED
- RLS enabled and default-deny on every exposed table
- private storage buckets for sensitive media
- foundation for the delete_user_data cascade (every user-owned table carries an ownership key)

Add the pgTAP harness and first isolation tests (user A cannot read user B; anon denied).
```

Acceptance criteria:
- see "Done when" above and the Definition of Done

---

## TASK 012C — Edge Function Scaffold and API Contract Baseline

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 012A, 012B · 🆕 **Added in v1.1**  
> **Brain docs:** security.md, api_contract.md, pdr.md, api_contract.md, error_handling.md · **Microtasks:** —  
> **Done when:** Envelope, idempotency, JWT and webhook-verification helpers unit-tested

Prompt:

```text
Create the shared Supabase Edge Function (Deno/TypeScript) foundation per Brain/api_contract.md.

Implement:
- request envelope: request_id, idempotency_key, payload
- response envelope: request_id, data, warnings, error
- error envelope using FK-xxxx codes from Brain/error_handling.md
- JWT/Auth verification helper
- idempotency-key storage/replay helper
- signed-webhook verification helper (provider-agnostic)
- rate-limit bucket interface (thresholds remain OPEN DECISION)
- least-privilege credential handling

Only a health-check function is allowed in this task. All concrete routes stay PROPOSED until their feature task. Add function-level tests.
```

Acceptance criteria:
- see "Done when" above and the Definition of Done

---

# PHASE 2 — AUTHENTICATION, USER PROFILE & ONBOARDING

> **Phase gate:** Backend stack from 012A-012C is in use; phone OTP + Google sign-in, profile and onboarding work end-to-end.

## TASK 013 — Supabase Client Foundation

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 003, 005, 012A  
> **Brain docs:** security.md, api_contract.md, pdr.md · **Microtasks:** —  
> **Done when:** App boots against mocks without production credentials

Prompt:

```text
Implement the client-side Supabase integration boundary according to Brain/architecture.md and Brain/trd.md.

Set up:
- client initialization
- environment configuration
- auth client access
- typed service boundary
- safe failure handling

Do not expose privileged server keys.

Add initialization tests/mocks so the app can boot without production credentials.
```

---

## TASK 014 — Phone OTP Authentication

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 013  
> **Brain docs:** security.md, api_contract.md, pdr.md · **Microtasks:** —  
> **Done when:** OTP success, invalid, timeout and resend states tested

Prompt:

```text
Implement FitKarma phone OTP authentication using Supabase Auth.

Build:
- phone entry screen
- OTP screen
- retry/timeout handling
- invalid OTP handling
- resend behavior
- loading/error states
- authenticated session persistence

Do not implement Google Sign-In yet.

Add unit/widget/integration coverage for the important auth states.
```

---

## TASK 015 — Google Sign-In

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 013, 014  
> **Brain docs:** security.md, api_contract.md, pdr.md · **Microtasks:** —  
> **Done when:** Sign-in/cancel/error/logout tested; no duplicate users

Prompt:

```text
Add Google Sign-In through the documented Supabase authentication architecture.

Implement:
- sign-in flow
- cancellation handling
- provider error handling
- session establishment
- logout

Do not duplicate user records.

Add integration-oriented tests with mocked auth boundaries.
```

---

## TASK 016 — User Profile Domain

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 013, 020  
> **Brain docs:** security.md, api_contract.md, pdr.md, data_model.md · **Microtasks:** —  
> **Done when:** Profile validated; local-first repo with sync boundary

Prompt:

```text
Implement the initial user/profile domain model and repository.

Support the documented user information needed for:
- age
- sex where required by calculations
- height
- weight
- goals
- activity level
- nutrition preferences
- language
- dietary identity
- notification preferences

Respect sensitive-data handling.

Use local-first patterns where appropriate and keep server synchronization behind the repository boundary.

Add validation tests.
```

---

## TASK 017 — Onboarding Flow

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 009, 010, 014, 016  
> **Brain docs:** security.md, api_contract.md, pdr.md, ui_spec.md · **Microtasks:** —  
> **Done when:** New user completes onboarding to main app; consent captured; e2e test passes

Prompt:

```text
Build the complete FitKarma onboarding experience from the documented product requirements.

Include:
- welcome/value proposition
- account setup
- basic profile
- fitness goal
- dietary identity/preferences
- activity baseline
- language selection
- consent/privacy explanation
- notification permissions
- health permission entry point
- optional Ayurveda/Dosha personalization flow

Do not make unsupported medical claims.

Ensure a new user can complete onboarding and reach the main app.
Add end-to-end onboarding tests.
```

---

## TASK 018 — Dosha/Wellness Profile Foundation

> **Roadmap:** R1 · **Priority:** P1 · **Depends on:** 017  
> **Brain docs:** security.md, api_contract.md, pdr.md · **Microtasks:** —  
> **Done when:** Documented scoring tested; skippable/revisitable; labelled wellness-only

Prompt:

```text
Implement the documented Ayurveda/Dosha feature as a separate wellness personalization layer.

Important:
- do not present Ayurveda as medical treatment
- separate traditional wellness concepts from evidence-based health measurements
- store answers and calculated profile in a testable domain service
- allow the user to skip/revisit the profile

Add deterministic tests for the scoring rules that are actually documented.
```

---

## TASK 019 — Account Lifecycle

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 014, 020  
> **Brain docs:** security.md, api_contract.md, pdr.md · **Microtasks:** —  
> **Done when:** Session transitions and local wipe tested; deletion handoff boundary exists

Prompt:

```text
Implement account lifecycle operations:

- logout
- session restoration
- account deletion request
- account recovery hooks
- local-data wipe on appropriate account removal
- safe session expiration behavior

Do not implement the full DPDP deletion backend yet; build the client boundary that will later invoke it.

Add tests for session transitions and local cleanup behavior.
```

---

# PHASE 3 — OFFLINE-FIRST DATA FOUNDATION

> **Phase gate:** Encrypted Drift DB, outbox, sync state machine, Realtime and conflict UX proven by offline/restart tests; no data loss on network failure.

## TASK 020 — Drift + SQLCipher Local Database

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 004, 012B  
> **Brain docs:** architecture.md, data_model.md, error_handling.md, decisions.md · **Microtasks:** —  
> **Done when:** Encrypted DB opens; migration tests pass; key lifecycle documented

Prompt:

```text
Implement the local persistence foundation using Drift + SQLCipher as documented.

Establish:
- encrypted local database
- schema/version migration framework
- repository access boundary
- test database configuration
- local transaction support

Do not build every table yet.

Create the minimum foundation tables required by the app shell and profile flow.

Add migration tests and encrypted-store initialization tests where supported.
```

---

## TASK 021 — Offline Outbox

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 020  
> **Brain docs:** architecture.md, data_model.md, error_handling.md · **Microtasks:** —  
> **Done when:** Enqueue/retry/success/permanent-failure/duplicate-key tests pass

Prompt:

```text
Implement the generic offline outbox/sync queue foundation.

Support:
- operation ID
- entity type
- operation type
- payload
- created timestamp
- retry count
- status
- last error
- idempotency key
- dependency/reference metadata where necessary

Build retry-safe behavior.

Do not connect every feature yet.

Add unit tests for enqueue, retry, success, permanent failure, and duplicate idempotency cases.
```

---

## TASK 022 — Sync State Machine

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 021  
> **Brain docs:** architecture.md, data_model.md, error_handling.md · **Microtasks:** —  
> **Done when:** Deterministic idle→syncing→synced/error/conflict tests

Prompt:

```text
Implement the documented sync state machine:

idle
→ syncing
→ synced
or
→ error
or
→ conflict

Build:
- sync coordinator
- connectivity awareness
- exponential retry/backoff
- cancellation support
- safe restart after interruption
- sync status exposed through Riverpod

Add deterministic tests for state transitions.
```

---

## TASK 023 — Supabase Sync Repository Pattern

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 012B, 021, 022  
> **Brain docs:** architecture.md, data_model.md, error_handling.md, decisions.md · **Microtasks:** —  
> **Done when:** Generic sync repo works; conflict model recorded PROPOSED

Prompt:

```text
Create the reusable repository synchronization pattern between Drift and Supabase.

Define:
- local source of truth
- remote fetch
- local merge
- outbox push
- server acknowledgement
- duplicate handling
- timestamp/version conflict strategy

Where the exact conflict model is not defined, document it as PROPOSED in Brain/decisions.md rather than pretending it was predetermined.

Implement the framework, not every feature.
```

---

## TASK 023A — Supabase Realtime Integration

> **Roadmap:** R1 · **Priority:** P1 · **Depends on:** 023 · 🆕 **Added in v1.1**  
> **Brain docs:** architecture.md, data_model.md, error_handling.md · **Microtasks:** —  
> **Done when:** Realtime updates merge without duplication; reconnect tested

Prompt:

```text
Feed Supabase Realtime changes into the sync engine.

Requirements:
- subscriptions respect RLS and the user's consent scope
- changes merge through the same repository pattern as pulled data
- no duplicate application of events already acknowledged via the outbox
- reconnect/backoff and graceful degradation to polling/manual sync
- Realtime is an optimization; the app must remain correct without it

Add tests for duplicate, reordered and dropped events.
```

Acceptance criteria:
- see "Done when" above and the Definition of Done

---

## TASK 024 — Offline Mode UX

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 022  
> **Brain docs:** architecture.md, data_model.md, error_handling.md, ui_spec.md · **Microtasks:** —  
> **Done when:** Offline indicator and pending count widget-tested

Prompt:

```text
Implement global offline UX.

Show:
- current connectivity state
- pending sync count/status
- unobtrusive offline indicator
- retry action
- sync failure explanation

Ensure the core app remains usable without network access wherever documented as offline-first.

Add widget tests.
```

---

## TASK 024A — Conflict Resolution UX

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 023, 024 · 🆕 **Added in v1.1**  
> **Brain docs:** architecture.md, data_model.md, error_handling.md, ui_spec.md, error_handling.md · **Microtasks:** —  
> **Done when:** Conflicts surfaced, never silently overwritten; resolution paths tested

Prompt:

```text
Implement user-facing conflict handling (error code FK-3003).

Requirements:
- never silently overwrite material user changes
- per-entity conflict strategy recorded as PROPOSED in Brain/decisions.md
- visible pending / synced / conflict states
- clear, non-blaming resolution actions (keep mine / keep server / merge where safe)
- localized messages

Add widget and sync tests for conflict creation and resolution.
```

Acceptance criteria:
- see "Done when" above and the Definition of Done

---

# PHASE 4 — HEALTH DATA CORE

> **Phase gate:** All core health logs (weight, steps, sleep, mood, water, medication, measurements, habits, BP/glucose) work offline and sync.

## TASK 025 — Core Health Domain

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 020  
> **Brain docs:** data_model.md, trd.md · **Microtasks:** HEALTH-001  
> **Done when:** Normalized health types round-trip serialization

Prompt:

```text
Implement the shared health-domain primitives needed by FitKarma.

Create normalized domain types for:
- timestamp
- quantity
- units
- source
- confidence
- measurement metadata

Prepare the architecture for:
- steps
- heart rate
- HRV
- sleep
- weight
- blood pressure
- glucose/CGM

Do not create unsupported provider-specific assumptions.
Add serialization and normalization tests.
```

---

## TASK 026 — Weight Logging

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 023, 025  
> **Brain docs:** data_model.md, trd.md · **Microtasks:** —  
> **Done when:** Offline CRUD + trend + sync tested

Prompt:

```text
Implement weight logging end-to-end.

Support:
- local-first entry
- unit normalization
- timestamp
- edit/delete
- history
- basic trend presentation
- synchronization

Add validation, duplicate protection, offline tests, widget tests, and repository tests.
```

---

## TASK 027 — Step Logging

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 025  
> **Brain docs:** data_model.md, trd.md · **Microtasks:** HEALTH-001  
> **Done when:** Repository interfaces ready for Health Connect/Apple Health

Prompt:

```text
Implement step tracking domain and UI.

Support:
- daily total
- historical days
- source attribution
- manual fallback where documented
- local cache
- synchronization

Do not yet implement Health Connect or Apple Health provider code; create the domain/repository interfaces needed for later integrations.
```

---

## TASK 028 — Sleep Logging

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 023, 025  
> **Brain docs:** data_model.md, trd.md · **Microtasks:** —  
> **Done when:** Overnight and timezone tests pass

Prompt:

```text
Implement the sleep logging domain and UI.

Support documented sleep fields and source attribution.

Include:
- nightly record
- duration
- stages where available
- quality/readiness inputs where defined
- local-first storage
- edit/delete
- sync

Add tests for overnight boundaries and time zones.
```

---

## TASK 029 — Mood Logging

> **Roadmap:** R1 · **Priority:** P1 · **Depends on:** 023  
> **Brain docs:** data_model.md, trd.md, security.md · **Microtasks:** —  
> **Done when:** Mood CRUD offline; notes treated as sensitive

Prompt:

```text
Implement mood logging from the documented product model.

Support:
- mood selection
- optional notes
- timestamp
- history
- local-first behavior
- synchronization
- deletion

Treat notes as potentially sensitive.

Add tests.
```

---

## TASK 030 — Water Logging

> **Roadmap:** R1 · **Priority:** P1 · **Depends on:** 023  
> **Brain docs:** data_model.md, trd.md · **Microtasks:** —  
> **Done when:** Quick add and goal progress tested offline

Prompt:

```text
Implement water tracking.

Support:
- quick add
- custom amount
- daily total
- goal
- history
- offline use
- sync

Use localized units and reusable UI components.
Add widget and domain tests.
```

---

## TASK 031 — Medication Logging

> **Roadmap:** R1 · **Priority:** P1 · **Depends on:** 023  
> **Brain docs:** data_model.md, trd.md, security.md · **Microtasks:** —  
> **Done when:** Encrypted, access-controlled, reminder interface; no medical advice

Prompt:

```text
Implement the medication logging foundation.

Support the fields defined by the documentation, including schedule/status data where specified.

Treat medication data as sensitive.

Implement:
- local encryption
- access control boundary
- reminders interface
- history
- deletion
- sync

Do not make medical recommendations.
Add tests.
```

---

## TASK 032 — Body Measurements

> **Roadmap:** R1 · **Priority:** P1 · **Depends on:** 023  
> **Brain docs:** data_model.md, trd.md · **Microtasks:** —  
> **Done when:** Measurements normalized; history and edit/delete tested

Prompt:

```text
Implement body measurements.

Support documented measurements such as:
- waist
- hip
- chest
- arm
- thigh
- body-fat estimate if documented

Normalize units and timestamps.

Build history and edit/delete.

Add tests and keep calculations deterministic.
```

---

## TASK 032A — Habit Tracking

> **Roadmap:** R1 · **Priority:** P1 · **Depends on:** 023, 086 · 🆕 **Added in v1.1**  
> **Brain docs:** data_model.md, trd.md · **Microtasks:** —  
> **Done when:** Habits CRUD/check-ins offline; streaks non-spammy

Prompt:

```text
Implement habit tracking from the documented habits entity.

Support: create/edit/archive habits, daily check-ins, streaks, reminders through the notification interface, history, local-first save and sync.

Do not create addictive or spammy loops. Add domain, offline and widget tests.
```

Acceptance criteria:
- see "Done when" above and the Definition of Done

---

## TASK 032B — Blood Pressure and Manual Glucose Logging

> **Roadmap:** R1 · **Priority:** P1 · **Depends on:** 025, 023 · 🆕 **Added in v1.1**  
> **Brain docs:** data_model.md, trd.md, security.md · **Microtasks:** —  
> **Done when:** BP/glucose manual entries sensitive, attributed, uninterpreted

Prompt:

```text
Implement manual blood pressure and glucose entry as the domain prerequisite for family sharing and later CGM.

Requirements:
- units, timestamps, source attribution (manual vs device)
- sensitive-data handling (encrypted locally, RLS remotely)
- no interpretation, diagnosis or medical advice
- offline-first with sync, edit/delete

Add validation, offline and deletion tests.
```

Acceptance criteria:
- see "Done when" above and the Definition of Done

---

# PHASE 5 — INDIAN NUTRITION ENGINE

> **Phase gate:** Indian food catalog, portions, raw/cooked, multipliers, Tadka, Family Recipe Splitter, manual logging and Dynamic TDEE are deterministic and tested.

## TASK 033 — Food Domain and Data Model

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 020  
> **Brain docs:** pdr.md, trd.md, data_model.md, testing.md · **Microtasks:** NUT-001  
> **Done when:** Domain models exist; seed data clearly marked

Prompt:

```text
Implement the core Indian nutrition domain.

Model:
- food item
- recipe
- ingredient
- portion
- serving
- unit
- raw/cooked state
- preparation method
- nutrition values
- source/provenance
- confidence where relevant

Support Indian examples such as:
roti, chapati, paratha, rice, dal, rajma, chole, sabzi, poha, upma, idli, dosa, sambar, regional foods, street foods, sweets, festival foods, restaurant foods, and homemade meals.

Do not fabricate authoritative nutritional data.

Use seeded/mock data only where the actual dataset is not yet connected, clearly marked as seed/test data.
```

---

## TASK 033A — Indian Food Catalog Seed Pipeline and Local Cache

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 033, 012B · 🆕 **Added in v1.1**  
> **Brain docs:** pdr.md, trd.md, data_model.md, testing.md, data_sources.md · **Microtasks:** NUT-001  
> **Done when:** Versioned catalog cached locally with provenance; coverage report produced

Prompt:

```text
Build the pipeline that loads the Indian food catalog into the local database.

Goals (per master documentation): 500+ seeded regional recipes, street food, festival adaptations, vegetarian protein optimization, cooking-yield multipliers and Indian portion units.

Requirements:
- follow Brain/data_sources.md source priority: official APIs, licensed datasets, open datasets, permitted scraping
- keep provenance, attribution, version and review status on every record
- versioned catalog with delta updates; cached locally in Drift
- never fabricate nutrition values; use clearly marked seed/test data until approved sources are connected
- produce a coverage report (cuisines, categories, missing nutrients)

Add import, versioning and cache tests.
```

Acceptance criteria:
- see "Done when" above and the Definition of Done

---

## TASK 034 — Indian Portion System

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 033  
> **Brain docs:** pdr.md, trd.md, data_model.md, testing.md · **Microtasks:** NUT-001  
> **Done when:** Household units converted deterministically; unsafe ones PROPOSED

Prompt:

```text
Implement the Indian portion-sizing system.

Support:
- katori
- glass
- spoon
- piece
- serving
- roti count
- idli count
- percentage portion

Create deterministic conversion rules where documentation provides them.

Where a conversion cannot be established safely, mark it PROPOSED and require confirmation.

Add extensive unit tests.
```

---

## TASK 035 — Raw vs Cooked Nutrition

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 034  
> **Brain docs:** pdr.md, trd.md, data_model.md, testing.md · **Microtasks:** NUT-002  
> **Done when:** Raw vs cooked never conflated; assumptions labelled

Prompt:

```text
Implement raw-vs-cooked food handling.

The system must distinguish:
- raw
- cooked
- preparation method
- cooking multiplier
- water absorption
- evaporation

Do not assume 100g raw equals 100g cooked.

Implement the data model, nutrition calculation service, UI selection, and tests.

All assumptions that are not explicitly documented must be identified as PROPOSED.
```

---

## TASK 036 — Cooking Multipliers

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 035  
> **Brain docs:** pdr.md, trd.md, data_model.md, testing.md · **Microtasks:** NUT-002  
> **Done when:** Versioned multipliers keep old logs reproducible

Prompt:

```text
Implement the cooking multiplier engine.

Support:
- raw quantity
- cooked yield
- preparation method
- multiplier/version
- provenance
- deterministic nutrition calculation

Ensure historical logs remain reproducible when a multiplier changes by versioning the applicable calculation input.

Add property/unit tests for representative foods.
```

---

## TASK 037 — Tadka / Tempering Slider

> **Roadmap:** R2 · **Priority:** P0 · **Depends on:** 036  
> **Brain docs:** pdr.md, trd.md, data_model.md, testing.md · **Microtasks:** NUT-003  
> **Done when:** Low/Medium/High estimates labelled as estimates; tested

Prompt:

```text
Implement the Tadka / Tempering Slider.

Levels:
- Low
- Medium
- High

Estimate:
- oil
- ghee
- butter
- tempering fat

The UI must explicitly communicate that the value is an estimate, not an exact measurement.

Implement:
- data model
- calculator
- UI
- storage
- sync representation
- tests
```

---

## TASK 038 — Family Recipe Splitter Nutrition Engine

> **Roadmap:** R2 · **Priority:** P0 · **Depends on:** 036  
> **Brain docs:** pdr.md, trd.md, data_model.md, testing.md · **Microtasks:** NUT-004  
> **Done when:** 0/25/50/100% and invalid cases pass offline; sync idempotent

Prompt:

```text
Implement the Family Recipe Splitter.

Example:
- family raw/cooked recipe
- total ingredient quantities
- total nutrition
- user selects "I ate 25%"

Support percentage-based personal consumption.

Ensure:
- recipe total remains distinct from user portion
- nutrition calculations are deterministic
- offline creation works
- synchronization is idempotent
- edits recalculate safely
- tests cover 0%, 25%, 50%, 100%, invalid percentages, and ingredient changes
```

---

## TASK 039 — Food Search

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 033A, 034  
> **Brain docs:** pdr.md, trd.md, data_model.md, testing.md · **Microtasks:** —  
> **Done when:** Local search covers aliases/transliteration; perf check passes

Prompt:

```text
Implement fast Indian food search.

Support:
- common names
- aliases
- regional names
- bilingual search
- transliterated terms where practical
- category filters
- portion presets

The feature must work against the local cached food dataset.

Add search tests and performance checks for the local data path.
```

---

## TASK 039A — Semantic Recipe Search with pgvector (PROPOSED)

> **Roadmap:** R3 · **Priority:** P2 · **Depends on:** 039 · 🆕 **Added in v1.1**  
> **Brain docs:** pdr.md, trd.md, data_model.md, testing.md, decisions.md · **Microtasks:** —  
> **Done when:** ADR approved; online semantic search falls back to 039

Prompt:

```text
Optional enhancement. Requires an ADR in Brain/decisions.md before implementation.

If approved: use pgvector recipe embeddings for online semantic search/suggestions, always falling back to the local search from TASK 039 when offline. Embeddings must not contain user health data.

Add tests for fallback and relevance fixtures.
```

Acceptance criteria:
- see "Done when" above and the Definition of Done

---

## TASK 040 — Manual Food Logging

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 023, 034, 035, 036, 039  
> **Brain docs:** pdr.md, trd.md, data_model.md, testing.md · **Microtasks:** NUT-001, NUT-002  
> **Done when:** Full manual log flow works offline and updates totals

Prompt:

```text
Implement complete manual food logging.

Flow:
Select food
→ choose portion
→ choose raw/cooked state where applicable
→ choose preparation
→ choose Tadka level when applicable
→ confirm
→ save locally
→ sync
→ update daily totals

Support meal categories and edit/delete.

This must be usable offline.

Add unit, widget, repository, and offline tests.
```

---

## TASK 041 — Recipe Creation

> **Roadmap:** R1 · **Priority:** P1 · **Depends on:** 040  
> **Brain docs:** pdr.md, trd.md, data_model.md, testing.md · **Microtasks:** —  
> **Done when:** Recipes validated; family-size recipe reusable

Prompt:

```text
Implement homemade recipe creation.

Support:
- recipe name
- ingredients
- quantities
- raw/cooked semantics
- cooking method
- serving count
- estimated nutrition
- favorite/reuse
- edit/delete

Support a family-sized recipe that can later use Family Recipe Splitter.

Add validation and deterministic calculation tests.
```

---

## TASK 042 — Nutrition Goals

> **Roadmap:** R1 · **Priority:** P1 · **Depends on:** 040  
> **Brain docs:** pdr.md, trd.md, data_model.md, testing.md · **Microtasks:** —  
> **Done when:** Goals user-overridable; no prescriptions

Prompt:

```text
Implement user nutrition goals.

Support:
- calorie goal where documented
- protein goal
- carbohydrate/fat tracking
- water goal
- user override
- daily progress

Do not introduce unsupported medical or nutritional prescriptions.

Goals must integrate with the local-first data architecture.
```

---

## TASK 043 — Dynamic TDEE Engine

> **Roadmap:** R2 · **Priority:** P0 · **Depends on:** 026, 027, 040, 042  
> **Brain docs:** pdr.md, trd.md, data_model.md, testing.md, decisions.md · **Microtasks:** TDEE-001  
> **Done when:** Algorithm approved in ADR; estimate+confidence+override time-series tests pass

Prompt:

```text
Implement the Dynamic TDEE foundation.

Inputs:
- body weight
- weight trend
- calorie intake
- activity
- steps
- workouts
- goal
- historical data

Define a deterministic algorithm based only on documented requirements.

The algorithm must provide:
- estimate
- confidence/quality indicator
- adjustment rules
- user override

If the exact formula is not defined in the documentation, first record the proposed algorithm in Brain/decisions.md before implementing it.

Add extensive time-series tests.
```

---

## TASK 044 — Nutrition Dashboard

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 040, 042  
> **Brain docs:** pdr.md, trd.md, data_model.md, testing.md · **Microtasks:** —  
> **Done when:** Overview shows today's data; ready for DIP card selection

Prompt:

```text
Build the nutrition overview screen.

Show:
- calories
- protein
- macro progress
- water relation where relevant
- today's meals
- missing/low-confidence logging signals
- quick add actions

Do not overload the screen with every health feature.

Design it so the Daily Intelligence Package can later select contextual cards.
```

---

# PHASE 6 — WORKOUT & FITNESS CORE

> **Phase gate:** Workout model, library, planner, logging and recovery basics work offline.

## TASK 045 — Workout Data Model

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 020  
> **Brain docs:** pdr.md, data_model.md · **Microtasks:** —  
> **Done when:** Workout entities reusable and tested

Prompt:

```text
Implement the workout domain.

Support documented entities for:
- workout
- exercise
- session
- duration
- intensity
- calories if available
- source
- completion state
- notes

Use normalized reusable exercise definitions.

Add tests.
```

---

## TASK 046 — Workout Library

> **Roadmap:** R1 · **Priority:** P1 · **Depends on:** 045  
> **Brain docs:** pdr.md, data_model.md · **Microtasks:** —  
> **Done when:** Library works from seed data marked as such

Prompt:

```text
Implement the initial workout library architecture.

Support:
- categories
- equipment
- difficulty
- duration
- home workout suitability
- muscle focus where documented
- localization-ready exercise names

Do not build a giant proprietary video library.

Use seed/test content clearly marked as such.
```

---

## TASK 047 — Workout Planner

> **Roadmap:** R1 · **Priority:** P1 · **Depends on:** 046  
> **Brain docs:** pdr.md, data_model.md · **Microtasks:** —  
> **Done when:** Plans stored offline; no pose estimation

Prompt:

```text
Implement workout planning.

Support:
- create/select workout
- schedule
- goals
- completion
- rest/recovery considerations
- home-friendly filtering
- history

Integrate with offline-first storage.

Do not implement pose estimation.
```

---

## TASK 048 — Workout Logging

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 023, 045  
> **Brain docs:** pdr.md, data_model.md · **Microtasks:** —  
> **Done when:** Interrupted/offline sessions tested

Prompt:

```text
Implement workout session logging end-to-end.

Support:
- start
- pause/resume where appropriate
- finish
- duration
- perceived exertion where documented
- completion
- history
- local-first save
- sync

Add tests for interrupted sessions and offline completion.
```

---

## TASK 049 — Recovery Basics

> **Roadmap:** R2 · **Priority:** P1 · **Depends on:** 025, 028, 048  
> **Brain docs:** pdr.md, data_model.md · **Microtasks:** —  
> **Done when:** Recovery model uses documented inputs; handles missing data

Prompt:

```text
Implement the initial recovery/readiness domain.

Use only documented inputs.

Prepare:
- recovery score model
- readiness factors
- daily summary
- confidence/availability handling

Do not invent medical-grade claims.

Keep provider data and algorithm logic separate.
```

---

# PHASE 7 — HEALTH CONNECT & APPLE HEALTH

> **Phase gate:** Health Connect + Apple Health import normalized, de-duplicated, source-attributed data with revocation and background-sync limits respected.

## TASK 050 — Health Integration Abstraction

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 023, 025  
> **Brain docs:** data_sources.md, architecture.md, trd.md, data_model.md · **Microtasks:** HEALTH-001, HEALTH-002  
> **Done when:** Adapter interfaces defined; no vendor-specific leakage

Prompt:

```text
Implement the platform health integration abstraction.

Define interfaces for:
- permissions
- fetch
- incremental sync
- source attribution
- normalization
- background sync
- conflict handling
- deletion

Create separate adapter boundaries for:
- Android Health Connect
- iOS Apple Health / HealthKit

Do not implement direct Garmin/Fitbit integrations yet.
```

---

## TASK 051 — Android Health Connect

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 050  
> **Brain docs:** data_sources.md, architecture.md, trd.md · **Microtasks:** HEALTH-001  
> **Done when:** Import, increment, dedupe, revoke tested with mocks

Prompt:

```text
Implement Android Health Connect integration for the documented P0 health data.

Start with the highest-value data types supported by the documentation, such as steps, sleep, heart rate/HRV, and weight where appropriate.

Implement:
- permission request
- permission state
- initial import
- incremental import
- duplicate protection
- source attribution
- local normalization
- error handling
- revocation behavior

Add Android-specific tests/mocks and document unsupported data types.
```

---

## TASK 052 — iOS Apple Health / HealthKit

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 050  
> **Brain docs:** data_sources.md, architecture.md, trd.md · **Microtasks:** HEALTH-002  
> **Done when:** iOS mirrors normalized model; tests/mocks pass

Prompt:

```text
Implement iOS Apple Health / HealthKit integration for the documented P0 health data.

Mirror the normalized domain model used by Health Connect without leaking platform-specific details into the domain layer.

Implement:
- permission flow
- initial import
- incremental sync
- source attribution
- duplicate handling
- revocation
- error states

Add iOS-specific tests/mocks where feasible.
```

---

## TASK 053 — Health Background Sync

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 051, 052  
> **Brain docs:** data_sources.md, architecture.md, trd.md · **Microtasks:** —  
> **Done when:** Background sync respects OS limits; failures observable

Prompt:

```text
Implement safe background health synchronization.

Support:
- platform scheduling constraints
- incremental windows
- local caching
- outbox/sync integration
- battery-conscious behavior
- retry handling

Do not assume unlimited background execution on either platform.

Add observability for failed sync jobs.
```

---

# PHASE 8 — DAILY INTELLIGENCE PACKAGE / HEALTH OS BRAIN

> **Phase gate:** Deterministic DIP contract + rule engine drive a contextual home; no screen shows every module.

## TASK 054 — DIP Domain Contract

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 025, 044  
> **Brain docs:** ui_spec.md, pdr.md · **Microtasks:** —  
> **Done when:** Deterministic typed DIP input/output tested

Prompt:

```text
Implement the Daily Intelligence Package (DIP) domain contract.

The DIP should be the central contextual layer that decides which useful insights/actions the user needs today.

Define structured inputs and outputs for:
- nutrition
- activity
- sleep
- recovery
- hydration
- goals
- adherence
- relevant alerts
- contextual actions

Do not implement LLM generation yet.

The output must be deterministic and testable.
```

---

## TASK 055 — DIP Rule Engine

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 054  
> **Brain docs:** ui_spec.md, pdr.md · **Microtasks:** —  
> **Done when:** Rules fire only with sufficient data; rule-level tests pass

Prompt:

```text
Implement the first deterministic DIP rule engine.

Prioritize useful, low-risk micro-actions.

Examples from the strategy:
- hydration prompt
- meal logging reminder when appropriate
- step micro-action
- indoor workout suggestion when contextually relevant

Do not make unsupported clinical claims.

Add rule-level tests and avoid generating alerts when necessary data is missing.
```

---

## TASK 056 — Contextual Dashboard Assembly

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 055  
> **Brain docs:** ui_spec.md, pdr.md · **Microtasks:** —  
> **Done when:** Contextual dashboard scenarios widget-tested

Prompt:

```text
Build the FitKarma home dashboard around the DIP.

Do not place every feature on one screen.

Use contextual sections for:
- today's readiness/health summary
- recommended micro-action
- meals
- activity
- sleep/recovery
- quick logging
- relevant goal progress

The dashboard should change based on available data and user needs.

Add widget tests for several contextual scenarios.
```

---

## TASK 057 — Daily Readiness Score

> **Roadmap:** R2 · **Priority:** P1 · **Depends on:** 049, 055  
> **Brain docs:** ui_spec.md, pdr.md · **Microtasks:** —  
> **Done when:** Score explained; missing data handled; non-diagnostic

Prompt:

```text
Implement the documented Daily Readiness concept.

Only use validated/documented inputs.

Support:
- score
- contributing factors
- missing-data handling
- user-friendly explanation
- trend where supported

Clearly distinguish wellness/readiness scoring from medical diagnosis.

Add deterministic tests.
```

---

# PHASE 9 — AI FOUNDATION

> **Phase gate:** Server-side AI gateway, validated schemas, meal analyzer, Hinglish layer, photo logging and safety guardrails pass AI test fixtures; client never calls providers.

## TASK 058 — Server-Side AI Gateway

> **Roadmap:** R2 · **Priority:** P0 · **Depends on:** 012C  
> **Brain docs:** architecture.md, api_contract.md, security.md, api_contract.md · **Microtasks:** —  
> **Done when:** Gateway routes/validates/limits AI; client never calls providers

Prompt:

```text
Implement the server-side AI gateway architecture using Supabase Edge Functions.

Create a safe abstraction for:
- prompt/task routing
- provider selection
- structured output
- timeout
- retry policy
- rate limiting
- audit metadata
- PII minimization

Do not call AI providers directly from the Flutter client.

Keep provider-specific implementation isolated.
```

---

## TASK 059 — AI Structured Output Contracts

> **Roadmap:** R2 · **Priority:** P0 · **Depends on:** 058  
> **Brain docs:** architecture.md, api_contract.md, security.md · **Microtasks:** AI-001  
> **Done when:** Malformed/ambiguous/adversarial outputs handled safely

Prompt:

```text
Define and implement validated structured AI output schemas for FitKarma nutrition/coaching tasks.

Require:
- schema validation
- confidence/uncertainty fields where appropriate
- safe fallback
- no unsupported medical claims
- deterministic post-processing

Add tests for malformed, incomplete, ambiguous, and adversarial model output.
```

---

## TASK 060 — AI Meal Analyzer

> **Roadmap:** R2 · **Priority:** P0 · **Depends on:** 033A, 059  
> **Brain docs:** architecture.md, api_contract.md, security.md · **Microtasks:** AI-001, AI-003  
> **Done when:** Output normalized to DB; confirmation required before commit

Prompt:

```text
Implement the AI Meal Analyzer described in the documentation.

Input:
- user meal text or structured meal context

Output:
- identified foods
- likely portions
- nutrition interpretation
- uncertainty
- contextual coaching insight

Normalize the output against the Indian food database.

Never let raw model output become the authoritative nutrition record without validation/confirmation.

Add mocked AI tests.
```

---

## TASK 061 — Hinglish Coaching Layer

> **Roadmap:** R2 · **Priority:** P0 · **Depends on:** 010, 059  
> **Brain docs:** architecture.md, api_contract.md, security.md · **Microtasks:** —  
> **Done when:** Natural Hinglish; separated from business logic

Prompt:

```text
Implement the FitKarma conversational coaching layer for Hinglish.

Examples should feel natural rather than formal Hindi.

Keep:
- language preferences
- culturally appropriate phrasing
- respectful tone
- no unsupported medical claims
- user-editable notification preferences

Separate language generation from business logic.
```

---

## TASK 062 — AI Photo Food Logging

> **Roadmap:** R2 · **Priority:** P1 · **Depends on:** 060, 063A  
> **Brain docs:** architecture.md, api_contract.md, security.md · **Microtasks:** AI-004  
> **Done when:** Confirmation, retention, deletion and manual fallback tested

Prompt:

```text
Implement AI photo food logging as the P1 nutrition experience.

Flow:
photo
→ upload
→ image analysis
→ Indian dish recognition
→ portion estimation
→ nutrition estimation
→ uncertainty
→ user confirmation
→ food log

Requirements:
- clear privacy messaging
- image retention policy from documentation
- deletion behavior
- failure fallback to manual logging
- no claim of perfect recognition

Add mocked vision tests and UI tests.
```

---

## TASK 063 — AI Safety and Medical Boundary

> **Roadmap:** R2 · **Priority:** P0 · **Depends on:** 059  
> **Brain docs:** architecture.md, api_contract.md, security.md · **Microtasks:** —  
> **Done when:** Prohibited-output tests pass

Prompt:

```text
Implement AI safety guardrails.

Ensure AI cannot:
- diagnose disease
- claim Ayurveda cures disease
- present uncertain nutrition values as exact
- give unsafe medical instructions
- override clinician guidance

Route health-sensitive requests to safe fallback wording where required.

Add tests for prohibited/unsafe output patterns.
```

---

## TASK 063A — AI and WhatsApp Media Retention and Deletion

> **Roadmap:** R2 · **Priority:** P0 · **Depends on:** 058, 063 · 🆕 **Added in v1.1**  
> **Brain docs:** architecture.md, api_contract.md, security.md, security.md · **Microtasks:** AI-004  
> **Done when:** Retention windows (OPEN DECISION) enforced by purge job; deletion hooks tested

Prompt:

```text
Implement the retention and deletion policy for AI/WhatsApp audio, images and prompts.

Requirements:
- retention windows are OPEN DECISION; record a PROPOSED default in Brain/decisions.md
- scheduled purge job and immediate deletion on user request
- bounded ai_interactions / whatsapp_interactions observability without raw health content in general logs
- deletion hooks wired to the right-to-erasure cascade
- PII-scrubbed monitoring

Add purge, deletion and no-raw-content-in-logs tests.
```

Acceptance criteria:
- see "Done when" above and the Definition of Done

---

# PHASE 10 — WHATSAPP AI LOGGING

> **Phase gate:** WhatsApp text/voice logging with linking, confirmation and coaching replies is idempotent and consent-gated.

## TASK 064 — WhatsApp Integration Contract

> **Roadmap:** R2 · **Priority:** P0 · **Depends on:** 058  
> **Brain docs:** architecture.md, api_contract.md, security.md · **Microtasks:** AI-002  
> **Done when:** Webhook verification + idempotent inbound model; no Meta secrets in client

Prompt:

```text
Implement the FitKarma WhatsApp integration boundary using the documented Meta WhatsApp Business Cloud API architecture.

Define:
- webhook verification interface
- inbound message model
- text/voice/media message handling
- user association
- message idempotency
- processing states
- reply interface

Do not expose Meta credentials in Flutter.
```

---

## TASK 064A — WhatsApp Account Linking and Consent

> **Roadmap:** R2 · **Priority:** P0 · **Depends on:** 064, 014 · 🆕 **Added in v1.1**  
> **Brain docs:** architecture.md, api_contract.md, security.md · **Microtasks:** —  
> **Done when:** Phone-ownership linking, opt-in/opt-out and unlink tested

Prompt:

```text
Implement secure linking between a WhatsApp number and a FitKarma account.

Requirements:
- verify phone ownership before linking
- explicit opt-in for WhatsApp logging; opt-out/STOP and unlink at any time
- handle unknown or unlinked numbers safely (no data disclosure)
- per-user message rate limiting hooks
- store only minimal message-correlation/consent metadata

Add tests for spoofed numbers, relinking, opt-out and duplicate events.
```

Acceptance criteria:
- see "Done when" above and the Definition of Done

---

## TASK 065 — WhatsApp Text Logging

> **Roadmap:** R2 · **Priority:** P0 · **Depends on:** 060, 064A  
> **Brain docs:** architecture.md, api_contract.md, security.md · **Microtasks:** AI-001  
> **Done when:** Duplicate-safe text pipeline end to end

Prompt:

```text
Implement WhatsApp text meal logging.

Example:
"Bhai aaj subah 2 parathe aur dahi khaya."

Pipeline:
WhatsApp
→ text processing
→ language detection
→ AI extraction
→ Indian food lookup
→ portion estimation
→ nutrition calculation
→ user confirmation
→ food log
→ DIP update

Ensure duplicate webhook/message handling.
```

---

## TASK 066 — WhatsApp Voice Logging

> **Roadmap:** R2 · **Priority:** P0 · **Depends on:** 065  
> **Brain docs:** architecture.md, api_contract.md, security.md · **Microtasks:** AI-002  
> **Done when:** Voice pipeline with fallbacks tested; Hinglish P0, Hindi P1, Tamil/Telugu P2

Prompt:

```text
Implement WhatsApp voice-note meal logging.

Pipeline:
voice note
→ audio retrieval
→ speech-to-text
→ language detection
→ AI extraction
→ Indian food matching
→ portion estimation
→ confirmation
→ food log
→ DIP

Support the documented language direction and priority:
- Hinglish (P0)
- Hindi (P1)
- Tamil / Telugu (P2, behind a feature flag; do not block P0 on them)

Build graceful fallbacks for:
- failed transcription
- unsupported audio
- ambiguous food
- low confidence
- provider timeout
```

---

## TASK 067 — WhatsApp User Confirmation

> **Roadmap:** R2 · **Priority:** P0 · **Depends on:** 065  
> **Brain docs:** architecture.md, api_contract.md, security.md · **Microtasks:** AI-003  
> **Done when:** Confirm/correct/cancel idempotent; late replies tested

Prompt:

```text
Implement confirmation workflows for WhatsApp-generated food logs.

Users must be able to:
- confirm
- correct food
- correct portion
- cancel

Ensure confirmations are tied to the correct message/session and are idempotent.

Add tests for duplicate and delayed responses.
```

---

## TASK 068 — WhatsApp Coaching Reply

> **Roadmap:** R2 · **Priority:** P1 · **Depends on:** 067, 086  
> **Brain docs:** architecture.md, api_contract.md, security.md · **Microtasks:** —  
> **Done when:** Replies respect quiet periods, fasting, language; templates tested

Prompt:

```text
Implement the personalized WhatsApp response layer.

After confirmed logging, return a concise helpful insight based on the DIP/meal analysis.

Do not send spammy messages.

Honor:
- notification preferences
- quiet periods
- fasting mode
- user language
- confidence limitations

Add message-template tests.
```

---

# PHASE 11 — FESTIVALS, FASTING, AQI & INDIA-FIRST UX

> **Phase gate:** Fasting, AQI and festival context are opt-in, never infer religion, and degrade gracefully.

## TASK 069 — Fasting Mode

> **Roadmap:** R2 · **Priority:** P1 · **Depends on:** 086  
> **Brain docs:** pdr.md, data_sources.md, ui_spec.md · **Microtasks:** —  
> **Done when:** Explicit opt-in; no inference; timezone tests pass

Prompt:

```text
Implement optional user-selected fasting modes.

Initial supported examples:
- Navratri
- Ramzan
- Karwa Chauth
- custom fasting periods

Requirements:
- user explicitly opts in
- never infer religion
- adapt meal reminders
- adapt hydration reminders
- adapt meal timing guidance
- suppress irrelevant "you haven't eaten" messaging

Add schedule/time-zone tests.
```

---

## TASK 070 — AQI-Aware Workout Recommendations

> **Roadmap:** R3 · **Priority:** P2 · **Depends on:** 055  
> **Brain docs:** pdr.md, data_sources.md, ui_spec.md, data_sources.md · **Microtasks:** —  
> **Done when:** Cached/offline/no-location states tested

Prompt:

```text
Implement optional AQI-aware workout recommendations.

Requirements:
- documented AQI source abstraction
- location permission handling
- cache
- thresholds
- privacy-conscious location use
- indoor-workout fallback recommendation

Do not make AQI claims beyond the configured source values.

Add tests for cached/offline/missing-location states.
```

---

## TASK 071 — Indian Festival Context

> **Roadmap:** R3 · **Priority:** P2 · **Depends on:** 069  
> **Brain docs:** pdr.md, data_sources.md, ui_spec.md · **Microtasks:** —  
> **Done when:** Replaceable calendar source; no assumptions about user

Prompt:

```text
Implement the festival-context architecture.

Support:
- festival calendar data source
- optional user participation
- food recommendations/context
- fasting relationship
- culturally appropriate content

Do not assume a user's religion, fasting participation, or dietary practice.

Keep the calendar/data source replaceable.
```

---

# PHASE 12 — WOMEN'S HEALTH

> **Phase gate:** Women's health modules are opt-in, sensitive-data protected, non-diagnostic.

## TASK 072 — Menstrual Cycle

> **Roadmap:** R3 · **Priority:** P2 · **Depends on:** 029, 025  
> **Brain docs:** security.md, data_model.md · **Microtasks:** —  
> **Done when:** Consent + privacy controls; non-diagnostic; date tests

Prompt:

```text
Implement the women's health foundation.

Support documented:
- menstrual cycle
- symptoms
- cycle history
- cycle-aware training

Treat this as sensitive health data.

Ensure user consent and privacy controls.

Do not make diagnostic claims.
Add robust date-cycle tests.
```

---

## TASK 073 — PCOS Lifestyle Tracking

> **Roadmap:** R3 · **Priority:** P2 · **Depends on:** 072  
> **Brain docs:** security.md, data_model.md · **Microtasks:** —  
> **Done when:** Sensitive visibility and deletion tested

Prompt:

```text
Implement the documented PCOS lifestyle-tracking experience.

Support:
- symptoms
- relevant lifestyle signals
- nutrition/activity correlation tracking where documented
- privacy
- data export/deletion

Do not claim FitKarma diagnoses or treats PCOS.

Add tests for sensitive-data visibility and deletion.
```

---

## TASK 074 — Menopause / Pregnancy Boundaries

> **Roadmap:** R3 · **Priority:** P2 · **Depends on:** 072  
> **Brain docs:** security.md, data_model.md, decisions.md · **Microtasks:** —  
> **Done when:** Opt-in gates only; undefined clinical logic marked OPEN DECISION

Prompt:

```text
Implement the documented architecture for menopause and pregnancy-related functionality only to the level actually specified.

Do not invent medical protocols.

Create opt-in data models and feature-gating boundaries.

Any undefined clinical behavior must be marked OPEN DECISION.
```

---

# PHASE 13 — FAMILY HEALTH

> **Phase gate:** Family groups, consent, sharing and care dashboard enforce explicit consent + instant revocation; crisis guardrails in place.

## TASK 075 — Family Groups

> **Roadmap:** R3 · **Priority:** P1 · **Depends on:** 012B  
> **Brain docs:** security.md, data_model.md, api_contract.md · **Microtasks:** FAMILY-001  
> **Done when:** Invite/accept/roles/leave tested with authorization checks

Prompt:

```text
Implement Family Group management.

Support:
- create family
- invite member
- accept/reject invite
- member roles
- leave/remove
- status
- consent state

Use explicit authorization and minimal shared data.

Add security and repository tests.
```

---

## TASK 076 — Family Consent and Permissions

> **Roadmap:** R3 · **Priority:** P1 · **Depends on:** 075  
> **Brain docs:** security.md, data_model.md, api_contract.md · **Microtasks:** FAMILY-001  
> **Done when:** Per-category consent, revocation and audit events tested

Prompt:

```text
Implement explicit family health consent and permission management.

Support:
- requested access
- accepted access
- revoked access
- role-based visibility
- per-data-category permissions where documented
- audit events

No family member should automatically see sensitive data merely because they belong to a family group.

Add authorization tests.
```

---

## TASK 077 — Family Health Data Sharing

> **Roadmap:** R3 · **Priority:** P1 · **Depends on:** 076, 032B  
> **Brain docs:** security.md, data_model.md, api_contract.md · **Microtasks:** FAMILY-001  
> **Done when:** Only permitted metrics exposed; RLS + revocation tests pass

Prompt:

```text
Implement shared family health metrics using strict consent.

Potential documented metrics:
- steps
- weight
- sleep
- blood pressure
- CGM
- medication
- activity

Only expose data the monitored member explicitly permits.

Add RLS/API authorization tests and revocation tests.
```

---

## TASK 078 — Family Care Dashboard

> **Roadmap:** R3 · **Priority:** P1 · **Depends on:** 077  
> **Brain docs:** security.md, data_model.md, api_contract.md, ui_spec.md · **Microtasks:** FAMILY-001  
> **Done when:** Consent-aware dashboard; no raw data dump

Prompt:

```text
Build the Family Care Dashboard.

Design for the Indian household use case where an adult child may help monitor a parent.

Provide:
- consent-aware status
- key shared metrics
- last synchronization time
- alerts where documented
- no unnecessary data exposure

Do not put all raw health data on one screen.
```

---

## TASK 078A — Family Crisis Alert Guardrails

> **Roadmap:** R3 · **Priority:** P1 · **Depends on:** 078 · 🆕 **Added in v1.1**  
> **Brain docs:** security.md, data_model.md, api_contract.md · **Microtasks:** FAMILY-001  
> **Done when:** Alerts never imply emergency services; thresholds recorded

Prompt:

```text
Implement guarded family alerts for concerning readings or inactivity.

Requirements:
- alerts must never pretend to be emergency medical services
- visible wording that directs users to professional/emergency help where appropriate
- only for metrics the monitored member explicitly consented to share
- thresholds are OPEN DECISION; no diagnostic claims
- alert-fatigue controls and audit events

Add authorization, wording and revocation tests.
```

Acceptance criteria:
- see "Done when" above and the Definition of Done

---

# PHASE 14 — MONETIZATION & RAZORPAY

> **Phase gate:** Razorpay/UPI/AutoPay, webhooks, entitlement engine, paywall and sachets are server-authoritative and replay-safe.

## TASK 079 — Subscription Domain

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 008A  
> **Brain docs:** api_contract.md, security.md, decisions.md, error_handling.md, decisions.md · **Microtasks:** PAY-001  
> **Done when:** Plan/entitlement models; no hard-coded prices

Prompt:

```text
Implement FitKarma subscription domain models.

Plans:
- Yogi Free
- Karma Pro
- FitKarma Elite
- Sachet Sprints

Keep pricing configurable from backend.

Do not hard-code final production prices into business logic.

Model:
- plan
- entitlement
- status
- start/end
- renewal
- grace period
- cancellation
- refund
```

---

## TASK 080 — Razorpay Server Integration Boundary

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 012C, 079  
> **Brain docs:** api_contract.md, security.md, decisions.md, error_handling.md · **Microtasks:** PAY-002  
> **Done when:** Server-only secrets; client sees public values only

Prompt:

```text
Implement the Razorpay server-side integration boundary.

Requirements:
- server-only secrets
- client only receives safe/public values
- order/subscription creation on trusted server
- server verification
- idempotency
- audit metadata
- error mapping

Do not activate real production secrets.

Do not let the Flutter app decide final entitlement status.
```

---

## TASK 081 — UPI Payment Flow

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 080  
> **Brain docs:** api_contract.md, security.md, decisions.md, error_handling.md · **Microtasks:** PAY-003  
> **Done when:** UPI state machine documented; mocked tests pass

Prompt:

```text
Implement the documented UPI-first payment flow.

Support the appropriate Razorpay UPI flow from the configured provider integration.

Requirements:
- user initiates payment
- server creates required payment object
- client handles payment UX
- server confirms final state
- entitlement remains server-authoritative

Add mocked integration tests.
```

---

## TASK 082 — UPI AutoPay

> **Roadmap:** R2 · **Priority:** P0 · **Depends on:** 081  
> **Brain docs:** api_contract.md, security.md, decisions.md, error_handling.md · **Microtasks:** PAY-004  
> **Done when:** All mandate states covered by tests

Prompt:

```text
Implement UPI AutoPay subscription architecture.

Flow:
plan selected
→ backend creates required Razorpay subscription/order
→ user authorizes mandate
→ mandate created
→ Razorpay confirmation
→ backend verifies
→ subscription activated
→ webhook events
→ entitlement updated

Support states:
created
pending
mandate_authorized
active
renewal_pending
payment_failed
grace_period
cancelled
expired
refunded

Never trust a client callback as the final authority.
```

---

## TASK 083 — Razorpay Webhooks

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 080  
> **Brain docs:** api_contract.md, security.md, decisions.md, error_handling.md · **Microtasks:** PAY-005  
> **Done when:** Duplicate/delayed/out-of-order/invalid webhooks handled

Prompt:

```text
Implement secure Razorpay webhook processing.

Requirements:
- signature verification
- replay/duplicate protection
- idempotency
- event persistence
- event ordering tolerance
- state transition rules
- retry safety
- safe logging

Add tests for:
- duplicate webhook
- delayed webhook
- invalid signature
- out-of-order events
- payment failure
- refund
```

---

## TASK 084 — Entitlement Engine

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 083  
> **Brain docs:** api_contract.md, security.md, decisions.md, error_handling.md · **Microtasks:** PAY-005  
> **Done when:** Entitlements derived server-side; client only consumes

Prompt:

```text
Implement the server-authoritative entitlement engine.

Map verified payment/subscription state to product entitlements.

Support:
- free
- pro
- elite
- sachet products
- grace period
- expiry
- cancellation
- refund

The Flutter client should consume entitlement state rather than calculate it.
```

---

## TASK 084A — Paywall, Plan Selection and Feature Gating UI

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 084 · 🆕 **Added in v1.1**  
> **Brain docs:** api_contract.md, security.md, decisions.md, error_handling.md, ui_spec.md · **Microtasks:** —  
> **Done when:** Paywall shows pending→active; gating never blocks health-safety features

Prompt:

```text
Build the client paywall using server-provided entitlements and config.

Requirements:
- show plan, amount, billing cadence, payment method and pending/final activation states
- UPI prominent for Indian users
- gate documented Pro features (WhatsApp voice logging, AI meal analysis, complete recipe library, Dynamic TDEE, ad-free) from entitlement state only
- never gate health-safety functions
- handle pending, failed, grace-period and expired states gracefully

Add widget tests for every entitlement state.
```

Acceptance criteria:
- see "Done when" above and the Definition of Done

---

## TASK 084B — Sachet Sprints

> **Roadmap:** R2 · **Priority:** P2 · **Depends on:** 084 · 🆕 **Added in v1.1**  
> **Brain docs:** api_contract.md, security.md, decisions.md, error_handling.md · **Microtasks:** —  
> **Done when:** Sachets configurable, refundable, entitlement-backed

Prompt:

```text
Implement Sachet Sprints (one-off focused health reports or short programs).

Requirements:
- price and catalog backend-configurable
- one-off purchase with server-verified entitlement
- refund handling
- no hard-coded prices

Add entitlement and refund tests.
```

Acceptance criteria:
- see "Done when" above and the Definition of Done

---

# PHASE 15 — ADS, NOTIFICATIONS & ENGAGEMENT

> **Phase gate:** Ads, notifications, Karma and squads respect health-critical-surface rules and anti-abuse limits.

## TASK 085 — AdMob Foundation

> **Roadmap:** R2 · **Priority:** P1 · **Depends on:** 084, 010  
> **Brain docs:** admob_spec.md, ui_spec.md · **Microtasks:** —  
> **Done when:** Test IDs only; premium ad-free; no ads on critical surfaces

Prompt:

```text
Implement the AdMob architecture from Brain/admob_spec.md.

Requirements:
- free vs premium behavior
- safe placements
- frequency limits
- consent
- analytics hooks
- rewarded ads only where appropriate
- no ads inside critical health actions
- no interference with medical/health workflows

Use test ad IDs during development.

Do not ship production credentials yet.
```

---

## TASK 086 — Notification Infrastructure

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 008A, 010  
> **Brain docs:** admob_spec.md, ui_spec.md · **Microtasks:** —  
> **Done when:** Preferences, quiet periods, FCM and deep links tested

Prompt:

```text
Implement notification infrastructure.

Support:
- local notification scheduling
- FCM token registration
- server-dispatched notifications boundary
- categories/types
- preferences
- quiet periods
- localization
- cancellation
- deep links

Add tests for notification preference enforcement.
```

---

## TASK 087 — Karma Points

> **Roadmap:** R2 · **Priority:** P2 · **Depends on:** 055  
> **Brain docs:** admob_spec.md, ui_spec.md · **Microtasks:** —  
> **Done when:** Points deterministic and auditable; no spam loops

Prompt:

```text
Implement the Karma points system.

Support documented reward sources such as:
- completed actions
- adherence
- challenges
- healthy behavior

Keep points deterministic and auditable.

Do not create artificial addictive loops or spam.

Prepare for future partner rewards.
```

---

## TASK 088 — Squads and Collective Challenges

> **Roadmap:** R3 · **Priority:** P2 · **Depends on:** 087, 075  
> **Brain docs:** admob_spec.md, ui_spec.md · **Microtasks:** —  
> **Done when:** Authorization + anti-abuse tests; no social feed

Prompt:

```text
Implement the documented functional social layer.

Focus on:
- squads
- collective challenges
- family activity rings
- corporate step challenges

Do NOT build an Instagram-style social feed.

Add authorization and anti-abuse boundaries.
```

---

# PHASE 16 — DATA VAULT, PRIVACY & DPDP

> **Phase gate:** Data Vault, export, erasure, RLS hardening and rate limiting verified by tests.

## TASK 089 — Data Vault

> **Roadmap:** R2 · **Priority:** P0 · **Depends on:** 091  
> **Brain docs:** security.md, data_model.md, ui_spec.md · **Microtasks:** —  
> **Done when:** Screen explains local vs cloud data; entry points work

Prompt:

```text
Build the FitKarma Data Vault screen.

Show users:
- what is stored locally
- what is stored in cloud systems
- connected health sources
- AI/WhatsApp data categories
- family-sharing state
- retention/deletion controls where applicable

Provide entry points for:
- export data
- erase account/data
- revoke family access
- manage integrations

Keep privacy language understandable.
```

---

## TASK 090 — Data Export

> **Roadmap:** R2 · **Priority:** P0 · **Depends on:** 012C  
> **Brain docs:** security.md, data_model.md, ui_spec.md · **Microtasks:** —  
> **Done when:** Secure expiring export; access-control tests

Prompt:

```text
Implement the user data export architecture.

Support a secure export request covering the documented user data categories.

Define:
- request
- generation
- secure delivery
- expiration
- audit event

Do not expose private data through insecure download URLs.

Add access-control tests.
```

---

## TASK 091 — Right-to-Erasure

> **Roadmap:** R2 · **Priority:** P0 · **Depends on:** 012B, 019  
> **Brain docs:** security.md, data_model.md, ui_spec.md, api_contract.md · **Microtasks:** —  
> **Done when:** Deletion cascade, receipts and family revocation tested; no false completion

Prompt:

```text
Implement the client/server contract for the documented delete_user_data cascading deletion process.

Cover:
- local data wipe
- remote deletion request
- storage cleanup
- AI/WhatsApp data deletion where applicable
- family access removal
- subscription/account handling boundaries
- audit receipt without retaining deleted health data

Add tests for deletion cascade and family-access revocation.

Do not falsely claim deletion is complete unless the backend confirms it.
```

---

## TASK 092 — RLS and Authorization Hardening

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 012B  
> **Brain docs:** security.md, data_model.md, ui_spec.md · **Microtasks:** —  
> **Done when:** pgTAP proves isolation, revocation and anon denial

Prompt:

```text
Implement and test Supabase Row Level Security and authorization for all implemented user/family data.

Verify:
- users can access only their own records
- family users see only explicitly shared data
- revoked users lose access immediately/appropriately
- privileged operations use server-side controls
- anonymous users cannot access health data

Add pgTAP/database authorization tests.
```

---

## TASK 092A — Rate Limiting and Abuse Prevention

> **Roadmap:** R2 · **Priority:** P0 · **Depends on:** 012C, 092 · 🆕 **Added in v1.1**  
> **Brain docs:** security.md, data_model.md, ui_spec.md, api_contract.md · **Microtasks:** —  
> **Done when:** Per-bucket limits (thresholds OPEN DECISION) tested

Prompt:

```text
Implement server-side rate limits using separate buckets for authentication, AI, WhatsApp, data export, sync and payment actions.

Requirements:
- per-user and per-IP controls plus provider/webhook verification
- thresholds are OPEN DECISION; record PROPOSED values in Brain/decisions.md
- return stable FK-xxxx errors with retry guidance
- abuse tests for automated API usage

Add tests per bucket.
```

Acceptance criteria:
- see "Done when" above and the Definition of Done

---

# PHASE 17 — ADMIN / FITKARMA HUB

> **Phase gate:** FitKarma Hub admin boundaries documented; no unrestricted health-data access for admins.

## TASK 093 — FitKarma Hub Foundation

> **Roadmap:** R3 · **Priority:** P2 · **Depends on:** 012B  
> **Brain docs:** architecture.md, security.md · **Microtasks:** —  
> **Done when:** Role boundaries documented; no unrestricted health-data access

Prompt:

```text
If the repository/product scope includes the documented FitKarma Hub companion admin platform, create its foundation.

Support administrative boundaries for:
- user support
- content/data management
- food database administration
- recipe management
- subscription visibility
- audit logs
- feature/configuration management

Do not expose unrestricted user health data to administrators.

Document role boundaries.
```

---

## TASK 094 — Indian Food Database Administration

> **Roadmap:** R3 · **Priority:** P2 · **Depends on:** 093, 033A  
> **Brain docs:** architecture.md, security.md · **Microtasks:** —  
> **Done when:** Versioned food edits with audit; referenced foods undeletable

Prompt:

```text
Implement the admin workflow for managing Indian food/recipe data.

Support:
- food creation/editing
- portions
- raw/cooked variants
- cooking multipliers
- provenance
- review status
- versioning

Prevent arbitrary deletion of food entities referenced by historical logs.

Add audit trails.
```

---

# PHASE 18 — EXTERNAL DATA SOURCES & RESPONSIBLE DATA COLLECTION

> **Phase gate:** External/Indian datasets ingested with provenance, licensing and responsible-collection rules.

## TASK 095 — Open Food Facts Integration

> **Roadmap:** R2 · **Priority:** P2 · **Depends on:** 033A  
> **Brain docs:** data_sources.md, scrapping_spec.md · **Microtasks:** —  
> **Done when:** Normalized, deduped, cached; curated data never overwritten blindly

Prompt:

```text
Implement Open Food Facts integration according to Brain/data_sources.md.

Requirements:
- API/source abstraction
- caching
- provenance
- deduplication
- rate-limit awareness
- fallback
- data normalization
- privacy-safe usage

Do not overwrite curated Indian food records blindly.

Add import/normalization tests.
```

---

## TASK 096 — Indian Dataset Ingestion

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 033A  
> **Brain docs:** data_sources.md, scrapping_spec.md · **Microtasks:** —  
> **Done when:** Provenance, licensing and review status recorded

Prompt:

```text
Implement the ingestion pipeline for approved Indian food datasets.

Follow the documented priority:
official APIs
→ licensed datasets
→ open datasets
→ permitted scraping

Support:
- provenance
- attribution
- deduplication
- review status
- versioning
- update process

Do not ingest data that violates licensing or access restrictions.
```

---

## TASK 097 — Responsible Scraping Pipeline

> **Roadmap:** R3 · **Priority:** P2 · **Depends on:** 096  
> **Brain docs:** data_sources.md, scrapping_spec.md · **Microtasks:** —  
> **Done when:** robots/ToS/throttling stop conditions enforced

Prompt:

```text
Implement only a responsible, policy-compliant scraping architecture where documented sources cannot be obtained through APIs/datasets.

Requirements:
- robots.txt awareness
- Terms of Service review
- throttling
- caching
- attribution
- deduplication
- provenance
- change detection
- stop conditions

Do not implement access-control bypasses or ToS-violating automation.
```

---

# PHASE 19 — ANALYTICS, METRICS & PRODUCT INSIGHTS

> **Phase gate:** Privacy-conscious analytics, retention-loop instrumentation and SLOs defined.

## TASK 098 — Product Analytics Contract

> **Roadmap:** R2 · **Priority:** P1 · **Depends on:** 086  
> **Brain docs:** pdr.md (success metrics), security.md · **Microtasks:** —  
> **Done when:** Schema documented; no health payloads in properties

Prompt:

```text
Implement privacy-conscious product analytics events.

Track only documented/necessary events such as:
- onboarding completion
- food log completion
- workout completion
- WhatsApp logging
- AI confirmation
- Health integration connection
- subscription events
- retention milestones

Do not log sensitive health payloads as analytics properties.

Create a documented event schema.
```

---

## TASK 099 — Retention Loop Instrumentation

> **Roadmap:** R2 · **Priority:** P1 · **Depends on:** 098  
> **Brain docs:** pdr.md (success metrics), security.md · **Microtasks:** —  
> **Done when:** Funnel stages measured with dedupe

Prompt:

```text
Instrument the documented FitKarma retention loop:

Trigger
→ WhatsApp/food logging
→ insight
→ app engagement
→ micro-action
→ Karma reward

Measure each stage without storing unnecessary sensitive content.

Create analytics tests and event deduplication behavior.
```

---

## TASK 099A — SLOs, Alerting and KPI Validation (PROPOSED)

> **Roadmap:** R2 · **Priority:** P1 · **Depends on:** 099 · 🆕 **Added in v1.1**  
> **Brain docs:** pdr.md (success metrics), security.md, architecture.md · **Microtasks:** —  
> **Done when:** SLO targets recorded PROPOSED; alerts for sync/webhook failures exist

Prompt:

```text
Define and wire operational objectives before launch.

Define PROPOSED SLOs for: sync success rate, API latency, crash-free sessions and webhook processing. Configure alerts for sync and webhook failures, and validate the KPI events listed in Brain/pdr.md section 9 (retention, meals logged, WhatsApp completion, AI correction rate, conversion, family consent rate, deletion/export completion).

Record targets in Brain/decisions.md as PROPOSED until approved.
```

Acceptance criteria:
- see "Done when" above and the Definition of Done

---

# PHASE 20 — TESTING & QUALITY

> **Phase gate:** Shared test architecture plus nutrition, offline, security, AI and payment suites green.

## TASK 100 — Testing Architecture

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 005  
> **Brain docs:** testing.md · **Microtasks:** —  
> **Done when:** Shared helpers and examples for every test layer

Prompt:

```text
Establish the complete testing architecture from Brain/testing.md.

Create conventions and helpers for:
- unit tests
- widget tests
- integration tests
- repository tests
- database tests
- RLS/pgTAP tests
- offline tests
- sync tests
- AI contract tests
- payment/webhook tests
- localization tests
- accessibility tests
- performance tests

Do not merely create empty test folders; provide useful shared helpers and examples.
```

---

## TASK 101 — Nutrition Test Suite

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 040  
> **Brain docs:** testing.md · **Microtasks:** NUT-001, NUT-002, NUT-003, NUT-004  
> **Done when:** Nutrition suite green incl. historical reproducibility

Prompt:

```text
Build a comprehensive nutrition test suite covering:

- portion conversion
- raw/cooked distinction
- cooking multipliers
- Tadka estimation
- family recipe percentage splits
- calories/macros
- invalid inputs
- rounding
- historical reproducibility
- offline save
- synchronization
- duplicate logs

Add regression cases for every nutrition calculation bug discovered later.
```

---

## TASK 102 — Offline and Sync Test Suite

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 023  
> **Brain docs:** testing.md · **Microtasks:** —  
> **Done when:** No data loss across failure/restart scenarios

Prompt:

```text
Create comprehensive offline-first tests.

Cover:
- offline creation
- offline edits
- offline deletion
- reconnect
- duplicate upload
- retry
- permanent error
- app restart during sync
- conflict
- partial batch
- duplicate webhook-like sync events

Prove user data is not lost during network failure.
```

---

## TASK 103 — Authentication/Security Test Suite

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 092  
> **Brain docs:** testing.md · **Microtasks:** —  
> **Done when:** Auth/security suite green; no sensitive fixtures in logs

Prompt:

```text
Create comprehensive auth/security tests.

Cover:
- OTP failures
- expired session
- unauthorized API calls
- RLS isolation
- family revocation
- local data access
- logout cleanup
- deletion
- export authorization
- secret exposure checks

Do not print sensitive fixtures in CI logs.
```

---

## TASK 104 — AI Test Suite

> **Roadmap:** R2 · **Priority:** P0 · **Depends on:** 060  
> **Brain docs:** testing.md · **Microtasks:** —  
> **Done when:** AI suite green incl. prompt injection and fallback

Prompt:

```text
Create the AI test suite.

Cover:
- valid model response
- malformed JSON
- incomplete response
- low confidence
- ambiguous food
- unsupported food
- hallucinated nutrition
- unsafe medical advice
- prompt injection
- provider timeout
- rate limit
- fallback behavior

AI output must never bypass deterministic validation.
```

---

## TASK 105 — Payment Test Suite

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 084  
> **Brain docs:** testing.md · **Microtasks:** PAY-005  
> **Done when:** Payment suite green with mocked providers only

Prompt:

```text
Create payment tests covering:

- subscription creation
- UPI payment success
- UPI failure
- AutoPay mandate creation
- renewal
- grace period
- cancellation
- expiry
- refund
- duplicate webhook
- invalid webhook signature
- delayed webhook
- out-of-order webhook
- entitlement updates

Use mocked provider responses.
Never use real payment credentials in automated tests.
```

---

# PHASE 21 — CI/CD & RELEASE ENGINEERING

> **Phase gate:** CI/CD (analysis, tests, RLS, security scans, Android/iOS builds) blocks bad merges; secrets only via CI secrets.

## TASK 106 — GitHub Actions CI

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 100  
> **Brain docs:** github_actions.md · **Microtasks:** —  
> **Done when:** CI blocks on format/analyze/tests/RLS/security

Prompt:

```text
Implement GitHub Actions CI according to Brain/github_actions.md.

Pipeline should cover where applicable:
- formatting check
- lint/analyze
- unit tests
- widget tests
- integration tests
- security checks
- dependency checks
- secret scanning
- database tests
- RLS/pgTAP tests

Fail safely without exposing secrets.
```

---

## TASK 107 — Android Build Pipeline

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 106  
> **Brain docs:** github_actions.md · **Microtasks:** —  
> **Done when:** Signed release validated via CI secrets

Prompt:

```text
Create the Android CI build pipeline.

Support:
- debug build
- release build validation
- signing configuration via CI secrets
- artifact generation
- versioning
- test execution before build

Do not commit signing keys.
```

---

## TASK 108 — iOS Build Pipeline

> **Roadmap:** R1 · **Priority:** P0 · **Depends on:** 106  
> **Brain docs:** github_actions.md · **Microtasks:** —  
> **Done when:** iOS build validated; no certs committed

Prompt:

```text
Create the iOS CI build pipeline.

Support:
- simulator/test build where feasible
- release validation
- signing configuration via secure CI secrets
- artifact generation

Do not commit certificates/profiles or secrets.
```

---

## TASK 109 — Dependency and Vulnerability Review

> **Roadmap:** R1 · **Priority:** P1 · **Depends on:** 106  
> **Brain docs:** github_actions.md · **Microtasks:** —  
> **Done when:** Vulnerability/outdated checks automated

Prompt:

```text
Implement dependency hygiene.

Review:
- Flutter packages
- Dart packages
- native Android dependencies
- native iOS dependencies
- Supabase/Edge Function dependencies

Add automated checks for vulnerable/outdated dependencies where practical.

Do not upgrade packages blindly; test compatibility before changing them.
```

---

# PHASE 22 — PRODUCTION READINESS

> **Phase gate:** Performance, offline, security, privacy, accessibility, consistency and store audits complete; production checklist items marked PASS/FAIL/BLOCKED/OPEN with evidence.

## TASK 110 — Performance Optimization

> **Roadmap:** PL · **Priority:** P0 · **Depends on:** —  
> **Brain docs:** production_checklist.md, security.md, trd.md · **Microtasks:** —  
> **Done when:** Measured bottlenecks fixed; budgets recorded

Prompt:

```text
Perform a production performance pass.

Measure:
- cold start
- dashboard render
- local database queries
- food search
- sync performance
- memory usage
- image handling
- AI request latency
- battery-impact areas

Optimize based on measured bottlenecks, not guesswork.

Do not sacrifice correctness/security for superficial benchmarks.
```

---

## TASK 111 — Offline Production Audit

> **Roadmap:** PL · **Priority:** P0 · **Depends on:** —  
> **Brain docs:** production_checklist.md, security.md · **Microtasks:** —  
> **Done when:** Offline matrix (full/partial/online-only) documented

Prompt:

```text
Perform an end-to-end offline audit.

Test:
- onboarding as applicable
- food logging
- recipe creation
- workouts
- sleep
- weight
- water
- mood
- local dashboard
- sync after reconnect

Document which features are:
- fully offline
- partially offline
- online-required

Fix any unexpected data-loss paths.
```

---

## TASK 112 — Security Production Audit

> **Roadmap:** PL · **Priority:** P0 · **Depends on:** —  
> **Brain docs:** production_checklist.md, security.md · **Microtasks:** —  
> **Done when:** Findings fixed or recorded as unresolved risks

Prompt:

```text
Perform a production security audit against Brain/security.md.

Review:
- secrets
- RLS
- authentication
- authorization
- local encryption
- sensitive logs
- storage
- AI boundaries
- WhatsApp
- payments
- family access
- deletion
- export
- abuse/rate limiting

Fix findings that are in scope.

Record unresolved risks in the appropriate documentation.
```

---

## TASK 112A — Backup, Restore and Migration Rollback Drill

> **Roadmap:** PL · **Priority:** P0 · **Depends on:** 112 · 🆕 **Added in v1.1**  
> **Brain docs:** production_checklist.md, security.md, production_checklist.md · **Microtasks:** —  
> **Done when:** Restore drill and migration rollback evidenced

Prompt:

```text
Prove recoverability.

Perform and document:
- backup and restore of the Postgres database and storage
- migration rollback/forward drill on a copy
- RLS and deletion tests re-run after restore

Record evidence for Brain/production_checklist.md.
```

Acceptance criteria:
- see "Done when" above and the Definition of Done

---

## TASK 113 — Privacy / DPDP Readiness Audit

> **Roadmap:** PL · **Priority:** P0 · **Depends on:** —  
> **Brain docs:** production_checklist.md, security.md · **Microtasks:** —  
> **Done when:** OPEN DECISION items listed; no overclaiming compliance

Prompt:

```text
Perform a privacy-readiness audit.

Verify:
- consent collection
- purpose clarity
- data minimization
- export
- deletion
- family consent
- sensitive health data handling
- AI/WhatsApp data treatment
- retention controls
- audit records

Do not claim legal certification/compliance beyond what the implementation and documentation support.

Record OPEN DECISION items clearly.
```

---

## TASK 113A — Legal Review Package

> **Roadmap:** PL · **Priority:** P0 · **Depends on:** 113 · 🆕 **Added in v1.1**  
> **Brain docs:** production_checklist.md, security.md · **Microtasks:** —  
> **Done when:** Counsel-ready package assembled; legal review tracked

Prompt:

```text
Assemble a counsel-ready package: data inventory, purposes, consent and notice texts, retention table, processors/third parties, export/deletion mechanics, family consent flow and AI/WhatsApp treatment.

Clearly separate product privacy controls from legal compliance claims. Do not state certification. Track legal review as OPEN DECISION until completed.
```

Acceptance criteria:
- see "Done when" above and the Definition of Done

---

## TASK 114 — Accessibility and Localization Audit

> **Roadmap:** PL · **Priority:** P1 · **Depends on:** —  
> **Brain docs:** production_checklist.md, security.md · **Microtasks:** —  
> **Done when:** Real defects fixed in EN/HI at large text

Prompt:

```text
Perform a final accessibility/localization audit.

Test:
- English
- Hindi
- long strings
- text scaling
- screen readers
- touch targets
- dark mode
- contrast
- orientation/responsive layouts

Fix real defects found.
```

---

## TASK 115 — Final Product Consistency Audit

> **Roadmap:** PL · **Priority:** P0 · **Depends on:** —  
> **Brain docs:** production_checklist.md, security.md · **Microtasks:** PAY-001  
> **Done when:** RevenueCat appears only as historical migration context

Prompt:

```text
Perform a full FitKarma product consistency audit.

Search the repository and Brain documentation for:
- RevenueCat
- Razorpay
- UPI
- UPI AutoPay
- subscription
- payment
- offline
- Drift
- Supabase
- Health Connect
- Apple Health
- WhatsApp
- AI
- family
- Ayurveda
- DPDP

RevenueCat may only remain as historical migration context in decisions/changelog documentation.

Resolve implementation contradictions without inventing facts.

Produce an audit report.
```

---

## TASK 116 — Production Checklist Completion

> **Roadmap:** PL · **Priority:** P0 · **Depends on:** —  
> **Brain docs:** production_checklist.md, security.md · **Microtasks:** —  
> **Done when:** Every item PASS/FAIL/BLOCKED/OPEN with evidence

Prompt:

```text
Complete Brain/production_checklist.md against the actual implementation.

Check:
- product
- backend
- database
- security
- privacy
- AI
- payments
- Razorpay
- UPI
- UPI AutoPay
- Android
- iOS
- offline mode
- monitoring
- analytics
- Play Store
- App Store

Mark every item:
- PASS
- FAIL
- BLOCKED
- OPEN DECISION

Do not mark an item PASS without evidence.
```

---

## TASK 116A — Store Submission Readiness

> **Roadmap:** PL · **Priority:** P0 · **Depends on:** 116 · 🆕 **Added in v1.1**  
> **Brain docs:** production_checklist.md, security.md · **Microtasks:** —  
> **Done when:** Store metadata/disclosures ready; low-end Android smoke passes

Prompt:

```text
Prepare Play Store and App Store submission.

Cover: privacy policy links, consent disclosures, health-data declarations, app review metadata, payment descriptions, production signing and a low-end Android smoke test.

Mark each item with evidence in Brain/production_checklist.md.
```

Acceptance criteria:
- see "Done when" above and the Definition of Done

---

## TASK 117 — End-to-End Smoke Test

> **Roadmap:** PL · **Priority:** P0 · **Depends on:** —  
> **Brain docs:** production_checklist.md, security.md · **Microtasks:** —  
> **Done when:** Fresh-install journey executed; failures documented

Prompt:

```text
Execute a full greenfield FitKarma smoke test from a fresh environment.

Test the highest-value path:

install
→ launch
→ sign up
→ onboarding
→ permissions
→ dashboard
→ food logging
→ Indian portions
→ Tadka
→ nutrition insight
→ workout
→ sleep/health data where available
→ offline mode
→ reconnect/sync
→ subscription test flow
→ logout
→ privacy/data controls

Document all failures.

Do not begin a separate refactor during this task.
```

---

## TASK 118 — Release Candidate Hardening

> **Roadmap:** PL · **Priority:** P0 · **Depends on:** 117  
> **Brain docs:** production_checklist.md, security.md · **Microtasks:** —  
> **Done when:** RC built; known issues + release notes written

Prompt:

```text
Prepare the FitKarma release candidate.

Only fix issues discovered from the completed test/audit set.

Perform:
- regression tests
- build validation
- crash/error review
- database migration validation
- configuration validation
- release notes preparation
- known issues documentation

Do not add major new features during this task.
```

---

# PHASE 23 — POST-MVP CATEGORY LEADERSHIP

> **Phase gate:** Only start after the core app is stable and provider/legal requirements are verified.

These tasks should be performed only after the core app is stable.

## TASK 119 — CGM Integration Architecture

> **Roadmap:** R3 · **Priority:** P2 · **Depends on:** 032B  
> **Brain docs:** data_sources.md, decisions.md, data_sources.md · **Microtasks:** —  
> **Done when:** Provider APIs verified first; no invented medical interpretation

Prompt:

```text
Implement the CGM integration abstraction and first supported provider only after verifying current provider/API requirements.

Support:
- glucose samples
- timestamps
- source attribution
- ingestion normalization
- privacy
- deletion
- visualization
- relationship to meals

Do not invent provider APIs or medical interpretations.
```

---

## TASK 120 — ABHA / ABDM Integration

> **Roadmap:** R3 · **Priority:** P2 · **Depends on:** —  
> **Brain docs:** data_sources.md, decisions.md, data_sources.md · **Microtasks:** —  
> **Done when:** API/legal requirements documented before code

Prompt:

```text
Implement ABHA/ABDM integration only after documenting verified API/legal requirements.

Create:
- authentication/consent flow
- record synchronization
- normalization
- secure storage
- deletion/revocation boundaries

Do not assume access or permissions not supported by the actual provider/API.
```

---

## TASK 121 — Grocery Integration

> **Roadmap:** R3 · **Priority:** P2 · **Depends on:** —  
> **Brain docs:** data_sources.md, decisions.md, data_sources.md · **Microtasks:** —  
> **Done when:** Provider-agnostic cart mapping with user confirmation

Prompt:

```text
Implement grocery integration architecture for future Zepto/Blinkit or other approved providers.

Support:
- ingredient list generation
- cart mapping abstraction
- user confirmation
- privacy
- provider fallbacks

Do not hard-code unsupported third-party APIs.
```

---

## TASK 122 — Corporate Wellness

> **Roadmap:** R3 · **Priority:** P2 · **Depends on:** 093  
> **Brain docs:** data_sources.md, decisions.md · **Microtasks:** —  
> **Done when:** Only aggregated, consented metrics visible to employers

Prompt:

```text
Implement the FitKarma Hub corporate wellness architecture.

Support the documented direction:
- organizations
- cohorts
- challenges
- aggregated reporting
- privacy-safe metrics
- employee consent
- admin roles

Do not expose individual medical data to employers.
```

---

## TASK 122A — Biological Age Estimation (PROPOSED)

> **Roadmap:** R3 · **Priority:** P2 · **Depends on:** 043, 119 · 🆕 **Added in v1.1**  
> **Brain docs:** data_sources.md, decisions.md, decisions.md · **Microtasks:** —  
> **Done when:** ADR approved; always labelled estimate/wellness

Prompt:

```text
Only after an ADR defines the method and inputs.

Requirements: always labelled an estimate with confidence; wellness framing, not medical; separate from evidence-based clinical metrics; user can hide it; deterministic and testable.
```

Acceptance criteria:
- see "Done when" above and the Definition of Done

---

## TASK 122B — Clinical Dossier Generation

> **Roadmap:** R3 · **Priority:** P2 · **Depends on:** 076, 090 · 🆕 **Added in v1.1**  
> **Brain docs:** data_sources.md, decisions.md, security.md · **Microtasks:** —  
> **Done when:** User-controlled, consented, non-diagnostic export

Prompt:

```text
Generate a user-controlled health summary the user may share with a clinician.

Requirements: explicit consent per export, secure expiring delivery, no diagnostic claims, scope defined by ADR (OPEN DECISION), audit event on creation/share.
```

Acceptance criteria:
- see "Done when" above and the Definition of Done

---

## TASK 122C — Elite Tier Services Readiness

> **Roadmap:** R3 · **Priority:** P3 · **Depends on:** 084 · 🆕 **Added in v1.1**  
> **Brain docs:** data_sources.md, decisions.md, decisions.md · **Microtasks:** —  
> **Done when:** Legal/ops readiness checklist signed off before build

Prompt:

```text
Assess readiness for FitKarma Elite human/clinical services and advanced metabolic tracking.

Produce an operational/legal readiness checklist and entitlement design only. Do not build service delivery until legal and operations sign-off is recorded as an ADR.
```

Acceptance criteria:
- see "Done when" above and the Definition of Done

---

# DEFERRED / DO NOT IMPLEMENT UNLESS EXPLICITLY REAUTHORIZED

The following should remain out of the main implementation sequence:

- Instagram-style fitness social feed
- proprietary wearable hardware
- expensive on-device pose estimation as a core product feature
- heavy video-production/content platform
- low-retention experimental AI features

The strategy source specifically identifies these as poor priorities compared with FitKarma's nutrition, WhatsApp, offline, family, and Health OS strengths.

---

# DEFINITION OF DONE FOR EVERY TASK

A task cannot be considered complete merely because code exists.

The task is DONE only when:

[ ] functionality is implemented  
[ ] architecture matches documentation  
[ ] security/authorization is addressed  
[ ] offline behavior is addressed where applicable  
[ ] error handling exists  
[ ] tests are added/updated  
[ ] formatting passes  
[ ] static analysis passes  
[ ] relevant tests pass  
[ ] documentation is updated when needed  
[ ] no unrelated refactor was introduced  
[ ] final diff was reviewed  
[ ] task is mapped to its Brain microtask IDs (where one exists) and progress tracker is updated  
[ ] every undefined detail is labelled PROPOSED or OPEN DECISION (and recorded in Brain/decisions.md when major)  
[ ] no secrets, personal health data or payment credentials were committed  
[ ] sensitive data paths have RLS/authorization and deletion/export behaviour defined  

---

# TASK STATUS TEMPLATE

Use this format when recording progress:

```text
## TASK XXX — <title>

Status: NOT STARTED / IN PROGRESS / COMPLETE / BLOCKED
Roadmap/Priority: R1|R2|R3|PL · P0|P1|P2|P3
Microtasks: ...
ADR touched: ...

Implementation:
- ...

Files changed:
- ...

Tests:
- ...

Checks:
- flutter analyze
- flutter test
- other relevant checks

Documentation:
- ...

Blockers:
- ...

Open Decisions:
- ...
```

---

# STRATEGIC BUILD ORDER

The intended greenfield order is:

```text
Repository
↓
Flutter bootstrap
↓
Architecture
↓
Design system
↓
Auth
↓
Profile/onboarding
↓
Drift + SQLCipher
↓
Offline outbox/sync
↓
Health domain
↓
Indian nutrition
↓
Food logging
↓
Workouts
↓
Health Connect / Apple Health
↓
Daily Intelligence Package
↓
AI gateway
↓
WhatsApp
↓
Fasting/AQI
↓
Women's health
↓
Family health
↓
Razorpay
↓
UPI AutoPay
↓
Privacy/Data Vault
↓
Analytics/notifications
↓
Testing/CI
↓
Production hardening
↓
CGM / ABHA / Grocery / Corporate
```

---

# FINAL IMPLEMENTATION PRINCIPLE

FitKarma is being built as a **new product from zero**, not as an incremental patchwork project.

The first priority is a stable, secure, offline-first foundation.

The second priority is the India-first nutrition experience.

The third priority is the frictionless WhatsApp + AI layer.

The fourth priority is the Health OS intelligence and integrations.

The fifth priority is monetization, family health, and category leadership.

Never sacrifice the foundational architecture to ship a flashy isolated feature.

---

# RECOMMENDED EXECUTION GROUPS (by Master Documentation roadmap)

Within a group, follow task dependencies and the ordering notes above.

**R1 — Phase 1 Competitive MVP (months 1–3)**

`001, 001A, 002, 003, 004, 005, 006, 007, 008, 008A, 009, 010, 011, 012, 012A, 012B, 012C, 013, 014, 015, 016, 017, 018, 019, 020, 021, 022, 023, 023A, 024, 024A, 025, 026, 027, 028, 029, 030, 031, 032, 032A, 032B, 033, 033A, 034, 035, 036, 039, 040, 041, 042, 044, 045, 046, 047, 048, 050, 051, 052, 053, 054, 055, 056, 079, 080, 081, 083, 084, 084A, 086, 092, 096, 100, 101, 102, 103, 105, 106, 107, 108, 109`

**R2 — Phase 2 India-First Differentiation (months 4–6)**

`037, 038, 043, 049, 057, 058, 059, 060, 061, 062, 063, 063A, 064, 064A, 065, 066, 067, 068, 069, 082, 084B, 085, 087, 089, 090, 091, 092A, 095, 098, 099, 099A, 104`

**R3 — Phase 3 Category Leadership (months 7–12)**

`039A, 070, 071, 072, 073, 074, 075, 076, 077, 078, 078A, 088, 093, 094, 097, 119, 120, 121, 122, 122A, 122B, 122C`

**PL — Pre-launch gate**

`110, 111, 112, 112A, 113, 113A, 114, 115, 116, 116A, 117, 118`

---

# MICROTASK TRACEABILITY (Brain/microtasks.md)

| Microtask | Implemented by task(s) |
|---|---|
| AI-001 | 059, 060, 065 |
| AI-002 | 064, 066 |
| AI-003 | 060, 067 |
| AI-004 | 062, 063A |
| DOC-001 | 001, 001A |
| DOC-002 | 001, 001A |
| FAMILY-001 | 075, 076, 077, 078, 078A |
| HEALTH-001 | 025, 027, 050, 051 |
| HEALTH-002 | 050, 052 |
| NUT-001 | 033, 033A, 034, 040, 101 |
| NUT-002 | 035, 036, 040, 101 |
| NUT-003 | 037, 101 |
| NUT-004 | 038, 101 |
| PAY-001 | 079, 115 |
| PAY-002 | 080 |
| PAY-003 | 081 |
| PAY-004 | 082 |
| PAY-005 | 083, 084, 105 |
| TDEE-001 | 043 |

---

# ADR TRACEABILITY (Brain/decisions.md)

| ADR | Decision | Tasks that implement or must respect it |
|---|---|---|
| ADR-001 / 003 | Offline-first, Drift + SQLCipher | 020–024A, 102 |
| ADR-002 | Supabase backend | 012A–012C, 013, 023A, 092 |
| ADR-004 | OS health aggregators first | 050–053 |
| ADR-005 | India-first nutrition | 033–041, 033A, 101 |
| ADR-006 | WhatsApp as low-friction interface | 064–068, 064A |
| ADR-007 | RevenueCat removed (historical only) | 079, 115, 001A |
| ADR-008 / 009 / 010 | Razorpay, UPI-first, UPI AutoPay | 079–084B, 105 |
| ADR-011 | Ayurveda as wellness layer, not medicine | 018, 063 |
| ADR-012 | Consent-based Family Care Dashboard | 075–078A |
| ADR-013 | Dynamic TDEE moved earlier | 043 |
| ADR-014 | AI photo logging is P1 | 062 |
| ADR-015 | Scope reduction / deferred features | Deferred section |

---

# OPEN DECISIONS REGISTER

| Open decision (from Brain docs) | Resolve in task | Record in |
|---|---|---|
| Physical table names/schemas, webhook payload persistence, retention windows, partitioning/index strategy | 012B, 063A, 091 | decisions.md, data_model.md |
| Conflict model per entity | 023, 024A | decisions.md |
| Exact Dynamic TDEE algorithm | 043 | decisions.md |
| API rate-limit thresholds | 092A | decisions.md |
| Ad frequency caps | 085 | admob_spec.md |
| Success-metric target values | 098, 099A | pdr.md |
| Numeric SLOs (sync, latency, crash-free, webhook) | 099A | decisions.md |
| Performance budgets (cold start, dashboard, offline write, sync, AI) | 110 | trd.md |
| Typography, spacing tokens, animation durations | 009 | ui_spec.md |
| Source refresh schedules and rollback | 096, 097 | scrapping_spec.md |
| GitHub Action versions and signing mechanism | 106–108 | github_actions.md |
| Family crisis-alert thresholds | 078A | decisions.md |
| Clinical dossier and biological-age scope | 122A, 122B | decisions.md |
| Legal review of privacy/DPDP posture | 113, 113A | security.md |

---

# PROGRESS TRACKER

Update the Status column as tasks finish (NOT STARTED / IN PROGRESS / COMPLETE / BLOCKED).

| ID | Title | Roadmap | Priority | Depends on | Status |
|---|---|---|---|---|---|
| 001 | Repository and Environment Audit | R1 | P0 | — | NOT STARTED |
| 001A | Documentation Wiring and Doc-Lint Gate | R1 | P0 | 001 | NOT STARTED |
| 002 | Bootstrap Flutter Application | R1 | P0 | 001 | NOT STARTED |
| 003 | Establish Git Ignore, Environment, and Secret Boundaries | R1 | P0 | 002 | NOT STARTED |
| 004 | Establish Project Folder Architecture | R1 | P0 | 002 | NOT STARTED |
| 005 | Riverpod Application Architecture | R1 | P0 | 004 | NOT STARTED |
| 006 | Navigation and Route Architecture | R1 | P0 | 005 | NOT STARTED |
| 007 | Error and Result Primitives | R1 | P0 | 004 | NOT STARTED |
| 008 | Logging and Observability Foundation | R1 | P0 | 007 | NOT STARTED |
| 008A | Feature Flags and Backend-Configurable Remote Config | R1 | P0 | 005,008 | NOT STARTED |
| 009 | FitKarma Design System | R1 | P0 | 005 | NOT STARTED |
| 010 | Localization Foundation | R1 | P0 | 009 | NOT STARTED |
| 011 | Accessibility Foundation | R1 | P0 | 009 | NOT STARTED |
| 012 | Shared UI States and Components | R1 | P0 | 009,010,011 | NOT STARTED |
| 012A | Supabase Project, Local Stack and Versioned Migrations | R1 | P0 | 003 | NOT STARTED |
| 012B | Baseline Schema and Universal RLS | R1 | P0 | 012A | NOT STARTED |
| 012C | Edge Function Scaffold and API Contract Baseline | R1 | P0 | 012A,012B | NOT STARTED |
| 013 | Supabase Client Foundation | R1 | P0 | 003,005,012A | NOT STARTED |
| 014 | Phone OTP Authentication | R1 | P0 | 013 | NOT STARTED |
| 015 | Google Sign-In | R1 | P0 | 013,014 | NOT STARTED |
| 016 | User Profile Domain | R1 | P0 | 013,020 | NOT STARTED |
| 017 | Onboarding Flow | R1 | P0 | 009,010,014,016 | NOT STARTED |
| 018 | Dosha/Wellness Profile Foundation | R1 | P1 | 017 | NOT STARTED |
| 019 | Account Lifecycle | R1 | P0 | 014,020 | NOT STARTED |
| 020 | Drift + SQLCipher Local Database | R1 | P0 | 004,012B | NOT STARTED |
| 021 | Offline Outbox | R1 | P0 | 020 | NOT STARTED |
| 022 | Sync State Machine | R1 | P0 | 021 | NOT STARTED |
| 023 | Supabase Sync Repository Pattern | R1 | P0 | 012B,021,022 | NOT STARTED |
| 023A | Supabase Realtime Integration | R1 | P1 | 023 | NOT STARTED |
| 024 | Offline Mode UX | R1 | P0 | 022 | NOT STARTED |
| 024A | Conflict Resolution UX | R1 | P0 | 023,024 | NOT STARTED |
| 025 | Core Health Domain | R1 | P0 | 020 | NOT STARTED |
| 026 | Weight Logging | R1 | P0 | 023,025 | NOT STARTED |
| 027 | Step Logging | R1 | P0 | 025 | NOT STARTED |
| 028 | Sleep Logging | R1 | P0 | 023,025 | NOT STARTED |
| 029 | Mood Logging | R1 | P1 | 023 | NOT STARTED |
| 030 | Water Logging | R1 | P1 | 023 | NOT STARTED |
| 031 | Medication Logging | R1 | P1 | 023 | NOT STARTED |
| 032 | Body Measurements | R1 | P1 | 023 | NOT STARTED |
| 032A | Habit Tracking | R1 | P1 | 023,086 | NOT STARTED |
| 032B | Blood Pressure and Manual Glucose Logging | R1 | P1 | 025,023 | NOT STARTED |
| 033 | Food Domain and Data Model | R1 | P0 | 020 | NOT STARTED |
| 033A | Indian Food Catalog Seed Pipeline and Local Cache | R1 | P0 | 033,012B | NOT STARTED |
| 034 | Indian Portion System | R1 | P0 | 033 | NOT STARTED |
| 035 | Raw vs Cooked Nutrition | R1 | P0 | 034 | NOT STARTED |
| 036 | Cooking Multipliers | R1 | P0 | 035 | NOT STARTED |
| 037 | Tadka / Tempering Slider | R2 | P0 | 036 | NOT STARTED |
| 038 | Family Recipe Splitter Nutrition Engine | R2 | P0 | 036 | NOT STARTED |
| 039 | Food Search | R1 | P0 | 033A,034 | NOT STARTED |
| 039A | Semantic Recipe Search with pgvector (PROPOSED) | R3 | P2 | 039 | NOT STARTED |
| 040 | Manual Food Logging | R1 | P0 | 023,034,035,036,039 | NOT STARTED |
| 041 | Recipe Creation | R1 | P1 | 040 | NOT STARTED |
| 042 | Nutrition Goals | R1 | P1 | 040 | NOT STARTED |
| 043 | Dynamic TDEE Engine | R2 | P0 | 026,027,040,042 | NOT STARTED |
| 044 | Nutrition Dashboard | R1 | P0 | 040,042 | NOT STARTED |
| 045 | Workout Data Model | R1 | P0 | 020 | NOT STARTED |
| 046 | Workout Library | R1 | P1 | 045 | NOT STARTED |
| 047 | Workout Planner | R1 | P1 | 046 | NOT STARTED |
| 048 | Workout Logging | R1 | P0 | 023,045 | NOT STARTED |
| 049 | Recovery Basics | R2 | P1 | 025,028,048 | NOT STARTED |
| 050 | Health Integration Abstraction | R1 | P0 | 023,025 | NOT STARTED |
| 051 | Android Health Connect | R1 | P0 | 050 | NOT STARTED |
| 052 | iOS Apple Health / HealthKit | R1 | P0 | 050 | NOT STARTED |
| 053 | Health Background Sync | R1 | P0 | 051,052 | NOT STARTED |
| 054 | DIP Domain Contract | R1 | P0 | 025,044 | NOT STARTED |
| 055 | DIP Rule Engine | R1 | P0 | 054 | NOT STARTED |
| 056 | Contextual Dashboard Assembly | R1 | P0 | 055 | NOT STARTED |
| 057 | Daily Readiness Score | R2 | P1 | 049,055 | NOT STARTED |
| 058 | Server-Side AI Gateway | R2 | P0 | 012C | NOT STARTED |
| 059 | AI Structured Output Contracts | R2 | P0 | 058 | NOT STARTED |
| 060 | AI Meal Analyzer | R2 | P0 | 033A,059 | NOT STARTED |
| 061 | Hinglish Coaching Layer | R2 | P0 | 010,059 | NOT STARTED |
| 062 | AI Photo Food Logging | R2 | P1 | 060,063A | NOT STARTED |
| 063 | AI Safety and Medical Boundary | R2 | P0 | 059 | NOT STARTED |
| 063A | AI and WhatsApp Media Retention and Deletion | R2 | P0 | 058,063 | NOT STARTED |
| 064 | WhatsApp Integration Contract | R2 | P0 | 058 | NOT STARTED |
| 064A | WhatsApp Account Linking and Consent | R2 | P0 | 064,014 | NOT STARTED |
| 065 | WhatsApp Text Logging | R2 | P0 | 060,064A | NOT STARTED |
| 066 | WhatsApp Voice Logging | R2 | P0 | 065 | NOT STARTED |
| 067 | WhatsApp User Confirmation | R2 | P0 | 065 | NOT STARTED |
| 068 | WhatsApp Coaching Reply | R2 | P1 | 067,086 | NOT STARTED |
| 069 | Fasting Mode | R2 | P1 | 086 | NOT STARTED |
| 070 | AQI-Aware Workout Recommendations | R3 | P2 | 055 | NOT STARTED |
| 071 | Indian Festival Context | R3 | P2 | 069 | NOT STARTED |
| 072 | Menstrual Cycle | R3 | P2 | 029,025 | NOT STARTED |
| 073 | PCOS Lifestyle Tracking | R3 | P2 | 072 | NOT STARTED |
| 074 | Menopause / Pregnancy Boundaries | R3 | P2 | 072 | NOT STARTED |
| 075 | Family Groups | R3 | P1 | 012B | NOT STARTED |
| 076 | Family Consent and Permissions | R3 | P1 | 075 | NOT STARTED |
| 077 | Family Health Data Sharing | R3 | P1 | 076,032B | NOT STARTED |
| 078 | Family Care Dashboard | R3 | P1 | 077 | NOT STARTED |
| 078A | Family Crisis Alert Guardrails | R3 | P1 | 078 | NOT STARTED |
| 079 | Subscription Domain | R1 | P0 | 008A | NOT STARTED |
| 080 | Razorpay Server Integration Boundary | R1 | P0 | 012C,079 | NOT STARTED |
| 081 | UPI Payment Flow | R1 | P0 | 080 | NOT STARTED |
| 082 | UPI AutoPay | R2 | P0 | 081 | NOT STARTED |
| 083 | Razorpay Webhooks | R1 | P0 | 080 | NOT STARTED |
| 084 | Entitlement Engine | R1 | P0 | 083 | NOT STARTED |
| 084A | Paywall, Plan Selection and Feature Gating UI | R1 | P0 | 084 | NOT STARTED |
| 084B | Sachet Sprints | R2 | P2 | 084 | NOT STARTED |
| 085 | AdMob Foundation | R2 | P1 | 084,010 | NOT STARTED |
| 086 | Notification Infrastructure | R1 | P0 | 008A,010 | NOT STARTED |
| 087 | Karma Points | R2 | P2 | 055 | NOT STARTED |
| 088 | Squads and Collective Challenges | R3 | P2 | 087,075 | NOT STARTED |
| 089 | Data Vault | R2 | P0 | 091 | NOT STARTED |
| 090 | Data Export | R2 | P0 | 012C | NOT STARTED |
| 091 | Right-to-Erasure | R2 | P0 | 012B,019 | NOT STARTED |
| 092 | RLS and Authorization Hardening | R1 | P0 | 012B | NOT STARTED |
| 092A | Rate Limiting and Abuse Prevention | R2 | P0 | 012C,092 | NOT STARTED |
| 093 | FitKarma Hub Foundation | R3 | P2 | 012B | NOT STARTED |
| 094 | Indian Food Database Administration | R3 | P2 | 093,033A | NOT STARTED |
| 095 | Open Food Facts Integration | R2 | P2 | 033A | NOT STARTED |
| 096 | Indian Dataset Ingestion | R1 | P0 | 033A | NOT STARTED |
| 097 | Responsible Scraping Pipeline | R3 | P2 | 096 | NOT STARTED |
| 098 | Product Analytics Contract | R2 | P1 | 086 | NOT STARTED |
| 099 | Retention Loop Instrumentation | R2 | P1 | 098 | NOT STARTED |
| 099A | SLOs, Alerting and KPI Validation (PROPOSED) | R2 | P1 | 099 | NOT STARTED |
| 100 | Testing Architecture | R1 | P0 | 005 | NOT STARTED |
| 101 | Nutrition Test Suite | R1 | P0 | 040 | NOT STARTED |
| 102 | Offline and Sync Test Suite | R1 | P0 | 023 | NOT STARTED |
| 103 | Authentication/Security Test Suite | R1 | P0 | 092 | NOT STARTED |
| 104 | AI Test Suite | R2 | P0 | 060 | NOT STARTED |
| 105 | Payment Test Suite | R1 | P0 | 084 | NOT STARTED |
| 106 | GitHub Actions CI | R1 | P0 | 100 | NOT STARTED |
| 107 | Android Build Pipeline | R1 | P0 | 106 | NOT STARTED |
| 108 | iOS Build Pipeline | R1 | P0 | 106 | NOT STARTED |
| 109 | Dependency and Vulnerability Review | R1 | P1 | 106 | NOT STARTED |
| 110 | Performance Optimization | PL | P0 | — | NOT STARTED |
| 111 | Offline Production Audit | PL | P0 | — | NOT STARTED |
| 112 | Security Production Audit | PL | P0 | — | NOT STARTED |
| 112A | Backup, Restore and Migration Rollback Drill | PL | P0 | 112 | NOT STARTED |
| 113 | Privacy / DPDP Readiness Audit | PL | P0 | — | NOT STARTED |
| 113A | Legal Review Package | PL | P0 | 113 | NOT STARTED |
| 114 | Accessibility and Localization Audit | PL | P1 | — | NOT STARTED |
| 115 | Final Product Consistency Audit | PL | P0 | — | NOT STARTED |
| 116 | Production Checklist Completion | PL | P0 | — | NOT STARTED |
| 116A | Store Submission Readiness | PL | P0 | 116 | NOT STARTED |
| 117 | End-to-End Smoke Test | PL | P0 | — | NOT STARTED |
| 118 | Release Candidate Hardening | PL | P0 | 117 | NOT STARTED |
| 119 | CGM Integration Architecture | R3 | P2 | 032B | NOT STARTED |
| 120 | ABHA / ABDM Integration | R3 | P2 | — | NOT STARTED |
| 121 | Grocery Integration | R3 | P2 | — | NOT STARTED |
| 122 | Corporate Wellness | R3 | P2 | 093 | NOT STARTED |
| 122A | Biological Age Estimation (PROPOSED) | R3 | P2 | 043,119 | NOT STARTED |
| 122B | Clinical Dossier Generation | R3 | P2 | 076,090 | NOT STARTED |
| 122C | Elite Tier Services Readiness | R3 | P3 | 084 | NOT STARTED |

---

# REVISION NOTES — v1.0 → v1.1

**Preserved:** all 122 original tasks, their prompts, the deferred list, the Definition of Done and the strategic build order. Nothing was removed.

**Fixed**
- Agent file path corrected to `.agent/skills/SKILL.md`; master spec path corrected to `FitKarma_Master_Documentation_v1.md`.
- TASK 001 now lists every Brain document explicitly.
- TASK 066 language priority aligned with the master doc (Hinglish P0, Hindi P1, Tamil/Telugu P2).
- Removed a hidden zero-width character from the TASK 018 heading.
- Ordering problems called out (backend before auth, Drift before profile, payments foundation is R1).

**Added**
- Metadata block (roadmap, priority, dependencies, Brain docs, microtask IDs, done-when) on every task.
- Phase gates for all 24 phases.
- 24 new tasks (suffix letters) covering gaps versus the Brain docs: doc wiring (001A), remote config (008A), Supabase workspace/baseline schema/Edge scaffold (012A–C), Realtime (023A), conflict UX (024A), habits and BP/glucose (032A–B), food catalog seeding (033A), pgvector search (039A), media retention (063A), WhatsApp linking (064A), crisis guardrails (078A), paywall and sachets (084A–B), rate limiting (092A), SLOs (099A), backup/restore drill (112A), legal package (113A), store readiness (116A), biological age / clinical dossier / Elite readiness (122A–C).
- Progress tracker, roadmap execution groups, microtask and ADR traceability, and an open-decisions register.