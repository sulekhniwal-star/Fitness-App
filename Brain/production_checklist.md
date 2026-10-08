# FitKarma Production Readiness Checklist

## Product

- [ ] P0 acceptance criteria complete
- [ ] DIP dashboard validated for clarity
- [ ] AI uncertainty UX validated
- [ ] India-specific nutrition edge cases reviewed

## Backend/Database

- [ ] migrations versioned
- [ ] indexes reviewed
- [ ] RLS policies tested
- [ ] deletion cascade tested
- [ ] backups/restore procedure tested

## Security/Privacy

- [ ] secrets isolated from client
- [ ] SQLCipher key lifecycle reviewed
- [ ] RLS/IDOR penetration checks completed
- [ ] PII scrubbing verified
- [ ] export and deletion flows verified
- [ ] legal/privacy review completed

## AI

- [ ] provider limits understood
- [ ] structured outputs validated
- [ ] fallback paths work
- [ ] prompt/data retention policy approved

## Payments/Razorpay/UPI

- [ ] test payments
- [ ] webhook signatures
- [ ] idempotency
- [ ] mandate lifecycle
- [ ] failed payment/grace period
- [ ] refund handling
- [ ] entitlement reconciliation

## Android/iOS

- [ ] Health Connect permissions
- [ ] Apple Health permissions
- [ ] background sync behavior
- [ ] low-end Android smoke test

## Offline

- [ ] fresh install offline
- [ ] log offline
- [ ] reconnect/sync
- [ ] conflict behavior

## Monitoring/Analytics

- [ ] Sentry configured with PII scrubbing
- [ ] alerts for sync/webhook failures
- [ ] KPI events validated

## Stores

- [ ] privacy policy links
- [ ] consent disclosures
- [ ] app review metadata
- [ ] payment descriptions
- [ ] production signing
