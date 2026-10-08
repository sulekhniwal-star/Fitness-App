# FitKarma UI/UX Specification

## 1. Design system

- Primary visual mode: dark (`#0D0F12`)
- Glassmorphism surfaces
- Bento-grid composition
- Spring-physics motion
- High contrast and strong text legibility for older/lower-end users
- English/bilingual UI with localized AI coaching

## 2. Navigation

The application uses declarative routing via `GoRouter` coordinated with Riverpod (`appRouterProvider`, `authNavStatusProvider`):

- **Auth boundaries**:
  - Unauthenticated routes: `/onboarding`, `/auth/login`, `/auth/otp`.
  - Authenticated top-level areas: `/dashboard` (home/DIP), `/nutrition`, `/nutrition/log`, `/workouts`, `/sleep`, `/recovery`, `/ai/meal-analyze`, `/family`, `/subscriptions`, `/settings`, `/data-vault`.
- **Reactive redirection**: Unauthenticated access to protected routes redirects to `/onboarding`; authenticated sessions redirect to `/dashboard`.

## 3. Onboarding

Capture only information required for personalization and consent. Explain privacy, offline behavior and optional integrations. Do not infer fasting/religion participation.

## 4. Home — Daily Intelligence Package

The home screen is contextually assembled. It should prioritize:

1. most important health signal;
2. explanation/insight;
3. one or more small actions;
4. progress/reward feedback;
5. access to detailed modules.

Avoid showing unrelated modules together simply because they exist.

## 5. Food logging

Support search, quick-add, household units, raw/cooked selection, recipe-based logging, Tadka slider, Family Recipe Splitter and AI/WhatsApp entry.

### Uncertainty

AI estimates must display a correction/confirm affordance before committing when uncertainty is material.

## 6. WhatsApp

The product response should be concise, contextual and actionable. A voice-note result should show recognized foods, assumed portions and a clear correction path.

## 7. Photo logging

Show detected dishes and estimated portions, then request confirmation. Provide manual fallback. Clearly state that recognition is approximate.

## 8. Family

Show consent state, relationship, accessible metrics and revocation controls. Avoid dark patterns around sharing.

## 9. Payments

Show plan, amount, billing cadence, payment method, pending state and final activation state. UPI should be prominent for India.

## 10. Data Vault

Provide a clear view of local vs cloud data, export, deletion, and privacy status. Deletion should require an intentional confirmation and show progress/completion.

## 11. Notifications

Use localized coaching. During selected fasting periods suppress inappropriate “you haven’t eaten” nudges and adapt meal/hydration prompts.

## 12. Accessibility

- readable type sizes
- strong contrast
- screen-reader labels
- non-color-only status indicators
- touch targets suitable for one-handed mobile interaction

Exact typography, spacing tokens and animation durations remain `OPEN DECISION` until the design system is finalized.
