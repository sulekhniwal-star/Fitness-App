# FitKarma — Master Documentation (v3.1)
### India's Intelligent Health Operating System
**Flutter 3.x · Dart · Riverpod 2.x · Supabase (Postgres, Auth, Storage, Edge Functions, Realtime) · Razorpay (UPI & AutoPay) · Multi-Model AI (Groq)**

> Offline-first · Privacy-centric · Built for India · AI-adaptive · DPDP Act 2023 Compliant  
> Dark mode primary (`#0D0F12`) · Glassmorphism · Spring physics · Bento grid · Bilingual Hindi/English  
> Package ID: `com.sulekhniwal.fitkarma` · Companion admin platform: **FitKarma Hub**

---

## Documentation Architecture

This document is the high-level master specification for FitKarma.

Detailed technical and product specifications are maintained in `/docs`.

Before implementing any feature, agents should consult:

1. `docs/master_rules.md`
2. `docs/pdr.md`
3. `docs/trd.md`
4. `docs/architecture.md`
5. `docs/decisions.md`
6. The relevant domain specification

### Documentation ownership

| Document | Ownership |
|---|---|
| This master document | Product vision, complete feature map, major requirements, roadmap |
| `pdr.md` | Product requirements and user outcomes |
| `trd.md` | Technical requirements |
| `architecture.md` | System architecture and boundaries |
| `data_model.md` | Logical data model and data lifecycle |
| `api_contract.md` | API interface contracts |
| `data_sources.md` | External data/service provenance |
| `ui_spec.md` | UI/UX and interaction rules |
| `security.md` | Security, privacy, DPDP controls |
| `error_handling.md` | Error taxonomy and recovery behavior |
| `testing.md` | Verification and test strategy |
| `production_checklist.md` | Release readiness |
| `github_actions.md` | CI/CD requirements |
| `admob_spec.md` | Advertising requirements |
| `scrapping_spec.md` | Responsible data collection |
| `decisions.md` | Architecture/Product Decision Records |
| `changelog.md` | Documentation and decision history |
| `microtasks.md` | Small implementation units and acceptance criteria |
| `SKILL.md` | AI coding-agent operating instructions |

---

## 0. Project Context & Current Product Positioning

> **Core Positioning**: *"FitKarma — India's smartest, most private Health OS that works where you are — on WhatsApp and offline."*

FitKarma is an **India-first Health Operating System**, not merely a calorie tracker, workout logger, step counter, or generic AI fitness app.

The strategy combines four product pillars:

1. **Daily Intelligence Package (DIP)** — a contextual home experience that assembles the most relevant health information and next action for today.
2. **India-first nutrition and lifestyle** — Indian foods, household portions, cooking realities, family meals, fasting periods, local language and cultural context.
3. **Zero-friction interfaces** — WhatsApp text/voice logging plus offline-first in-app logging.
4. **Private digital health rails** — encrypted local storage, Supabase RLS, explicit family consent, and cascading right-to-erasure.

The competitive analysis identifies the strongest moat as the combination of **DPDP-aligned privacy, offline resilience, and ultra-low-friction WhatsApp logging tailored to Indian cultural habits**. The source also warns that a 16-phase scope is too ambitious for a solo founder and recommends severe scope reduction. This strategic conclusion is incorporated throughout the roadmap and prioritization documents.

### Audience

- Tier-1 urban professionals
- Tier-2/Tier-3 and lower-bandwidth users
- College students
- Families managing household health
- Corporate wellness programs
- Premium/clinical metabolic-health users

### Primary use cases

- Consolidating diet, sleep, workouts, wearable biometrics and CGM data
- Logging Indian meals with realistic portions and cooking assumptions
- Receiving actionable daily coaching without excessive AI calls
- Managing long-term health transformations offline and online
- Sharing selected health telemetry with consenting family members

---

## 1. System Overview & Key Moats

