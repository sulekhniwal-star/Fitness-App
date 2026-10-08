# FitKarma Testing Strategy

## Layers

### Unit

- nutrition arithmetic
- raw/cooked conversion
- cooking multipliers
- Tadka estimates
- Family Recipe Splitter percentages
- Dynamic TDEE calculations
- subscription state machine
- error mapping

### Widget

- onboarding
- dashboard/DIP cards
- food confirmation
- WhatsApp result view
- family consent/revocation
- payment states
- Data Vault

### Integration

- Drift/SQLCipher persistence
- outbox sync
- Supabase auth and RLS
- Health Connect / Apple Health adapters
- Edge Functions
- webhook verification

### Security

- RLS isolation
- IDOR attempts
- token leakage
- webhook spoof/replay
- family permission bypass
- deletion completeness
- secret scanning

### AI

Test deterministic fixtures with ambiguous food names, mixed language, missing quantities, unusual portions and adversarial text. Measure extraction correctness and correction rate.

### Nutrition

Test raw vs cooked food, yield multipliers, invisible fats, household units, recipe splitting and rounding.

### Payments

Cover:

- duplicate webhook
- delayed webhook
- failed UPI payment
- cancelled mandate
- expired subscription
- renewal failure
- grace period
- refund
- entitlement reconciliation

### Offline/sync

Cover:

- airplane mode
- reconnect
- duplicate outbox item
- reordered operations
- conflict
- partial sync
- app restart during sync

### Localization/accessibility

Test Hinglish/Hindi/Tamil/Telugu content where supported, text overflow, screen readers, contrast and large font settings.

## Baseline verification

The source documentation reports 160/160 unit/widget tests and zero static-analysis issues. Treat those as historical/source-reported until rerun against the actual repository.
