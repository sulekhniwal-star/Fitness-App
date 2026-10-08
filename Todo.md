# FitKarma — Antigravity IDE Implementation TODO

## How to use this file

Paste **one task prompt at a time** into Antigravity IDE, in order.

After each task:
1. Let the agent inspect the repository and documentation before changing code.
2. Review the diff.
3. Run the requested tests/checks.
4. Only then continue to the next task.

The prompts intentionally tell the agent to inspect the real codebase first. Do not assume the current implementation exactly matches the documentation.

---

## TASK 001 — Repository + Documentation Audit

```text
You are working on the existing FitKarma application repository.

Before writing code, first inspect the repository structure and enumerate `Brain/`. Then read and follow:
- `.agent/skills/SKILLS.md`
- `FitKarma_Master_Documentation_v3.md`
- Brain/master_rules.md
- Brain/pdr.md
- Brain/trd.md
- Brain/architecture.md
- Brain/decisions.md
- the relevant domain documents in Brain/
- the existing source code, database migrations, tests, configuration, and CI files.

Do a full implementation-vs-documentation audit.

Your goals:
1. Identify the actual current Flutter/Dart architecture.
2. Identify current Supabase schema and migrations.
3. Identify current API/Edge Function boundaries.
4. Identify current payment implementation and every RevenueCat reference.
5. Identify existing nutrition, food logging, AI, health integrations, offline sync, family, women's health, Ayurveda, notification, analytics, and subscription functionality.
6. Identify what is already implemented, partially implemented, stubbed, or absent.
7. Detect documentation/code contradictions.
8. Do NOT implement new product features yet.

Produce:
- an implementation inventory in the repository (preferably Brain/implementation_audit.md unless an equivalent existing document already exists);
- a prioritized gap list mapped to the Todo task IDs in Todo.md;
- a list of open decisions that must be resolved before implementation.

Important:
- Treat PROPOSED and OPEN DECISION documentation as non-authoritative until confirmed.
- Do not invent endpoints, tables, packages, or providers.
- Do not delete existing working functionality merely because it is not highlighted in the strategy.
- Keep changes limited to this audit/documentation task.

Validation:
- Run the existing test/lint commands if safe.
- Report exact commands and results.
```

---

## TASK 002 — Documentation/Code Consistency Foundation

```text
Read .agent/skills/SKILLS.md and the master/domain documentation before coding.

Using the implementation audit from TASK 001, establish a clean documentation-to-code baseline.

Fix only documentation inconsistencies that are clearly confirmed by the actual codebase. Do not invent behavior.

Requirements:
- The master docs remain the high-level source.
- /docs remain domain-level source of truth.
- Major architectural changes must be recorded in Brain/decisions.md.
- Any newly discovered but unresolved architecture point must be marked OPEN DECISION.
- Keep RevenueCat only as historical migration context; it must not remain an active payment dependency.

Add or update implementation notes only where they are supported by the repository.

Run tests/lint after changes.
```

---

## TASK 003 — Payment Migration Inventory: RevenueCat → Razorpay

```text
Read:
- .agent/skills/SKILLS.md
- Brain/master_rules.md
- Brain/architecture.md
- Brain/data_model.md
- Brain/api_contract.md
- Brain/security.md
- Brain/decisions.md
- the existing payment/subscription source code.

Implement only the first stage of the payment migration:
- remove active RevenueCat package usage and runtime references;
- preserve historical references only where explicitly required in decisions/changelog;
- identify all subscription, entitlement, paywall, purchase-restore, webhook, and billing logic that must be migrated;
- introduce a clean provider boundary if the existing architecture lacks one.

Do NOT implement the complete Razorpay integration in this task.
Do NOT remove currently working paywall UX unless necessary to remove the provider dependency.

Acceptance:
- No active RevenueCat dependency remains.
- No runtime import/reference to RevenueCat remains.
- Existing app still builds/tests as far as the current environment permits.
- Migration gaps are clearly recorded.
```

---

## TASK 004 — Razorpay Backend Foundation

