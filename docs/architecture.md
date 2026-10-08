# FitKarma System Architecture

## 1. Canonical architecture

```mermaid
flowchart TD
  UI[Flutter UI] --> RV[Riverpod]
  RV --> DB[Drift + SQLCipher]
  DB --> OUT[Offline Outbox]
  OUT --> SYNC[Sync Engine]
  SYNC --> SB[Supabase]
  SB --> EF[Edge Functions]
  EF --> AI[AI Providers]
  EF --> WA[WhatsApp Cloud API]
  EF --> PAY[Razorpay]
  EF --> EXT[Other External APIs]
  SB --> RT[Supabase Realtime]
  RT --> SYNC
```

## 2. Client layers

- Presentation: Flutter widgets and screens.
- State: Riverpod feature/domain providers.
- Persistence: Drift repositories over SQLCipher.
- Sync: outbox worker with idempotent operations.
- Integrations: platform health APIs and secure backend bridges.

## 3. Backend boundaries

### Supabase Postgres

Canonical relational data store with RLS on exposed user data. `pgvector` may support recipe embeddings where required.

### Edge Functions

Server-only responsibilities include AI provider routing, WhatsApp webhooks, payment provider verification, subscription entitlement updates, deletion orchestration and privileged integrations.

## 4. Offline sync

Every mutable entity needs a stable client ID or server-issued identifier plus an idempotency strategy. The sync engine should:

1. read pending outbox records;
2. submit only authorized mutations;
3. retry transient failures with backoff;
4. mark success only after server acknowledgement;
5. surface conflicts instead of silently overwriting material user changes.

Exact conflict rules are `PROPOSED` and vary by entity.

## 5. AI architecture

Use the server-side Groq router described in the main documentation. Candidate model roles are retained as source-supported architecture, while exact model versions remain configurable. Structured outputs should feed deterministic domain logic.

## 6. WhatsApp architecture

Inbound text/audio is received through webhook infrastructure. Media is fetched server-side, transcribed/parsed, normalized to the nutrition domain, and returned as a confirmation prompt before committing uncertain food data.

## 7. Payments

Razorpay is integrated server-side. The client receives only public identifiers and state needed to render the payment flow. Webhooks are verified and applied idempotently before entitlements are changed.

## 8. Health integrations

OS-level health aggregators are the primary first-stage integrations: Health Connect on Android and Apple Health/HealthKit on iOS. Each imported observation retains source metadata where the platform makes it available.

## 9. Security boundaries

- Client never holds provider secrets.
- Local health data is encrypted.
- Supabase RLS is mandatory.
- Privileged Edge Functions use least-privilege credentials.
- Family sharing is scoped and revocable.

## 10. Availability targets

No numeric SLO is currently confirmed. `PROPOSED`: define sync success, API latency, crash-free session and webhook processing objectives before production launch.