1. **Health OS Brain** — DIP orchestration and contextual dashboard generation.
2. **Deep Indian Nutrition Moat** — 500+ seeded regional recipes, street food, festival adaptations, vegetarian protein optimization, cooking-yield multipliers and Indian portion units.
3. **Conversational WhatsApp Interface** — voice/text logging in Hinglish first, with Hindi, Tamil and Telugu support in the localization roadmap.
4. **Clinical & Preventive Longevity** — Dynamic TDEE, biological age estimation, metabolic/CGM pipeline and clinical dossier generation where product scope permits.
5. **Family Health Governance** — family consent, role-based access, remote monitoring and crisis alerts.
6. **Privacy & Data Sovereignty** — local SQLCipher encryption, universal RLS, auditability, export and cascading right-to-erasure.
7. **India-native monetization** — UPI-first subscriptions, UPI AutoPay and micro-transaction “sachets”.

---

## 2. Technical Stack & Infrastructure

| Layer | Implementation | Status |
|---|---|---|
| Frontend | Flutter 3.24+ / Dart 3.5+ | Confirmed |
| State | Riverpod 2.x (`StateNotifierProvider`) | Confirmed |
| Local persistence | Drift + SQLCipher | Confirmed |
| Remote database | Supabase Postgres + RLS | Confirmed |
| Backend compute | Supabase Edge Functions (Deno/TypeScript) | Confirmed |
| Auth | Supabase Auth; phone OTP and Google OAuth | Confirmed |
| Storage | Supabase Storage, private buckets | Confirmed |
| Realtime/sync | Supabase Realtime + offline outbox | Confirmed |
| AI routing | Groq server-side via Edge Functions | Confirmed |
| Vision | Llama vision path; MediaPipe pose analysis is deferred | Source-supported / roadmap constrained |
| OS health | Google Health Connect + Apple Health/HealthKit | P0 |
| Payments | Razorpay + UPI + UPI AutoPay | Confirmed strategic direction |
| Push | Firebase Cloud Messaging | Confirmed |
| Monitoring | Sentry with PII scrubbing | Confirmed |
| CI/CD | GitHub Actions | Confirmed |

Exact third-party API versions, endpoint paths, secrets, quotas and legal terms are domain-controlled in `/docs`; undefined items are marked `PROPOSED` or `OPEN DECISION`.

---

## 3. Authoritative Monetisation Architecture

### Configurable commercial tiers

- **Yogi Free (₹0)** — manual food logging, steps, basic wellness/Ayurveda profile, offline caching, limited ads.
- **Karma Pro (₹149–₹199/month or ~₹1,499/year)** — WhatsApp voice logging, AI meal analysis, complete Indian recipe library, Dynamic TDEE, ad-free.
- **FitKarma Elite (₹1,999+/month)** — Pro features plus premium human/clinical services and advanced metabolic tracking, subject to operational/legal readiness.
- **Sachet Sprints (₹49–₹99)** — one-off focused health reports or short programs.

Pricing is **backend-configurable**. No price is hard-coded as an architectural constant.

### Payment source of truth

The client may initiate payment and display pending states, but subscription entitlements become active only after server-side verification of the payment provider event and the corresponding entitlement write. See `api_contract.md`, `security.md`, `decisions.md` and `testing.md`.

---

## 4. Product Strategy Updates from Competitive Analysis

The strategic analysis recommends the following priorities:

### P0

- WhatsApp voice logging
- Drift offline sync
- Indian portion/raw-cooked nutrition model
- Health Connect and Apple Health
- AI meal analysis
- Razorpay/UPI foundation

### P1

- AI photo recognition with explicit uncertainty and confirmation
- Family Recipe Splitter
- Family Care Dashboard
- Dynamic/adaptive TDEE moved earlier in roadmap

### P2

- ABHA/ABDM expansion
- Advanced recovery coaching
- Additional Indian languages
- Broader ecosystem/grocery integrations

### P3 / Deferred

- On-device pose estimation
- Custom social feed
- Proprietary wearable hardware
- Heavy video-content production

