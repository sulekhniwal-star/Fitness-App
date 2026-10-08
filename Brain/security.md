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

## 5. Payment security

Do not store UPI PINs, card CVVs, full card details or bank credentials. Keep provider secrets server-side. Verify webhook signatures and compute entitlements server-side.

## 6. AI/WhatsApp security

Minimize payloads. Apply retention controls to audio, images and prompts. Do not log raw health content in general application logs. Scrub PII in monitoring.

## 7. Family security

Explicit affirmative consent is mandatory before sharing selected health observations. Revocation must be immediate at the authorization layer.

## 8. DPDP considerations

Provide purpose-aware collection, consent/notice where required, export/access mechanisms, deletion pathways, and auditable cascading erasure. Product implementation does not by itself constitute legal compliance; launch should include legal review.

## 9. Threat model

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

## 10. Rate limiting and abuse prevention

Apply provider/webhook verification plus per-user/IP controls for authentication, AI, WhatsApp and export/deletion operations. Exact thresholds are `OPEN DECISION`.

## 11. Deletion

The existing documentation specifies a `delete_user_data` cascade across 28 tables and storage assets. This claim is classified as **UNVERIFIED** until implemented and tested in this greenfield repository. Deletion must include local cache invalidation where appropriate and family-access revocation.