```text
Read the payment, architecture, API, security, and decision documents first.

Implement the Razorpay backend foundation using the actual existing Supabase/Edge Function architecture.

Requirements:
- Server-side Razorpay API access only.
- Client receives only public Razorpay identifiers and safe server-issued IDs.
- Secrets remain server-side.
- Create a provider service/repository boundary.
- Define the minimum required server functions/contracts based on the documented architecture and actual codebase.
- Do not create fake endpoints or tables without documenting them as PROPOSED.
- Keep entitlement decisions server-authoritative.

Add unit/integration tests around the provider boundary and secret handling.
Update docs only for behavior actually implemented.
```

---

## TASK 005 — Razorpay Webhook Verification + Idempotency

```text
Implement the Razorpay webhook pipeline.

Read .agent/skills/SKILLS.md plus payment/security/error/testing documents.

Requirements:
- verify webhook signatures server-side;
- reject invalid signatures;
- process events idempotently;
- handle duplicate and delayed events safely;
- persist only the minimum webhook/payment data needed by the documented architecture;
- update entitlements from verified server events, never from client success callbacks;
- return safe errors without leaking secrets.

Add tests for:
- valid webhook;
- invalid signature;
- duplicate webhook;
- delayed/out-of-order webhook;
- malformed payload;
- replay attempt.
```

---

## TASK 006 — Subscription State Machine + Entitlements

```text
Implement the documented subscription state machine using the existing architecture.

States to support where applicable:
created, pending, mandate_authorized, active, renewal_pending, payment_failed, grace_period, cancelled, expired, refunded.

Requirements:
- server-authoritative entitlement calculation;
- idempotent transitions;
- safe handling of retries;
- correct downgrade/expiry behavior;
- no client-side entitlement authority;
- UI reads entitlement state from the authoritative source.

Do not invent business rules that are not in the docs. For any missing transition rule, mark OPEN DECISION rather than guessing.

Add state-transition tests.
```

---

## TASK 007 — UPI + UPI AutoPay UX and Contract

```text
Implement the UPI-first subscription flow described in the FitKarma documentation.

Read Brain/pdr.md, Brain/trd.md, Brain/architecture.md, Brain/api_contract.md, Brain/ui_spec.md, Brain/security.md, Brain/decisions.md.

Implement:
- plan selection;
- order/subscription creation through backend;
- UPI authorization flow supported by the chosen Razorpay integration;
- server confirmation;
- mandate lifecycle display;
- safe handling of pending/failed/cancelled states;
- clear user messaging.

Do not trust the client callback as the final payment truth.
Do not store UPI PIN, CVV, bank credentials, or full card data.

Use actual available Razorpay SDK/API capabilities; where provider-specific details are unresolved, document an OPEN DECISION instead of fabricating an API.

Add widget/integration tests for success, pending, failure, cancellation, and retry flows.
```

---

## TASK 008 — Configurable Pricing + Plan Enforcement

```text
Implement configurable product plans rather than hard-coded pricing logic.

Plans documented by FitKarma:
- Yogi Free
- Karma Pro
- FitKarma Elite
- Sachet Sprints

Requirements:
- pricing/config should be backend-driven where architecture permits;
- enforce entitlements on the server and client UI;
- support monthly/yearly plan variants where documented;
- preserve a free path;
- do not expose premium health/payment features when entitlement is absent.

Do not invent exact commercial SKUs if they are not defined.
Mark unresolved billing SKU/provider details as OPEN DECISION.

Add tests for entitlement gating and plan configuration.
```

---

## TASK 009 — Indian Portion Data Model

```text
Implement the Indian nutrition portion model.

Read Brain/data_model.md, Brain/pdr.md, Brain/trd.md, Brain/api_contract.md, Brain/ui_spec.md.

Support the documented units such as:
- katori
- glass
- spoon
- piece
- serving
- roti count
- idli count
- percentage of a family recipe

Requirements:
- portion definitions are data-driven;
- units can map to food-specific standard quantities;
- UI clearly shows the selected portion;
- nutrition calculations use the normalized quantity;
- offline persistence works.

Do not invent authoritative nutrition values. Use existing database values or clearly mark missing values for data curation.

Add model/calculation tests.
```

---

## TASK 010 — Raw vs Cooked Nutrition + Cooking Multipliers