The feature-comparison matrix on pages 1–2 of the strategy analysis identifies FitKarma’s strongest differentiators as Indian food depth, Indian languages, offline mode, Ayurveda positioning and DPDP-oriented privacy. The prioritization table on page 6 places WhatsApp voice logging, Drift offline sync, Indian nutrition data and Health Connect in P0.

---

## 5. India-first Nutrition Requirements

FitKarma must support Indian foods and household measurement patterns including roti/chapati/paratha, rice, dal, rajma, chole, sabzi, poha, upma, idli, dosa, sambar, regional cuisines, street food, sweets, festival foods, restaurant foods and homemade meals.

Native portion units must include:

- `katori`
- `glass`
- `spoon`
- `piece`
- `serving`
- roti count
- idli count
- percentage of family recipe

The model must distinguish **raw vs cooked food** and retain preparation/cooking context. Cooking yield multipliers are part of the nutrition calculation path.

### Tadka / Tempering Slider

Users can select `Low`, `Medium`, or `High` for estimated oil/ghee/butter/tempering fat when exact fat quantity is unavailable. The UI and data model must label the result as an **estimate**.

### Family Recipe Splitter

A family meal can be entered using total raw ingredients, then allocated by the user’s consumed percentage (for example, “I ate 25%”). This feature must work offline and converge through the sync engine.

---

## 6. WhatsApp AI Logging

WhatsApp is a major FitKarma interface, not a marketing add-on.

Supported input modes:

- Text
- Voice notes
- Hinglish (P0)
- Hindi (P1)
- Tamil/Telugu (P2)

Canonical pipeline:

```text
WhatsApp
  ↓
Voice/Text Processing
  ↓
Language Detection
  ↓
AI Extraction
  ↓
Indian Food Database
  ↓
Portion Estimation
  ↓
Nutrition Calculation
  ↓
User Confirmation
  ↓
Food Log
  ↓
Daily Intelligence Package
```

AI output must include uncertainty/confidence where material. The system must not silently present uncertain food identification or portions as exact facts.

---

## 7. AI Photo Food Logging

P1 capability. The flow must include photo upload, Indian dish detection, portion estimation, nutrition estimation, user confirmation, privacy controls, image retention policy, deletion behavior and a manual fallback.

Photo recognition is an estimate and is not a substitute for user confirmation.

---

## 8. Dynamic TDEE

Adaptive TDEE is strategically moved earlier. Candidate inputs include body weight, weight trend, logged calorie intake, activity, steps, workouts, goals and historical data.

The algorithm must document:

- calculation method
- adjustment rules
- confidence/uncertainty
- smoothing/outlier handling
- user override behavior
- test fixtures

The exact mathematical algorithm remains `PROPOSED` until formally approved in `decisions.md`.

---

## 9. Health Ecosystem

### P0 OS-level integrations

- Android: Google Health Connect
- iOS: Apple Health / HealthKit

Use OS-level aggregation before building direct integrations with every wearable vendor. Normalize data, retain source attribution, manage permission scopes, handle background synchronization, resolve conflicts and honor deletion.

### Hardware/clinical tiers

- Tier 1: phone steps
- Tier 2: consumer wearables synced through OS health rails
- Tier 3: CGM/clinical integrations

---

## 10. Family Health

The strategy treats health decisions in India as household decisions. The **Family Care Dashboard** may enable a consenting adult to monitor selected metrics for a parent/family member, such as steps, weight, sleep, blood pressure, glucose/CGM, medication and activity.

Required safeguards:

- explicit affirmative consent
- role-based access
- revocation
- data minimization
- auditability
- crisis-alert guardrails that do not pretend to be emergency medical services

---

## 11. Festival/Fasting & AQI Fitness

### Festival/Fasting mode

Support user-selected periods such as Navratri, Ramzan, Karwa Chauth and other fasting schedules. Adapt reminders, hydration, meal timing and recommendations. Never infer religion or fasting participation automatically from identity.

