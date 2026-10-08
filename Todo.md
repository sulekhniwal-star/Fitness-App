# FitKarma — From-Scratch Implementation TODO
## Version 1.0 — Greenfield Build Plan

> This TODO is for a **completely new FitKarma application built from scratch**.
> Assume there is currently **no application code** unless the repository inspection proves otherwise.
>
> The implementation agent must use:
>
> - `.agent/skills/SKILLS.md` as the highest-level agent skill/instruction file
> - `FitKarma_Master_Documentation_v1.0.md` as the root-level master specification
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

Read .agent/skills/SKILLS.md, FitKarma_Master_Documentation_v1.0.md, the relevant Brain documentation, and inspect the repository before making changes.

Do not continue to the next task automatically.
```

After a task finishes, paste the next task.

The agent must never silently implement later tasks.

---

# GLOBAL EXECUTION RULES

Every task must follow this sequence:

1. Read `.agent/skills/SKILLS.md`.
2. Read the root `FitKarma_Master_Documentation_v1.0.md`.
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

---

# PHASE 0 — REPOSITORY INITIALIZATION & ENGINEERING FOUNDATION

## TASK 001 — Repository and Environment Audit

Prompt:

```text
Perform a complete greenfield repository audit for FitKarma.

Read:
- .agent/skills/SKILLS.md
- FitKarma_Master_Documentation_v1.0.md
- Brain/master_rules.md
- Brain/pdr.md
- Brain/trd.md
- Brain/architecture.md
- Brain/decisions.md
- all other relevant Brain documentation

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

## TASK 002 — Bootstrap Flutter Application

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

# PHASE 1 — DESIGN SYSTEM & UI FOUNDATION

## TASK 009 — FitKarma Design System

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

Separate UI localization from AI-generated conversational phrasing.

Add tests for:
- locale switching
- missing translation fallback
- no hard-coded user-facing strings in newly created UI
```

---

## TASK 011 — Accessibility Foundation

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

# PHASE 2 — AUTHENTICATION, USER PROFILE & ONBOARDING

## TASK 013 — Supabase Client Foundation

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

## TASK 018 — Dosha/W​ellness Profile Foundation

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

## TASK 020 — Drift + SQLCipher Local Database

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

## TASK 024 — Offline Mode UX

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

# PHASE 4 — HEALTH DATA CORE

## TASK 025 — Core Health Domain

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

# PHASE 5 — INDIAN NUTRITION ENGINE

## TASK 033 — Food Domain and Data Model

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

## TASK 034 — Indian Portion System

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

## TASK 040 — Manual Food Logging

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

## TASK 045 — Workout Data Model

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

## TASK 050 — Health Integration Abstraction

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

## TASK 054 — DIP Domain Contract

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

## TASK 058 — Server-Side AI Gateway

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

# PHASE 10 — WHATSAPP AI LOGGING

## TASK 064 — WhatsApp Integration Contract

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

## TASK 065 — WhatsApp Text Logging

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

Support the documented language direction:
- Hinglish
- Hindi
- Tamil
- Telugu

Build graceful fallbacks for:
- failed transcription
- unsupported audio
- ambiguous food
- low confidence
- provider timeout
```

---

## TASK 067 — WhatsApp User Confirmation

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

## TASK 069 — Fasting Mode

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

## TASK 072 — Menstrual Cycle

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

Prompt:

```text
Implement the documented architecture for menopause and pregnancy-related functionality only to the level actually specified.

Do not invent medical protocols.

Create opt-in data models and feature-gating boundaries.

Any undefined clinical behavior must be marked OPEN DECISION.
```

---

# PHASE 13 — FAMILY HEALTH

## TASK 075 — Family Groups

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

# PHASE 14 — MONETIZATION & RAZORPAY

## TASK 079 — Subscription Domain

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

# PHASE 15 — ADS, NOTIFICATIONS & ENGAGEMENT

## TASK 085 — AdMob Foundation

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

## TASK 089 — Data Vault

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

# PHASE 17 — ADMIN / FITKARMA HUB

## TASK 093 — FitKarma Hub Foundation

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

## TASK 095 — Open Food Facts Integration

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

## TASK 098 — Product Analytics Contract

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

# PHASE 20 — TESTING & QUALITY

## TASK 100 — Testing Architecture

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

## TASK 106 — GitHub Actions CI

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

## TASK 110 — Performance Optimization

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

## TASK 113 — Privacy / DPDP Readiness Audit

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

## TASK 114 — Accessibility and Localization Audit

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

## TASK 117 — End-to-End Smoke Test

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

These tasks should be performed only after the core app is stable.

## TASK 119 — CGM Integration Architecture

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

---

# TASK STATUS TEMPLATE

Use this format when recording progress:

```text
## TASK XXX — <title>

Status: NOT STARTED / IN PROGRESS / COMPLETE / BLOCKED

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
