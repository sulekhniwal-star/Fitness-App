# FitKarma Error Handling

## Error envelope

```json
{
  "code": "FK-XXXX",
  "message": "User-safe message",
  "retryable": false,
  "request_id": "..."
}
```

## Standard codes

| Code | Domain | Meaning |
|---|---|---|
| FK-1001 | Auth | authentication required/expired |
| FK-1002 | AuthZ | access denied |
| FK-2001 | Validation | invalid user input |
| FK-3001 | Offline | queued locally |
| FK-3002 | Sync | transient sync failure |
| FK-3003 | Conflict | reconciliation required |
| FK-4001 | AI | provider/unparseable AI result |
| FK-4002 | AI | low-confidence result needs confirmation |
| FK-5001 | Payment | provider request failed |
| FK-5002 | Payment | verification failed |
| FK-5003 | Payment | mandate/payment failed |
| FK-5004 | Payment | webhook duplicate/already processed |
| FK-6001 | External | third-party dependency unavailable |
| FK-7001 | Privacy | deletion/export operation failed |

## Recovery rules

- Offline: write locally and show pending state.
- Sync: retry transient errors with backoff; do not endlessly retry permanent validation errors.
- AI: fall back to manual entry or a deterministic parser where available.
- Payment: show pending until server verification; never grant entitlement on UI-only success.
- Webhooks: deduplicate and make handler idempotent.
- External APIs: degrade gracefully when non-critical.

## User messaging

Messages should be localized, actionable and non-blaming. Never expose stack traces, secrets or provider internals.
