# FitKarma API Contract

> Most exact API routes are **PROPOSED** because the supplied baseline does not enumerate concrete endpoint paths. This document defines contracts and responsibilities without pretending unconfirmed routes already exist.

## 1. Rules

- JSON over HTTPS for public application APIs unless an integration requires another protocol.
- Authenticated user calls carry the user identity through Supabase Auth/JWT.
- Sensitive server integrations occur through Edge Functions.
- Mutating requests should accept or generate an idempotency key.
- Errors use the taxonomy in `error_handling.md`.

## 2. Proposed endpoint families

| Method | Route | Purpose | Auth |
|---|---|---|---|
| POST | `/v1/food-logs` | create/confirm food log | user |
| GET | `/v1/food-logs` | list food logs | user |
| POST | `/v1/recipes/estimate` | estimate recipe nutrition | user |
| POST | `/v1/ai/meal-analyze` | analyze meal text/photo | user |
| POST | `/v1/whatsapp/webhook` | receive WhatsApp events | signed provider webhook |
| POST | `/v1/family/invitations` | invite family member | user |
| POST | `/v1/family/consent` | record consent | subject/user |
| POST | `/v1/subscriptions` | create subscription/payment intent | user |
| POST | `/v1/webhooks/razorpay` | payment provider events | signed provider webhook |
| POST | `/v1/health/sync` | ingest normalized observations | user/device |
| POST | `/v1/data-export` | request export | user |
| POST | `/v1/data-erasure` | request deletion cascade | user |

## 3. Request contract pattern

```json
{
  "request_id": "client-generated-id",
  "idempotency_key": "stable-operation-key",
  "payload": {}
}
```

## 4. Response pattern

```json
{
  "request_id": "...",
  "data": {},
  "warnings": [],
  "error": null
}
```

## 5. Authentication/authorization

Every route must document whether it requires authenticated ownership, family role, admin role or signed provider verification.

## 6. AI responses

AI responses that can change structured user data must include confidence/uncertainty metadata and a confirmation state.

## 7. Payment APIs

Client success is not authoritative. Subscription activation is driven by server verification and webhook reconciliation.

## 8. Webhooks

Webhook handlers must verify signatures, deduplicate by event ID/provider ID where supported, process idempotently, and return a stable response quickly.

## 9. Rate limits

Exact limits are `OPEN DECISION`. Define separate buckets for authentication, AI, WhatsApp, data export, sync and payment actions.
