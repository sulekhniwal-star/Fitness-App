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

## ADR-016 — Greenfield Implementation Baseline
**Status:** Accepted  
**Decision:** Treat `F:\Fitness App` as a clean-slate implementation workspace and exclude legacy external files. All modules (Flutter UI, Drift/SQLCipher, Supabase schema, Edge Functions, Razorpay) are to be built incrementally following Todo.md tasks.  
**Reason:** Avoid carrying over deprecated dependencies, architectural drift, or unvalidated technical debt.

## ADR-017 — Dual Documentation Path Mirroring (`/docs` and `Brain/`)
**Status:** Accepted  
**Decision:** Support both `Brain/` and `/docs` paths natively via a filesystem directory junction. `Brain/` remains the physical storage location for domain documentation, mirrored directly to `/docs`.  
**Reason:** Reconciles references in Master Documentation and skills that cite `/docs` with the local workspace folder `Brain/` without file duplication or sync drift.

## Open Architectural Decisions

- **OD-001: Project Bootstrapping & Package Pinning**  
  *Context*: Flutter SDK 3.47.6 / Dart 3.13.5 installed on host. Standard project structure, Riverpod 2.x, Drift, and SQLCipher dependencies must be pinned cleanly.  
  *Status*: OPEN DECISION.

- **OD-002: Supabase Migrations Workflow**  
  *Context*: Supabase CLI is not installed on PATH. Migration scripts will be versioned as pure SQL in `supabase/migrations/` ready for CI and remote execution.  
  *Status*: OPEN DECISION.

- **OD-003: Razorpay Server Secrets & Webhook Verification Convention**  
  *Context*: Standardizing Edge Function environment variables (`RAZORPAY_KEY_ID`, `RAZORPAY_KEY_SECRET`, `RAZORPAY_WEBHOOK_SECRET`) and HMAC SHA-256 verification contracts.  
  *Status*: OPEN DECISION.

- **OD-004: Offline Outbox Conflict Resolution Policy**  
  *Context*: Defining entity-specific conflict rules (e.g. food log vs health observation sync collisions) for offline writes.  
  *Status*: OPEN DECISION.

