---
phase: 4
plan: 2
wave: 1
---

# Plan 4.2: Payment Subscription Engine

## Objective
Extend Razorpay integration dynamically writing purchase configurations into a secure PocketBase `subscriptions` ledger upstream while upgrading the local User hierarchy.

## Context
- .gsd/SPEC.md
- fitkarma/lib/domain/services/payment_service.dart
- fitkarma/lib/data/providers/subscription_provider.dart

## Tasks

<task type="auto">
  <name>Bind Razorpay Ledger</name>
  <files>
    - fitkarma/lib/domain/services/payment_service.dart
  </files>
  <action>
    Review `_handlePaymentSuccess`. Along with updating the user tier optimistically via `syncServiceProvider`, inject a secondary synchronization command tracking the explicit `subscriptions` table alongside properties like `payment_id` and `plan_name` ensuring analytics map accurately to sales pipelines.
  </action>
  <verify>Run analyzer ensuring multi-sync enqueue structures validate successfully against offline models.</verify>
  <done>Transactions reflect dynamically into the Subscriptions table upstream offline-first.</done>
</task>

## Success Criteria
- [ ] Users natively unlock premium states offline securely.
- [ ] Market ledgers mirror precisely against backend databases post-transaction via Sync pipelines.
