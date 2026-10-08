# FitKarma Implementation & Documentation Audit (TASK 001)

> **Document Version**: 1.0.0  
> **Date**: 2026-10-08  
> **Workspace**: `F:\Fitness App`  
> **Status**: Completed Audit Baseline  

---

## 1. Executive Summary

FitKarma is positioned as **"India's smartest, most private Health OS that works where you are — on WhatsApp and offline."**

This audit evaluates the current state of the repository at `F:\Fitness App` against the product strategy and technical specifications defined in:
- `FitKarma_Master_Documentation_v3.md`
- `.agent/skills/SKILL.md`
- `Brain/` (18 domain specification documents)
- `Todo.md` (44 sequential implementation tasks)

### Core Finding
The repository currently contains the **complete specification and documentation baseline** (Master Documentation v3.1, 18 domain-specific specification files in `Brain/`, the AI agent skill in `.agent/skills/SKILL.md`, and the sequential execution roadmap in `Todo.md`), but **zero physical application source code, configuration files, database migrations, or test suites**.

Per user direction, legacy files from external locations (such as `F:\fitkarma`) are explicitly excluded. Consequently, this repository represents a **clean-slate implementation baseline**. All application domains (Flutter UI, Riverpod state, Drift/SQLCipher persistence, Supabase backend/RLS, Edge Functions, Razorpay payments, and Health integrations) are currently **Absent** in code and must be methodically implemented according to the sequential checklist in [Todo.md](file:///f:/Fitness%20App/Todo.md).

---

## 2. Implementation Inventory by Domain

### 2.1 Flutter/Dart Architecture
- **Documented Baseline**: Flutter 3.24+ / Dart 3.5+, Riverpod 2.x (`StateNotifierProvider`), feature-first domain separation, dark mode primary (`#0D0F12`), glassmorphism, spring physics, Bento grid layout.
- **Current Environment**:
  - Flutter SDK 3.47.6 (channel stable)
  - Dart SDK 3.13.5 (stable)
  - Windows x64 host
- **Repository Code State**: **Absent**
  - No `pubspec.yaml`
  - No `lib/` directory or Dart entry point (`main.dart`)
  - No UI components, themes, or routing
  - No Riverpod state providers or notifier implementations

### 2.2 Database, Local Persistence & Sync
- **Documented Baseline**:
  - Local: Drift + SQLCipher (ADR-001, ADR-003) for encrypted offline-first persistence.
  - Outbox: Local sync queue (`sync_queue`) with retry state, backoff, and idempotency keys.
  - Remote: Supabase Postgres with Universal Row-Level Security (RLS) on all user data.
  - Deletion Cascade: `delete_user_data` function covering 28 tables and storage assets.
- **Repository Code State**: **Absent**
  - No Drift table definitions or code generation setups
  - No SQLCipher encryption key management integration
  - No `supabase/` directory or SQL migrations
  - No pgTAP or SQL migration tests

### 2.3 Backend & API Boundaries
- **Documented Baseline**:
  - Supabase Edge Functions (Deno/TypeScript) for privileged operations.
  - Edge Functions own server secrets, Groq AI routing, Razorpay payment verification/webhooks, WhatsApp webhook processing, and deletion cascade orchestration.
  - Endpoints follow structured request/response envelopes with idempotency keys (`Brain/api_contract.md`).
- **Repository Code State**: **Absent**
  - No Edge Function definitions (`supabase/functions/`)
  - Supabase CLI is not currently installed or recognized in the system PATH
  - No TypeScript/Deno contracts implemented

### 2.4 Payment Infrastructure & RevenueCat Audit
- **Documented Baseline**:
  - Active Payment Rail: Razorpay + UPI + UPI AutoPay (ADR-008, ADR-009, ADR-010).
  - Tiers: Yogi Free (₹0), Karma Pro (₹149–₹199/mo or ~₹1,499/yr), FitKarma Elite (₹1,999+/mo), Sachet Sprints (₹49–₹99). Backend-configurable.
  - Entitlements: Strictly server-authoritative, verified via idempotent webhook handler (`Brain/api_contract.md`, `Brain/master_rules.md`).
  - RevenueCat Policy: RevenueCat is strictly historical migration context (ADR-007) and must NOT exist as an active dependency.
- **Repository Code State**:
  - **No Active RevenueCat Dependency**: Confirmed. There are zero packages, build scripts, or code files referencing RevenueCat in the workspace.
  - **Payment Implementation**: **Absent** in code. Neither Razorpay client SDK nor backend Edge Function webhook handlers exist yet.

### 2.5 Nutrition Engine & Food Logging
- **Documented Baseline**:
  - Deep Indian Food Catalog: 500+ regional recipes, festival foods, street food, vegetarian protein optimization.
  - Native Portions: `katori`, `glass`, `spoon`, `piece`, `serving`, roti count, idli count, percentage of family recipe.
  - Food State & Multipliers: Distinguish raw vs. cooked foods; deterministic cooking multipliers for water absorption/evaporation.
  - Tadka/Tempering Slider: `Low`, `Medium`, `High` invisible fat estimates.
  - Family Recipe Splitter: Total raw recipe entry with consumed percentage allocation (offline-capable).
- **Repository Code State**: **Absent**
  - No food databases, seed JSON/SQL, or models
  - No portion conversion arithmetic or unit tests

### 2.6 Zero-Friction Logging & AI Routing
- **Documented Baseline**:
  - WhatsApp text and voice note logging (Hinglish P0, Hindi P1, Tamil/Telugu P2).
  - Server-side Groq AI router via Supabase Edge Functions.
  - Structured schema extraction with explicit confidence/uncertainty scoring.
  - Mandatory confirmation UI for ambiguous results; manual fallback.
  - AI photo recognition (P1) with privacy/retention boundaries.
- **Repository Code State**: **Absent**
  - No WhatsApp webhook ingress, audio transcription, or prompt pipeline
  - No Groq API adapter or confirmation widgets

### 2.7 Daily Intelligence Package (DIP) & UI
- **Documented Baseline**:
  - Contextual Bento grid dashboard dynamically presenting today's key signal, explanation, small micro-action, and reward.
  - Rejection of cluttered "all-in-one" dashboard.
  - Bilingual Hindi/English support.
- **Repository Code State**: **Absent**
  - No UI screens, widgets, or DIP orchestration logic

### 2.8 Health Ecosystem & Aggregators
- **Documented Baseline**:
  - OS-level aggregators prioritized before direct wearable vendor APIs (ADR-004).
  - Android: Google Health Connect (P0).
  - iOS: Apple Health / HealthKit (P0).
  - Normalized observation model with source attribution, permission handling, background sync, and deletion cascade.
- **Repository Code State**: **Absent**
  - No Health Connect or HealthKit plugins/services implemented

### 2.9 Family Health Governance
- **Documented Baseline**:
  - Household health management with explicit affirmative consent (ADR-012).
  - Role-based scoped access (steps, sleep, vitals) for aging parents/dependents.
  - Instant revocation; non-emergency crisis alert guardrails.
- **Repository Code State**: **Absent**
  - No family models, invitations, or RLS permission policies implemented

### 2.10 Cultural Wellness & Specialized Domains
- **Documented Baseline**:
  - Dynamic TDEE: Adaptive calculation based on intake and weight trends (ADR-013).
  - Ayurveda Wellness Layer: Personalization and lifestyle guidance without medical claims (ADR-011).
  - Festival / Fasting Mode: User-selected fast schedules (Navratri, Ramzan, etc.) that adapt nudges/hydration without religious inference.
  - Women's Health: Cycle-aware training, PCOS tracking, and symptoms under heightened security.
  - AQI-Aware Fitness: Outdoor/indoor recommendations based on permissioned location and cached AQI.
- **Repository Code State**: **Absent**
  - No domain logic or models implemented

### 2.11 Security, Privacy & DPDP Compliance
- **Documented Baseline**:
  - SQLCipher local encryption, private Supabase Storage buckets.
  - Server-side cascading deletion (`delete_user_data`), export requests.
  - Visual Data Vault showing local vs. cloud storage distribution.
  - Universal RLS; no client-side secrets.
- **Repository Code State**: **Absent**
  - No security infrastructure or encryption layer implemented

### 2.12 CI/CD, Testing & Tooling
- **Documented Baseline**:
  - GitHub Actions running formatting, static analysis, unit/widget tests, Supabase RLS tests, security scans, and builds.
  - Documentation reports historical 160/160 passing tests.
- **Repository Code State**: **Absent**
  - No `.github/workflows/` directory
  - No automated test files (`test/` absent)

---

## 3. Implementation Status Matrix

| Module / Component | Documentation Status | Code Implementation Status | Notes |
|---|---|---|---|
| Flutter Project Skeleton | Confirmed (Master Doc §2) | **Absent** | Requires bootstrapping with Flutter 3.47 / Dart 3.13 |
| State Management (Riverpod) | Confirmed (Master Doc §2) | **Absent** | Needs core provider architecture |
| Drift + SQLCipher DB | Confirmed (ADR-001, ADR-003) | **Absent** | Offline foundation required |
| Offline Sync Outbox | Confirmed (TRD §2, Arch §4) | **Absent** | Needs sync queue & retry logic |
| Supabase Postgres & RLS | Confirmed (Master Doc §2) | **Absent** | Schema & migrations needed |
| Supabase Edge Functions | Confirmed (TRD §3, Arch §3) | **Absent** | Server orchestration needed |
| Razorpay Payment Gateway | Confirmed (ADR-008, ADR-009) | **Absent** | To replace historical RevenueCat |
| RevenueCat References | Retired (ADR-007) | **Clean in Code** | Exists only in doc history |
| Indian Portion Model | Confirmed (PDR §6, TRD §4) | **Absent** | Katori, glass, piece, etc. |
| Raw vs Cooked Multipliers | Confirmed (Master Doc §5) | **Absent** | Deterministic formulas needed |
| Tadka / Tempering Slider | Confirmed (Master Doc §5) | **Absent** | Low/Med/High fat estimation |
| Family Recipe Splitter | Confirmed (Master Doc §5) | **Absent** | Percentage consumption model |
| WhatsApp Ingress & Webhook | Confirmed (ADR-006, PDR §6) | **Absent** | Meta Business API integration |
| Groq Server-Side AI Adapter | Confirmed (Master Doc §2) | **Absent** | Multi-model routing |
| Daily Intelligence Package | Confirmed (Master Doc §14) | **Absent** | Dynamic home screen layout |
| Health Connect / Apple Health | Confirmed (ADR-004) | **Absent** | OS aggregation layer |
| Dynamic TDEE Engine | Confirmed (ADR-013) | **Absent** | Trend smoothing & math models |
| Family Care Dashboard | Confirmed (ADR-012) | **Absent** | Consent & permission scopes |
| Data Vault / Deletion Cascade | Confirmed (Master Doc §16) | **Absent** | Local & cloud erasure |
| CI/CD Workflows | Confirmed (TRD §1, GitHub Actions) | **Absent** | GitHub Actions workflows |

---

## 4. Documentation vs. Code Contradictions

1. **Historical Test Suite vs. Empty Workspace**:
   - *Documentation Claim*: Master Documentation §18 and `Brain/testing.md` refer to "160/160 automated unit/widget tests were passing" as baseline evidence.
   - *Code Reality*: `test/` directory is completely absent. Rerunning `flutter test` fails with `Test directory "test" not found.`
   - *Action*: Note historical claims as legacy audit artifacts; establish fresh greenfield testing suites alongside implementation.

2. **Documentation Path Inconsistencies (`/docs` vs `/Brain`)**:
   - *Documentation Text*: Master Doc §11 and `Brain/master_rules.md` state: *"Detailed technical and product specifications are maintained in `/docs`."*
   - *Repository Reality*: All domain specifications reside in `Brain/` (`Brain/pdr.md`, `Brain/trd.md`, etc.).
   - *Action*: Update documentation references in TASK 002 to consistently point to `Brain/` or establish canonical documentation path aliases.

3. **Skill File Reference (`SKILLS.md` vs `SKILL.md`)**:
   - *Prompt / Rule*: Refers to `.agent/skills/SKILLS.md`.
   - *Repository Reality*: The actual file on disk is `.agent/skills/SKILL.md`.
   - *Action*: Clarify and align in documentation consistency phase (TASK 002).

4. **Confirmed vs. Proposed Schemas**:
   - *Documentation Text*: `Brain/data_model.md` classifies `recipes` and `cooking_multipliers` as CONFIRMED, while classifying `portions` and `sync_queue` as PROPOSED.
   - *Code Reality*: Since no database migration exists in the workspace, physical definitions for all entities remain to be instantiated.

---

## 5. Prioritized Gap List Mapped to Todo Task IDs

The 44 tasks in [Todo.md](file:///f:/Fitness%20App/Todo.md) map directly to addressing the gaps identified above:

| Phase | Todo Tasks | Target Scope | Gap Status |
|---|---|---|---|
| **Phase 0: Baseline & Consistency** | TASK 001 - TASK 002 | Repo audit, documentation-to-code alignment, resolving `/docs` vs `Brain/` path discrepancies | TASK 001 in progress; TASK 002 next |
| **Phase 1: Payment Migration** | TASK 003 - TASK 008 | Complete purge of RevenueCat references; Razorpay backend, webhook verification, idempotency, state machine, UPI/AutoPay, pricing config | All payment code absent; needs implementation |
| **Phase 2: India-First Nutrition** | TASK 009 - TASK 013 | Indian portions (katori, glass, roti count), raw vs cooked yield multipliers, Tadka slider, Family Recipe Splitter, food logging UX | All nutrition models & logic absent; needs implementation |
| **Phase 3: Conversational AI & WhatsApp** | TASK 014 - TASK 018 | WhatsApp text/voice backend contracts, Hinglish NLP extraction, AI meal analyzer, confirmation UI, photo logging (P1) | Webhook and AI adapters absent; needs implementation |
| **Phase 4: Health OS Intelligence** | TASK 019 - TASK 020 | Dynamic TDEE adaptive engine, Daily Intelligence Package (DIP) orchestration | Calculations and dashboard absent; needs implementation |
| **Phase 5: Health Rails** | TASK 021 - TASK 023 | Health Connect (Android), Apple Health (iOS), sync engine hardening & conflict resolution | Platform integrations absent; needs implementation |
| **Phase 6: Family & Specialized Wellness** | TASK 024 - TASK 029 | Family Care consent & UX, Festival/Fasting mode, AQI workout coach, Ayurveda guardrails, Women's Health | Domain modules absent; needs implementation |
| **Phase 7: Privacy, Gamification & Monetization** | TASK 030 - TASK 034 | Data Vault / erasure UX, push retention loop, Karma points, grocery boundary, safe AdMob placement | Retention and privacy UX absent; needs implementation |
| **Phase 8: Hardening, Security & Release** | TASK 035 - TASK 044 | API conformance, error taxonomy (FK-XXXX), RLS security audit, test expansion, low-end Android perf, CI/CD, production readiness | Quality assurance & release gates absent; needs implementation |

---

## 6. Open Decisions Requiring Resolution

1. **Project Bootstrapping Strategy**:
   - How should the Flutter skeleton be initialized in `F:\Fitness App` without pulling in deprecated or unwanted third-party dependencies?
   - *Status*: OPEN DECISION. Recommended to initialize standard Flutter 3.x project layout with defined `pubspec.yaml` matching confirmed tech stack.

2. **Supabase Local Development & Migrations**:
   - Supabase CLI is not in the system PATH. Will migrations be written as standard SQL files in `supabase/migrations/` and applied via remote connection or Docker when CLI is installed?
   - *Status*: OPEN DECISION. Recommend structuring clean versioned SQL scripts (`00001_initial_schema.sql`, etc.) ready for CI/CD and direct execution.

3. **Drift & SQLCipher Dependency Configuration**:
   - `sqlite3_flutter_libs` with SQLCipher on Windows/Android/iOS requires specific build configuration.
   - *Status*: OPEN DECISION. Validate compatibility with Flutter 3.47 / Dart 3.13.

4. **Razorpay Webhook Secret & Key Architecture**:
   - Webhook signatures require `X-Razorpay-Signature` HMAC SHA-256 verification against a server secret.
   - *Status*: OPEN DECISION. Environment secret names and Edge Function config convention must be standardized (`RAZORPAY_KEY_ID`, `RAZORPAY_KEY_SECRET`, `RAZORPAY_WEBHOOK_SECRET`).

5. **WhatsApp Inbound Provider Routing**:
   - Meta WhatsApp Business Cloud API requires webhook verification token (`hub.challenge`) and HMAC verification of payload.
   - *Status*: OPEN DECISION. Contract documented in `Brain/api_contract.md`; Edge Function signature needed.

---

## 7. Verification & Tooling Diagnostics Log

| Command | Working Directory | Exit Code | Observed Output / Diagnostic |
|---|---|---|---|
| `dart analyze` | `F:\Fitness App` | 0 | `Analyzing Fitness App... No issues found!` (Clean report; zero Dart source files currently present) |
| `flutter test` | `F:\Fitness App` | 1 | `Test directory "test" not found.` (Confirms tests have not yet been initialized in workspace) |
| `flutter --version` | `F:\Fitness App` | 0 | `Flutter 3.47.6 • Dart 3.13.5 • DevTools 2.60.0 • windows_x64` |
| `supabase --version` | `F:\Fitness App` | 1 | `CommandNotFoundException` (Supabase CLI not on PATH) |
| `git status` | `F:\Fitness App` | 1 | `fatal: not a git repository` |

---

## 8. Conclusion & Immediate Next Step

TASK 001 audit is complete. All existing documentation has been analyzed in strict accordance with `.agent/skills/SKILL.md` and `FitKarma_Master_Documentation_v3.md`.

The next sequential task in [Todo.md](file:///f:/Fitness%20App/Todo.md) is:
👉 **TASK 002 — Documentation/Code Consistency Foundation** (aligning documentation paths, clarifying `.agent/skills/SKILL.md` vs `SKILLS.md`, `/docs` vs `Brain/`, and setting up baseline consistency without inventing unconfirmed behavior).