```text
Implement the raw/cooked food model from the FitKarma documentation.

Read Brain/data_model.md and the nutrition sections of pdr/trd/api/ui/testing.

Requirements:
- distinguish raw and cooked food states;
- store preparation/cooking state where needed;
- support cooking multipliers;
- account for water absorption and evaporation through documented multipliers;
- never assume 100 g raw food equals 100 g cooked food;
- keep calculations deterministic and testable.

Use existing confirmed schema/data where available. If a new schema element is required and only proposed in docs, mark it PROPOSED and document the migration before implementing it.

Add calculation and regression tests.
```

---

## TASK 011 — Tadka / Tempering Slider

```text
Implement the Tadka/Tempering Slider for Indian meal logging.

Support:
- Low
- Medium
- High

Use it to estimate added oil/ghee/butter/tempering fat only where the food record is designed to accept an estimate.

Requirements:
- the result must be clearly labeled as an estimate;
- the estimate must be deterministic and testable;
- the selected level is stored with the log;
- offline use must work;
- API/database representations stay consistent.

Do not present the result as a laboratory-accurate measurement.
Add unit, widget, and nutrition regression tests.
```

---

## TASK 012 — Family Recipe Splitter

```text
Implement Family Recipe Splitter.

Concept:
A user can enter the full household recipe and then record the fraction they personally consumed, such as 25%.

Requirements:
- household recipe ingredients and total nutrition are calculated;
- user can choose a consumption percentage;
- personal nutrition is derived deterministically;
- works offline;
- sync is idempotent;
- the UI makes clear that the allocation is an estimate when inputs are estimated.

Example data from the docs may be used as a test fixture, not as hard-coded product data.

Add model, calculation, offline, sync, and widget tests.
```

---

## TASK 013 — Nutrition Logging UX Simplification

```text
Refine the food logging experience around the India-first workflow.

Read Brain/ui_spec.md plus the nutrition/product documents.

The logging flow should minimize friction while supporting:
- Indian food selection;
- common Indian portion units;
- raw/cooked state;
- Tadka estimate;
- family recipe percentage;
- manual correction;
- uncertainty/estimation indicators.

Do not redesign the whole application.
Do not create dashboard bloat.
Preserve existing working flows unless the docs explicitly replace them.

Add/update widget tests for the affected flows.
```

---

## TASK 014 — WhatsApp Text Logging Backend Contract

```text
Implement the WhatsApp text logging backend contract.

Read Brain/architecture.md, Brain/api_contract.md, Brain/data_sources.md, Brain/security.md, Brain/error_handling.md.

Flow:
WhatsApp → text processing → language detection → AI extraction → Indian food database → portion estimation → nutrition calculation → user confirmation → food log → DIP.

Requirements:
- authenticated webhook verification where required by the provider;
- normalize inbound messages;
- isolate AI provider code behind an adapter;
- return structured candidates, not free-form database writes;
- require confirmation when uncertainty is material;
- make repeated inbound events idempotent;
- log only data allowed by the privacy specification.

Do not invent Meta API details where the existing codebase/docs do not specify them. Use PROPOSED/OPEN DECISION for unresolved provider details.

Add fixture/integration tests.
```

---

## TASK 015 — WhatsApp Voice Logging

```text
Implement WhatsApp voice-note logging on top of the text logging contract.

Requirements:
- receive/process the voice message through the supported WhatsApp integration;
- obtain a transcript using the existing/approved audio model adapter;
- support Hinglish and the documented language set;
- pass transcript into the same deterministic food extraction pipeline as text;
- provide confidence/uncertainty;
- require user confirmation where ambiguity is material;
- preserve idempotency and privacy.

Do not duplicate business logic between voice and text pipelines.

Add audio fixture tests, parser tests, and integration tests.
```

---

## TASK 016 — Hinglish / Indian Language Intelligence

```text
Expand conversational food logging to the documented language strategy.

Prioritize:
- Hinglish P0
- Hindi P1
- Tamil P2
- Telugu P2

Requirements:
- UI remains consistent with the localization strategy;
- AI prompts/extraction support bilingual and mixed-language input;
- food entities are normalized to the Indian food database;
- user-visible confirmation uses the user's supported language preference;
- avoid unsupported translation assumptions;
- keep clinical/evidence-based content distinct from cultural phrasing.

Add localization and parser fixture tests for representative mixed-language examples.
```

---

## TASK 017 — AI Meal Analyzer + Confirmation System

