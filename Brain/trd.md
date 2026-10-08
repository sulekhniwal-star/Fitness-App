# FitKarma Technical Requirements Document

## 1. Technology baseline

- Flutter 3.24+ / Dart 3.5+
- Riverpod 2.x
- Drift + SQLCipher
- Supabase Postgres, Auth, Storage, Realtime, Edge Functions
- Groq server-side AI routing
- Health Connect / Apple Health
- Razorpay
- Firebase Cloud Messaging
- Sentry
- GitHub Actions

## 2. Frontend requirements

- Responsive Android/iOS execution
- Offline-first writes
- Encrypted local persistence
- Feature-domain state isolation in Riverpod
- Accessibility-conscious typography and contrast
- Contextual dashboard driven by DIP

## 3. Backend requirements

- Server-side validation for sensitive mutations
- RLS for user data
- Webhook signature verification
- Idempotent mutation processing
- Structured AI request/response envelopes
- Auditable deletion and entitlement operations

## 4. Nutrition engine

Must support raw/cooked status, cooking multipliers, household portions, recipe composition, family percentage allocation and Tadka estimates. Nutrition arithmetic must be deterministic and independently testable.

## 5. AI requirements

- Structured extraction
- explicit uncertainty
- user confirmation before committing ambiguous results
- bounded prompts and schema validation
- privacy-aware logging and retention

## 6. Health integration requirements

- explicit permissions
- normalized observation model
- source attribution
- incremental sync
- revocation/deletion handling
- background sync where OS capabilities allow

## 7. Payment requirements

- UPI-first
- UPI AutoPay support
- server-side entitlement calculation
- webhook verification
- idempotency
- state machine for pending/failure/grace/cancellation/refund

## 8. Security requirements

- SQLCipher encrypted local DB
- secure key material storage via platform facilities
- RLS
- least privilege
- secret scanning
- PII scrubbing in logs

## 9. Performance

No fixed target is confirmed. `PROPOSED`: define cold-start, dashboard render, offline write, sync and AI response budgets before performance sign-off.

## 10. Scalability

Design for horizontal Edge Function execution, PostgreSQL indexing, bounded AI spend and queue/backoff behavior. Avoid coupling app availability to non-critical third-party APIs.

## 11. Testing

All calculations, sync state transitions, RLS policies, payment webhooks, deletion cascades and localization flows require automated coverage. See `testing.md`.
