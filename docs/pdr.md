# FitKarma Product Requirements Document

## 1. Product vision

FitKarma becomes the private, India-first Health OS that consolidates fragmented health data and turns it into simple daily actions—working through WhatsApp and offline.

## 2. Mission

Reduce the friction of healthy living for Indian users by understanding local food, household behavior, language, connectivity constraints, and family health dynamics.

## 3. Positioning

**FitKarma — India's smartest, most private Health OS that works where you are — on WhatsApp and offline.**

The product is not positioned as a generic calorie tracker, step counter, workout library, or generic AI coach.

## 4. Target users

- Urban professionals in Tier-1 cities
- Tier-2/Tier-3 and low-connectivity users
- College students
- Families coordinating health decisions
- Corporate wellness cohorts
- Premium metabolic-health users

## 5. Product principles

1. Indian by default.
2. Offline before online.
3. Action over analytics overload.
4. Privacy as a product feature.
5. AI assists; deterministic systems decide.
6. Consent before family sharing.
7. Cultural personalization must not become medical misinformation.

## 6. Core requirements

### P0 — Competitive MVP

- Authentication
- Offline local store and sync queue
- Indian nutrition database
- Raw/cooked distinction and cooking multipliers
- Indian household portion units
- Basic food, activity, sleep and weight tracking
- Health Connect
- Apple Health/HealthKit
- Razorpay foundation and UPI payments

### P0/P1 — India-first differentiation

- WhatsApp text/voice logging
- Hinglish coaching and language detection
- AI meal analysis
- Tadka/tempering slider
- Family Recipe Splitter
- Dynamic TDEE
- UPI AutoPay
- Karma Pro

### P1–P2 — Expansion

- AI photo food recognition
- Family Care Dashboard
- CGM pipeline
- ABHA/ABDM
- Advanced recovery
- Grocery integrations
- Hindi, Tamil and Telugu expansion

## 7. Key user journeys

### Meal via WhatsApp

WhatsApp → processing → language detection → AI extraction → Indian food DB → portion estimate → nutrition calculation → user confirmation → food log → DIP update.

### Offline food log

User logs locally → local validation/calculation → outbox record → sync when online → idempotent server upsert → acknowledgement.

### Family sharing

Owner invites family member → subject explicitly consents → scoped role is granted → selected metrics are visible → revocation immediately removes access.

### Subscription

User selects plan → backend creates provider transaction/subscription → user authorizes payment → provider confirms → server verifies → entitlement activates → future webhook events update state.

## 8. Monetization

- Free: ₹0
- Karma Pro: ₹149–₹199/month or ~₹1,499/year
- Elite: ₹1,999+/month
- Sachet products: ₹49–₹99

Pricing is configurable server-side.

## 9. Success metrics

The exact target values are `OPEN DECISION`. Measure:

- D1/D7/D30 retention
- meals logged per active user/week
- percentage of logs completed without opening the app
- WhatsApp log completion rate
- correction rate for AI meal extraction
- sync success rate
- crash-free sessions
- subscription conversion and renewal
- family invite-to-consent rate
- deletion/export completion rate

## 10. Strategic rationale

The competitive analysis identifies manual logging friction as a key churn risk and recommends WhatsApp voice logging as a killer India-first differentiator. It also recommends moving adaptive TDEE earlier and prioritizing OS-level health aggregation before building numerous direct wearable integrations.

## 11. Risks

- Scope creep
- AI hallucination/incorrect food portions
- regulatory/privacy exposure
- third-party API dependency
- poor offline conflict handling
- payment webhook drift
- overloading the dashboard
- inconsistent Indian nutrition data

## 12. Roadmap

See master documentation and `microtasks.md` for the implementation sequence.