```text
Harden the AI meal analyzer.

Requirements:
- structured JSON/schema validation;
- deterministic normalization after model output;
- confidence/uncertainty fields;
- human confirmation for materially ambiguous food/portion interpretations;
- fallback to manual logging on AI failure;
- no unsupported medical claims;
- token/cost efficient routing consistent with the Health OS Brain strategy.

Add tests for malformed model output, low confidence, hallucinated food names, missing portions, and provider failure.
```

---

## TASK 018 — AI Food Photo Logging (P1)

```text
Implement the P1 AI photo food logging flow.

Flow:
Photo → food detection → Indian dish recognition → portion estimation → nutrition estimation → user confirmation → food log.

Requirements:
- explicit user confirmation before materially uncertain logs are finalized;
- show uncertainty clearly;
- use approved vision model adapter;
- respect photo retention/deletion policy;
- provide manual fallback;
- do not claim perfect recognition;
- do not expose sensitive images unnecessarily;
- integrate with existing Indian nutrition/portion model.

Add vision fixture tests, privacy/deletion tests, and widget tests.
```

---

## TASK 019 — Dynamic TDEE Engine

```text
Implement the adaptive Dynamic TDEE engine.

Inputs documented by FitKarma:
- body weight
- weight trend
- calorie intake
- activity
- steps
- workouts
- goal
- historical data

Requirements:
- deterministic calculation layer separated from AI;
- documented adjustment rules;
- confidence level;
- user override;
- insufficient-data state;
- guardrails against extreme recommendations;
- reproducible calculations.

Do not invent a medical or scientifically authoritative formula where the documentation leaves it open. First determine whether an existing implementation/formula exists in the repository. If not, document the exact proposed algorithm in Brain/decisions.md before implementation.

Add extensive math/regression tests.
```

---

## TASK 020 — Daily Intelligence Package (DIP) Orchestration

```text
Implement or refine the Daily Intelligence Package as the central orchestration layer.

Read Brain/architecture.md, Brain/pdr.md, Brain/ui_spec.md and the current home/dashboard implementation.

Requirements:
- combine relevant health signals into a concise daily state;
- avoid redundant AI calls;
- produce actionable micro-actions;
- expose readiness/recovery/nutrition information based on context;
- allow the dashboard to be assembled contextually;
- avoid showing every module at once.

Do not invent new health scoring formulas without documenting them as PROPOSED.

Add deterministic orchestration tests and UI tests.
```

---

## TASK 021 — Health Connect Integration

```text
Implement the documented Android Health Connect integration.

Read Brain/architecture.md, Brain/data_sources.md, Brain/security.md, Brain/api_contract.md, Brain/testing.md.

Requirements:
- explicit permission handling;
- source attribution;
- data normalization;
- incremental/background synchronization according to platform capabilities;
- offline outbox handling;
- duplicate detection;
- conflict handling;
- deletion/revocation handling;
- no unnecessary direct wearable integrations when Health Connect is sufficient.

Use real platform capabilities available in the repository. Do not fake background behavior if it is not supported.

Add integration tests/mocks and permission/error tests.
```

---

## TASK 022 — Apple Health / HealthKit Integration

```text
Implement the iOS counterpart using Apple Health/HealthKit.

Match the normalized health data contract established by the Android Health Connect implementation.

Support the documented data categories only where the current code/docs justify them.

Requirements:
- permission UX;
- source attribution;
- normalization;
- sync;
- deletion/revocation;
- offline persistence where applicable;
- consistent repository interface across Android/iOS.

Add platform-aware tests and keep unsupported platform code safely isolated.
```

---

## TASK 023 — Health Sync Engine Hardening

```text
Harden the offline-first health synchronization engine.

Read Brain/master_rules.md, Brain/architecture.md, Brain/error_handling.md, Brain/testing.md.

Requirements:
- local-first writes;
- outbox queue;
- idempotent retries;
- exponential/backoff strategy where already supported by architecture;
- duplicate prevention;
- conflict policy;
- partial failure recovery;
- safe resume after app restart;
- no loss of user-entered health data.

Do not replace Drift with another persistence system.

Add offline/retry/conflict tests.
```

---

## TASK 024 — Family Care Dashboard Data Permissions

