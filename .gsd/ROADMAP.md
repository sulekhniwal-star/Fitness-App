# ROADMAP.md — FitKarma

> **Current Phase**: 5
> **Milestone**: v1.0 MVP
> **Last Updated**: 2026-02-24

---

## Must-Haves (MVP — from SPEC)

- [x] Flutter project scaffolded with clean architecture
- [x] PocketBase backend deployed with all collections
- [x] Authentication (email, Google, phone OTP)
- [x] Food logging (search, barcode, OCR, voice) — offline-first
- [x] Step tracking with background pedometer
- [x] Workout system with YouTube videos
- [x] Karma system (earn/persist/display)
- [x] Medical report OCR
- [x] Razorpay subscriptions
- [x] Release APK < 50MB, dashboard < 1s

---

## Phase 1: Foundation & MVP Core
**Status**: ✅ Complete
**Objective**: Scaffold the Flutter app, configure PocketBase, implement authentication, offline-first data layer (Hive), and the app shell with navigation. Deliver a working skeleton that all subsequent features plug into.

**Deliverables:**
- Flutter project with clean architecture folder structure
- Riverpod 2.x state management wired up
- Hive local storage (all boxes defined and initialized)
- PocketBase client configured (auth, sync queue)
- Auth screens: Register, Login, Google OAuth, Phone OTP
- Bottom navigation shell + routing (go_router)
- Offline-first sync engine (write-to-Hive → queue → sync)
- Splash screen, onboarding (3 screens), profile setup

**Requirements**: REQ-01 through REQ-08

---

## Phase 2: Core Features — Food, Steps & Karma
**Status**: ✅ Complete
**Objective**: Implement the three flagship daily-use features: food logging, step tracking, and the karma reward engine. These are the core engagement loops that drive daily active use.

**Deliverables:**
- Food logging UI (search, barcode scan, photo OCR, voice)
- Open Food Facts API integration + local 500-item cache
- Meal type flow (breakfast/lunch/dinner/snack/chai)
- Step tracking with pedometer plugin (background service)
- Daily step goal, cricket overs converter, calorie estimate
- fl_chart graphs (daily/weekly/monthly steps + calories)
- Karma engine (earn events, balance, transaction history)
- Dashboard screen (step ring, calories, water, karma badge)

**Requirements**: REQ-09 through REQ-18

---

## Phase 3: Workouts & Medical Records
**Status**: ✅ Complete
**Objective**: Deliver the workout discovery system with culturally-relevant YouTube videos, and the medical report OCR pipeline for health-record digitization.

**Deliverables:**
- Workout browser (categories: Yoga, Bollywood Dance, Desi, HIIT, Indian Sports)
- YouTube player integration (youtube_player_flutter)
- Workout detail screen + log workout flow
- Calorie burn estimation per workout type
- Medical report capture (camera + gallery)
- Google ML Kit OCR text recognition
- Regex parsers for HbA1c, BP, cholesterol, hemoglobin, glucose
- Manual entry fallback UI
- Health alerts and trend display
- Weight log + BMI tracker

**Requirements**: REQ-19 through REQ-28

---

## Phase 4: Subscriptions, Polish & Beta Launch
**Status**: ✅ Complete
**Objective**: Integrate Razorpay subscriptions, conduct performance optimization (< 50MB APK, < 1s dashboard), add PocketBase real-time notifications, finalize analytics, and deploy to Play Store beta.

**Deliverables:**
- Subscription screen (Free / Monthly / Quarterly / Yearly / Family)
- Razorpay payment integration + webhook handling
- Premium feature gates
- PocketBase real-time notifications (workout reminders, step goal, karma milestones)
- Mixpanel + Crashlytics + Sentry configured
- Performance audit: lazy loading, WebP images, split APK
- App size validation (< 50MB)
- PocketBase VPS deployment with SSL (Nginx reverse proxy)
- Play Store beta release preparation
- Beta testing feedback collection

**Requirements**: REQ-29 through REQ-36

---

## Phase 5: Health & Community (Post-MVP)
**Status**: 🚧 In Progress
**Objective**: Social features, GPS workout tracking, community challenges, and leaderboards. This is Phase 2 from the product roadmap.

**Deliverables:**
- Social feed (posts, likes, comments)
- Community challenges system
- GPS activity tracking (geolocator + flutter_map)
- Leaderboard (karma-based, weekly reset)
- WhatsApp bot MVP (Phase 2.5)

---

## Phase 6: Cultural Integration (Post-MVP)
**Status**: ⬜ Not Started
**Objective**: Ayurvedic personalization, festival calendar, vernacular language support, AI-powered meal planner. Phase 3 from product roadmap.

**Deliverables:**
- Dosha quiz + Ayurvedic recommendations engine
- Festival calendar with adjusted meal/workout plans
- Hindi + regional language UI (flutter_localizations)
- 7-day AI meal planner (rule-based, zero API cost)
- Voice-first logging in Hindi/English

---

## Phase 7: AI & Scale
**Status**: ⬜ Not Started
**Objective**: AI Health Twin, ML-powered food scanner (thali detection), WhatsApp bot, marketplace. Phase 4 from product roadmap.

**Deliverables:**
- AI Health Twin (pattern learning, predictive alerts)
- TensorFlow Lite food recognition model (80% accuracy target)
- WhatsApp bot for food/workout logging
- Karma marketplace (physical rewards)
- Team challenges + corporate wellness