### AQI-aware workout recommendations

Optional feature. When location/AQI data is available and permissioned, the app can suggest indoor alternatives during poor outdoor conditions. AQI source, thresholds, cache behavior and privacy are controlled by `data_sources.md` and `ui_spec.md`.

---

## 12. Ayurveda Positioning

Ayurveda remains a **cultural/wellness personalization layer**. Evidence-based metrics (CGM, BP, health records, etc.) must remain visibly separate from traditional wellness concepts. The product must not make unsupported diagnosis or disease-curing claims.

---

## 13. Women's Health

The product supports menstrual-cycle tracking, cycle-aware training, PCOS lifestyle tracking, symptoms, menopause and pregnancy-related functionality where appropriate. These are sensitive health data and require the security and privacy controls defined in `security.md`.

---

## 14. UX Philosophy — The Daily Intelligence Package

The strategy explicitly rejects a dashboard that displays every feature simultaneously. The homepage should dynamically assemble the user’s “today” based on the DIP: the most relevant health signal, context, recommendation, micro-action and status. Pregnancy, Dosha, CGM, recovery and other modules should not all compete for attention on every session.

---

## 15. Social & Gamification

Use functional squads and collective challenges rather than a native social network. Examples include corporate step challenges and family activity rings. Karma points should connect to tangible value where commercially feasible, including partner benefits.

---

## 16. Privacy & Data Sovereignty

FitKarma’s privacy model includes:

- SQLCipher local encryption
- Supabase RLS across data tables
- private storage controls
- server-side cascading deletion (`delete_user_data`)
- export support
- a visible **Data Vault** experience showing local vs cloud storage
- an “Erase my existence” action with auditable completion receipts

The legal specification must continue to distinguish product privacy controls from legal compliance claims and must be reviewed before launch.

---

## 17. Roadmap

### Phase 1 — Competitive MVP (Months 1–3)

- offline foundation
- Indian food database and basic nutrition
- Health Connect
- Apple Health
- authentication
- core health tracking
- Razorpay foundation and UPI

### Phase 2 — India-First Differentiation (Months 4–6)

- WhatsApp voice logging
- Hinglish AI
- AI meal analysis
- Tadka slider
- Family Recipe Splitter
- Dynamic TDEE
- UPI AutoPay
- Karma Pro

### Phase 3 — Category Leadership (Months 7–12)

- CGM pipeline
- ABHA/ABDM
- Family Care Dashboard
- advanced recovery
- grocery integrations
- additional Indian languages

This roadmap intentionally compresses and reprioritizes the larger original scope according to the competitive analysis. Large items remain documented as future/deferred rather than deleted.

---

## 18. Implementation Status and Source Discipline

The source documentation states that 160/160 automated unit/widget tests were passing, Flutter analysis reported zero issues, Postgres RLS tests were validated with pgTAP, and webhook/deletion paths were covered by automated tests. These are source-reported baseline claims and must be re-verified in the actual repository before relying on them as current release evidence.

Undefined details must be labeled:

- `PROPOSED` — a concrete recommendation not yet confirmed.
- `OPEN DECISION` — requires explicit product/architecture approval.

Major architectural changes require an ADR in `decisions.md`.

---

## 19. Canonical Documentation Entry Points

For future implementation work:

```text
Master Documentation
        │
        ├── docs/master_rules.md
        ├── docs/pdr.md
        ├── docs/trd.md
        ├── docs/architecture.md
        ├── docs/data_model.md
        ├── docs/api_contract.md
        ├── docs/data_sources.md
        ├── docs/ui_spec.md
        ├── docs/security.md
        ├── docs/error_handling.md
        ├── docs/testing.md
        ├── docs/production_checklist.md
        ├── docs/github_actions.md
        ├── docs/admob_spec.md
        ├── docs/scrapping_spec.md
        ├── docs/decisions.md
        ├── docs/changelog.md
        ├── docs/microtasks.md
        └── docs/SKILL.md
```