```text
Implement the Family Care Dashboard foundation.

Required security model:
- explicit affirmative consent;
- role-based access;
- revocation;
- data minimization.

Potential health data includes steps, weight, sleep, BP, CGM, medication, and activity, but only implement fields supported by the existing data model.

Requirements:
- clear relationship/permission model;
- server-side authorization;
- RLS coverage;
- easy consent revocation;
- no silent monitoring;
- auditability.

Add authorization/RLS tests and widget tests for consent/revocation.
```

---

## TASK 025 — Family Health UX

```text
Implement the Family Care Dashboard UX around the permission model from TASK 024.

User experience should support:
- inviting/linking a family member;
- consent state;
- allowed health summaries;
- alerts only where explicitly configured;
- revocation;
- privacy explanation.

Do not expose raw health data beyond the granted permission scope.
Do not add unrelated social-feed functionality.

Add widget/accessibility tests.
```

---

## TASK 026 — Festival / Fasting Mode

```text
Implement user-selected fasting/festival modes.

Supported documented examples:
- Navratri
- Ramzan
- Karwa Chauth
- other user-defined fasting periods where architecture allows.

Requirements:
- user opt-in only;
- never infer religion automatically;
- adapt notifications/meal reminders/hydration/recommendations;
- avoid "you haven't eaten" messaging during active fasting periods;
- allow start/end editing;
- respect timezone/date boundaries;
- keep medical advice conservative.

Add state, scheduling, and notification tests.
```

---

## TASK 027 — AQI-Aware Workout Recommendations

```text
Implement optional AQI-aware workout recommendations.

Requirements:
- use the configured/approved AQI source from Brain/data_sources.md;
- respect location permissions and privacy;
- cache appropriately for offline use;
- use documented thresholds where available;
- recommend indoor alternatives when outdoor conditions are poor;
- do not claim medical certainty;
- make the feature optional and dismissible.

If the exact AQI provider/API is not yet decided, document an OPEN DECISION instead of inventing one.

Add service, caching, threshold, permission, and widget tests.
```

---

## TASK 028 — Ayurveda Wellness Layer Guardrails

```text
Review and implement/refine Ayurveda functionality according to the documentation.

Ayurveda must remain a cultural/wellness personalization layer, not a replacement for medicine.

Requirements:
- clearly separate traditional wellness concepts from evidence-based metrics;
- no disease-curing claims;
- no diagnosis presented as medical fact;
- contextual recommendations can include seasonal eating/lifestyle guidance where already designed;
- preserve user choice and avoid culturally insensitive assumptions.

Audit all current Ayurveda text/content and fix claims that violate these rules.
Add content/UX tests where practical.
```

---

## TASK 029 — Women's Health Expansion

```text
Audit and implement the documented women's health functionality using the existing architecture.

Relevant areas:
- menstrual cycle
- cycle-aware training
- PCOS lifestyle tracking
- symptoms
- menopause
- pregnancy-related functionality where supported.

Requirements:
- treat the data as sensitive health information;
- encryption/security/privacy controls must match the security docs;
- avoid unsupported diagnosis/treatment claims;
- integrate relevant nutrition/CGM signals only where the docs explicitly support the relationship;
- preserve user control over visibility.

Add privacy, authorization, calculation, and UI tests.
```

---

## TASK 030 — Data Vault / Privacy UX

```text
Implement the FitKarma Data Vault privacy experience.

Support the documented concepts:
- see what is stored locally vs cloud;
- export my data;
- erase my existence;
- clear explanation of data categories;
- deletion status/audit receipt where supported.

Requirements:
- never claim deletion completed unless the backend confirms it;
- deletion must include all documented data/storage relationships;
- sensitive health data must not leak through logs/analytics;
- ensure family, AI, WhatsApp, and payment-related data are handled consistently with their retention policies.

Add end-to-end deletion/export tests and permission tests.
```

---

## TASK 031 — Notifications and Retention Loop

```text
Implement/refine the documented FitKarma retention loop without becoming spammy.

Core loop:
WhatsApp/food input → insight → app readiness/DIP → micro-action → Karma reward.

Requirements:
- actionable notification content;
- contextual frequency controls;
- respect fasting mode;
- do not notify users about sensitive information in unsafe wording;
- premium/free differences must respect entitlement rules;
- avoid notification fatigue.

Add notification logic tests.
```

---

## TASK 032 — Karma Points + Functional Gamification

