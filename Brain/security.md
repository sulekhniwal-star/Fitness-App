# FitKarma Security & Privacy Specification

## 1. Security posture

Treat health, family, AI, WhatsApp and payment-adjacent data as sensitive.

## 2. Authentication

Use Supabase Auth as the application identity layer. Never bypass authorization checks merely because a request originated from the trusted client.

## 3. Authorization

- Supabase RLS on user data
- least privilege for Edge Functions
- explicit family roles
- revocable consent
- privileged operations audited

## 4. Encryption

- Drift + SQLCipher for local data
- platform secure storage for local secrets/keys where applicable
- TLS for data in transit
- private storage buckets for sensitive media

## 5. Environment configuration and secret boundaries

Client builds strictly ingest public configuration (`APP_ENV`, `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SENTRY_DSN`) via `AppConfig`. Privileged server secrets (`SUPABASE_SERVICE_ROLE_KEY`, `RAZORPAY_KEY_SECRET`, `RAZORPAY_WEBHOOK_SECRET`, `GROQ_API_KEY`, `WHATSAPP_ACCESS_TOKEN`, `WHATSAPP_WEBHOOK_VERIFY_TOKEN`) are strictly prohibited in the client and enforced at compile-time/runtime via `SecurityViolationException`. All `.env` and credential files are ignored by git with template definitions in `.env.example`.

## 6. Payment security

Do not store UPI PINs, card CVVs, full card details or bank credentials. Keep provider secrets server-side. Verify webhook signatures and compute entitlements server-side.

## 7. AI/WhatsApp security

Minimize payloads. Apply retention controls to audio, images and prompts. Do not log raw health content in general application logs. Scrub PII in monitoring.

## 8. Family security

Explicit affirmative consent is mandatory before sharing selected health observations. Revocation must be immediate at the authorization layer.

## 9. DPDP considerations

Provide purpose-aware collection, consent/notice where required, export/access mechanisms, deletion pathways, and auditable cascading erasure. Product implementation does not by itself constitute legal compliance; launch should include legal review.

## 10. Threat model

Primary threats:

- account takeover
- IDOR/data leakage
- family consent bypass
- webhook spoofing
- replay/duplicate events
- malicious AI input
- insecure local backups
- secrets in client/logs
- abusive automated API usage

## 11. Rate limiting and abuse prevention

Apply provider/webhook verification plus per-user/IP controls for authentication, AI, WhatsApp and export/deletion operations. Exact thresholds are `OPEN DECISION`.

## 12. Deletion

The existing documentation specifies a `delete_user_data` cascade across 28 tables and storage assets. This claim is classified as **UNVERIFIED** until implemented and tested in this greenfield repository. Deletion must include local cache invalidation where appropriate and family-access revocation.
