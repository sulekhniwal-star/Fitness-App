# FitKarma Engineering Master Rules

> Highest-level engineering rulebook. Read before implementation.

## Rule hierarchy

1. Preserve confirmed implementation requirements in the master documentation.
2. Apply strategic enhancements from the competitive analysis.
3. Record material architecture/product changes in `decisions.md`.
4. Anything not confirmed is `PROPOSED` or `OPEN DECISION`.

## Architecture rules

- Flutter remains the client framework; Riverpod remains the state-management boundary.
- Drift + SQLCipher is the offline source of truth for user-entered/client-synced data.
- Supabase/Postgres is the canonical remote backend unless an ADR changes it.
- Supabase Edge Functions own server-only secrets, AI routing, payment verification, webhooks, and sensitive orchestration.
- Avoid vendor-specific wearable integrations when an OS-level health aggregator provides the needed data.

## Offline-first rules

- Every user-visible write that can be performed offline must be persisted locally first.
- Queue remote synchronization in an outbox with retry state and idempotency keys.
- UI must expose pending/synced/conflict state where relevant.
- Never erase a local record solely because a network call failed.

## Data rules

- Health data is sensitive by default.
- Raw and cooked food states must remain distinguishable.
- Portion estimates and AI-derived nutrition are estimates unless sourced from exact user-entered quantities.
- Maintain source attribution for health metrics and external data.

## Security rules

- Universal Supabase RLS is mandatory for exposed user data.
- Never ship server secrets in the mobile client.
- Encrypt sensitive local data with SQLCipher.
- Payment credentials and authentication secrets are delegated to trusted providers; FitKarma must not store prohibited payment secrets.
- Audit privileged operations and deletion.

## AI rules

- AI must be server-routed when provider credentials are required.
- AI responses must be bounded by structured schemas where the result changes user data.
- AI must express uncertainty when food identity, portion size, or interpretation is ambiguous.
- Never present AI output as diagnosis or guaranteed medical advice.
- Prefer deterministic rules/calculations for critical calculations such as nutrition arithmetic and subscription state.

## Payment rules

- Razorpay is the active payment rail.
- UPI is first-class; UPI AutoPay is supported for recurring mandates where commercially and legally enabled.
- Entitlements are server-authoritative and webhook-backed.
- Webhook handlers must be idempotent.
- Never trust client-side payment success as final entitlement proof.

## UI rules

- The Daily Intelligence Package governs the home surface.
- Do not render every module on the dashboard simultaneously.
- Primary interactions should be short, contextual, and recoverable offline.
- Health-critical actions must not be obscured by advertisements.
- Bilingual/localized coaching may mix English with the selected Indian language while the product UI remains controlled and legible.

## Testing rules

- Every domain feature has unit coverage for calculations and state transitions.
- Every user-critical workflow has widget/integration coverage.
- RLS, deletion, payment webhooks, offline sync and localization require dedicated tests.

## Git/documentation rules

- Documentation changes accompany architecture/product changes.
- `decisions.md` is required for major architectural decisions.
- Do not silently remove a feature; classify it as active, deferred, future, or not recommended.
- Never commit secrets, production tokens, personal health exports, or payment credentials.