```text
Implement functional gamification only.

Use documented concepts:
- Karma points;
- progression rings;
- squads/collective challenges where already present;
- tangible rewards integration only where actually supported.

Do not build an Instagram-style fitness social feed.

Requirements:
- rewards cannot override health/safety constraints;
- server-authoritative point issuance for valuable/redeemable rewards;
- idempotent event handling;
- abuse prevention.

Add unit/security tests.
```

---

## TASK 033 — Quick-Commerce Grocery Integration Boundary

```text
Prepare the grocery integration boundary for future Zepto/Blinkit-style integrations.

Do not pretend a partner API exists unless the repository/docs confirm it.

Implement only:
- normalized grocery list model;
- export/integration interface;
- provider adapter boundary;
- privacy/consent behavior;
- fallback to manual cart/list.

Mark any external commercial/API dependency as OPEN DECISION if unresolved.
Add unit tests around the adapter boundary.
```

---

## TASK 034 — AdMob Specification + Safe Placement

```text
Implement/refine AdMob according to Brain/admob_spec.md.

Requirements:
- ads only in permitted free-tier contexts;
- no interference with critical health, privacy, payment, consent, or deletion flows;
- no misleading health claims around ads;
- frequency limits;
- consent/privacy requirements;
- rewarded ads only where explicitly approved;
- premium experience remains ad-free where documented.

Audit current ad placements and fix unsafe placements.
Add UI tests where practical.
```

---

## TASK 035 — API Contract Conformance Audit

```text
Audit all implemented backend endpoints/services against Brain/api_contract.md.

For each implemented endpoint, verify:
- method
- route
- request schema
- response schema
- validation
- authentication
- authorization
- error handling
- rate limiting where implemented
- idempotency where relevant.

Do not create fictional endpoints merely to satisfy documentation.
Update docs only when the actual implementation is authoritative and intentional.
Create a gap report for missing or divergent contracts.
```

---

## TASK 036 — Error Handling Standardization

```text
Implement/refine the standardized error handling from Brain/error_handling.md.

Cover:
- network failures
- offline mode
- sync failures/conflicts
- authentication/authorization
- validation
- AI errors/uncertainty
- Razorpay/UPI/AutoPay
- webhook failures
- subscription failures
- third-party API failures.

Requirements:
- stable machine-readable error codes;
- safe user-facing messages;
- no secret leakage;
- retryability classification;
- centralized mapping where architecture permits.

Add unit and integration tests.
```

---

## TASK 037 — Security + RLS Audit

```text
Perform a security audit against Brain/security.md and Brain/master_rules.md.

Inspect:
- Supabase RLS;
- auth/session handling;
- SQLCipher/local storage;
- secrets;
- Edge Functions;
- family access;
- health data;
- AI/WhatsApp data;
- payment data;
- logs/analytics;
- deletion/export;
- rate limiting and abuse prevention.

Fix confirmed vulnerabilities and missing controls.
Do not weaken security to make features work.

Add regression tests for every security fix.
Produce a concise findings/fixes report.
```

---

## TASK 038 — Test Suite Expansion

```text
Implement the testing matrix in Brain/testing.md for the newly added functionality.

Prioritize:
- nutrition calculations;
- Tadka;
- Family Recipe Splitter;
- WhatsApp text/voice;
- AI uncertainty;
- photo recognition flow;
- TDEE;
- Health Connect/Apple Health adapters;
- family authorization;
- fasting;
- AQI;
- subscriptions;
- Razorpay webhooks;
- UPI AutoPay;
- offline sync;
- deletion.

Include edge cases from the documentation.
Do not delete or weaken existing tests.
```

---

## TASK 039 — Performance / Offline / Low-End Android Audit

```text
Audit FitKarma against the India Tier-2/Tier-3 offline-first strategy.

Focus on:
- startup time;
- APK/app payload size where measurable;
- database performance;
- offline operation;
- outbox size;
- sync efficiency;
- low-memory devices;
- battery impact;
- accessibility/legibility for older users.

Use profiling/measurement where available.
Make only evidence-based optimizations.
Do not introduce a new architecture without an ADR.
```

---

## TASK 040 — CI/CD + GitHub Actions Hardening

