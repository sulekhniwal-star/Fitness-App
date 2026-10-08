# FitKarma AI Coding Agent Skill

## Required reading order

Before a major change, read:

1. `master_rules.md`
2. `pdr.md`
3. `trd.md`
4. `architecture.md`
5. `decisions.md`
6. the relevant domain document

## Repository behavior

Treat the master documentation as the high-level source and `/docs` as domain-level source of truth. Do not create competing documentation systems.

## Coding conventions

- Flutter/Dart idioms
- feature-oriented domain separation
- immutable Riverpod state
- repository boundaries around persistence/integrations
- deterministic calculations separated from AI adapters

## Database/API

Never infer an existing schema or endpoint from a proposal. `PROPOSED` text requires implementation/approval before becoming source of truth.

## Security

No client secrets, no insecure local storage for health data, no RLS bypasses, no trust in client-side payment success.

## Offline-first

Write local first, enqueue remote sync, make retries idempotent, preserve user data during transient failures.

## AI

Validate structured outputs, show uncertainty, require confirmation for materially ambiguous user data, and avoid medical claims.

## Payments

Use Razorpay server APIs and verified webhooks. Maintain the subscription state machine independently of UI state.

## Testing

Every implementation task must add the appropriate unit/widget/integration/security tests. Do not lower coverage by deleting tests to make CI pass.

## Git workflow

Small commits, descriptive messages, no secrets, no unrelated refactors, and documentation updates alongside architectural changes.

## Definition of done

A feature is not complete until:

- behavior is documented;
- errors are documented;
- permissions/security are covered;
- offline behavior is explicit;
- tests exist;
- production/monitoring impact is known.