```text
Implement Brain/github_actions.md against the actual repository.

Pipeline should cover, as applicable:
- formatting;
- linting;
- flutter analyze;
- unit/widget/integration tests;
- database/RLS tests;
- dependency/security checks;
- secret scanning;
- Android builds;
- iOS builds;
- signed release workflow separation.

Never put secrets into the repository or workflow logs.
Use repository/environment secrets correctly.
Do not create signing credentials.
Add documentation for any required repository secrets as names/placeholders only.
```

---

## TASK 041 — Production Readiness Checklist

```text
Work through Brain/production_checklist.md against the real repository.

Audit:
- product flows;
- backend;
- database;
- RLS/security;
- privacy/DPDP workflows;
- AI;
- payments/Razorpay/UPI/AutoPay;
- Android/iOS permissions;
- offline mode;
- monitoring;
- analytics;
- Play Store/App Store readiness.

Fix concrete blockers discovered during the audit.
Do not mark an item complete unless evidence exists.
```

---

## TASK 042 — Remove/Defer Scope-Creep Features

```text
Audit the repository for features explicitly marked Deferred / Future / Not Recommended.

The strategy says not to prioritize:
- Instagram-style social feed;
- proprietary wearable hardware;
- expensive pose estimation as a core feature;
- heavy video-content production;
- low-retention experimental AI.

Do not blindly delete existing code. Instead:
- disable unfinished experimental features from production navigation if the docs require that;
- preserve reusable infrastructure when safe;
- move incomplete feature flags/routes into a deferred state;
- document any destructive removal as a decision.

Ensure the core product remains focused on nutrition + WhatsApp + offline + health aggregation.
```

---

## TASK 043 — Final Documentation/Implementation Synchronization

```text
Read all FitKarma documentation again after the implementation work.

Search the entire repository for:
RevenueCat
Razorpay
UPI
UPI AutoPay
subscription
payment
offline
Drift
Supabase
Health Connect
Apple Health
WhatsApp
AI
family
Ayurveda
DPDP

Resolve contradictions using this hierarchy:
1. confirmed existing implementation;
2. approved product strategy;
3. architecture decisions in Brain/decisions.md.

Critical rule:
RevenueCat must not appear as an active dependency. Historical mention is allowed only in decisions/changelog.

Update documentation for behavior that is now actually implemented.
Mark unresolved items PROPOSED or OPEN DECISION.
Do not invent missing API/table/provider details.
```

---

## TASK 044 — Final Full Regression + Release Candidate Audit

```text
Treat the current repository as a release candidate.

Read .agent/skills/SKILLS.md, Brain/master_rules.md, Brain/production_checklist.md, Brain/testing.md, Brain/security.md and Brain/decisions.md.

Run the strongest available full validation suite, including:
- Flutter format/analyze;
- unit/widget/integration tests;
- database/RLS tests;
- payment/webhook tests;
- offline/sync tests;
- platform builds where the environment supports them;
- security/dependency checks.

Then produce:
1. blockers;
2. warnings;
3. tests that passed;
4. tests that could not run and why;
5. remaining OPEN DECISION items;
6. exact next steps for production readiness.

Do not claim the app is production-ready unless the evidence supports it.
```

---

# Final operating rules for every task

- Always read `.agent/skills/SKILLS.md` before implementation.
- For major changes, read `master_rules.md`, `pdr.md`, `trd.md`, `architecture.md`, `decisions.md`, then the relevant domain document.
- Inspect the existing repository before making assumptions.
- Implement only the current task unless a dependency fix is strictly required.
- Do not start a large refactor unrelated to the task.
- Do not invent database tables, API routes, provider APIs, formulas, or third-party capabilities.
- Use `PROPOSED` or `OPEN DECISION` when the source documents do not define something.
- Preserve existing working features unless an approved strategy/decision explicitly changes them.
- Keep offline-first behavior explicit for every user-data feature.
- Keep health data, family data, AI data, WhatsApp data, and payment data subject to the documented security/privacy rules.
- Never trust client-side payment success for entitlement authority.
- Never store payment secrets, UPI PINs, CVV, or bank credentials.
- AI output must be validated and uncertainty surfaced.
- Do not make unsupported medical claims.
- Every feature needs appropriate tests.
- Every architectural change needs an ADR in `Brain/decisions.md`.
- Update documentation alongside implemented behavior.
- Prefer small, descriptive commits with no unrelated changes.
- Never commit secrets.
