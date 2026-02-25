# SPEC.md — FitKarma Project Specification

> **Status**: `FINALIZED`
> **Created**: 2026-02-24
> **Version**: 1.0

---

## Vision

FitKarma is India's most affordable, culturally-rich fitness app — a Flutter 3.x + PocketBase application targeting Android and iOS. It is offline-first, privacy-focused, and entirely free of API costs in its MVP phase. FitKarma combines step tracking, food logging, culturally-relevant workouts (yoga, Bollywood dance, desi workouts, Indian sports), a gamified Karma reward system, and medical report digitization — all tailored to Indian users with vernacular language support, Ayurvedic personalization, and festival-awareness.

---

## Goals

1. **Ship a working MVP** (Phase 1, ~4 months) with auth, food logging, workouts, step tracking, and karma system
2. **Zero ongoing API costs** in MVP — all services on free tiers or self-hosted
3. **Offline-first reliability** — core features (food, workouts, steps, weight) work without internet
4. **Cultural relevance** — Bollywood dance, yoga, Ayurveda, vernacular UI, Indian food database
5. **Privacy-first** — medical data encrypted at rest, never shared externally
6. **Performance targets** — app < 50MB, splash < 2s, dashboard < 1s
7. **Grow to 10,000 users / 1,500 DAU / 500 subscriptions by end of Year 1**

---

## Non-Goals (Out of Scope for MVP)

- WhatsApp bot integration (Phase 2+)
- AI Health Twin / TensorFlow Lite model (Phase 4)
- Marketplace / physical rewards redemption (Phase 4)
- Social feed and leaderboards (Phase 2)
- GPS route tracking (Phase 2)
- Apple Sign-In (Phase 2+, add once iOS is targeted)
- Government-aligned features / ABDM integration

---

## Users

| Persona | Description |
|---------|-------------|
| **Primary** | Indian adults (18–45) wanting fitness guidance in a culturally familiar context |
| **Secondary** | Users seeking affordable alternatives to gyms; home workout enthusiasts |
| **Tertiary** | Health-conscious users managing chronic conditions via diet/exercise logs |

Key traits: smartphone-first, price-sensitive, vernacular language preference, strong affinity for Bollywood/yoga/cricket references.

---

## Technology Stack

| Layer | Technology | Notes |
|-------|-----------|-------|
| Frontend | Flutter 3.x | Android + iOS |
| State management | Riverpod 2.x | |
| Local storage | Hive | Offline persistence |
| Backend | PocketBase | Self-hosted VPS |
| Food data | Open Food Facts API | Free, no cost |
| OCR | Google ML Kit | On-device, free |
| Maps | OpenStreetMap / flutter_map | Free |
| Video | YouTube (youtube_player_flutter) | Free |
| Payments | Razorpay | Subscriptions |
| Notifications | PocketBase | Real-time subscriptions |
| Analytics | Mixpanel + Crashlytics + Sentry | Free tiers |

---

## Architecture

**Three-Tier Offline-First:**

```
User Action → Hive (local write) → Sync Queue → PocketBase → Conflict resolution
Read path  → Hive (fast) → Background sync → Merge → Update UI
```

**Conflict Resolution:**
- Client wins: food logs, workout logs, weight logs
- Server wins: karma transactions, social posts

**Offline capabilities (MVP):**
- ✅ Food logging
- ✅ Workout browsing & logging
- ✅ Step tracking
- ✅ Weight/water/medical logs
- ❌ Social feed
- ❌ Leaderboards

---

## Database Schema (PocketBase Collections)

| Collection | Key Fields |
|------------|-----------|
| users | email, phone, name, dob, gender, height, weight_kg, dosha, preferred_language, subscription_tier |
| food_items | name, name_hi, barcode, calories, protein_g, carbs_g, fat_g, fiber_g, brand, is_indian, verified |
| food_logs | user, date, meal_type, food_item, quantity_g, calories, logged_via |
| workouts | title, category (yoga/dance/hiit/sport/desi), duration_min, youtube_id, thumbnail_url, difficulty, language |
| workout_logs | user, workout, date, duration_min, calories_burned |
| medical_reports | user, report_type, report_date, extracted_data (json), raw_image, is_processed |
| weight_logs | user, date, weight_kg, body_fat_pct, notes |
| steps_logs | user, date, steps, calories, distance_km, source |
| water_logs | user, date, total_ml |
| karma_transactions | user, amount, type (earn/redeem), source, description, balance_after |
| challenges | title, description, start_date, end_date, karma_reward, goal_type, goal_value |
| posts | user, content, image_url, likes, challenge (optional), is_public |
| subscriptions | user, plan_type (monthly/quarterly/yearly/family), status, start_date, end_date, razorpay_subscription_id |

**Local Hive Boxes:**
- `userBox` — profile
- `foodLogBox` — 7-day rolling food logs
- `workoutLogBox` — 30-day workout logs
- `stepsBox` — step data
- `foodCacheBox` — top 500 Indian food items
- `syncQueueBox` — pending sync operations

---

## Core Features (MVP — Phase 1)

### Authentication
- Email + password
- Google OAuth
- Phone OTP (via PocketBase)
- JWT tokens, refresh logic

### Step Tracking
- `pedometer` plugin (background)
- Daily goal (default: 8,000 steps)
- Cricket overs conversion (fun metric)
- Calorie estimation
- fl_chart graphs (daily/weekly/monthly)

### Food Logging
- Search Open Food Facts + local Hive cache
- Barcode scan (`barcode_scan2`)
- Photo OCR (`google_ml_kit`)
- Voice logging (`speech_to_text`)
- Meal types: breakfast / lunch / dinner / snack / chai
- Indian meal templates (thali, dal-rice, etc.)

### Workout System
- YouTube-hosted videos (`youtube_player_flutter`)
- Categories: Yoga, Bollywood Dance, Desi Workouts, HIIT, Indian Sports
- Offline metadata cached; video streams on-demand
- Duration, difficulty, calorie burn estimate

### Medical Report OCR
- Capture via camera or gallery
- `google_ml_kit` text recognition
- Regex parsing for: HbA1c, blood pressure, cholesterol, hemoglobin, fasting glucose
- Manual entry fallback
- Personalized health alerts

### Karma System
- **Earn**: daily login (+5), step goal met (+10), meal logged (+3), workout done (+15), 7-day streak (+50), challenge complete (+variable)
- **Redeem**: premium feature unlock, future physical rewards (Phase 4)
- Leaderboard (Phase 2)

### Subscriptions
- Free | Monthly ₹99 | Quarterly ₹249 | Yearly ₹799 | Family ₹1,299/yr
- Razorpay integration
- Premium unlocks: advanced analytics, AI insights, recipe planner

---

## Security & Privacy

- `flutter_secure_storage` for tokens
- HTTPS only + certificate pinning
- AES encryption for sensitive Hive boxes (medical data)
- Medical data never transmitted to third parties
- Data export (JSON) and account deletion flows
- Profile visibility controls

---

## Performance Targets

| Metric | Target |
|--------|--------|
| Splash screen | < 2 seconds |
| Dashboard load | < 1 second |
| Video start | < 3 seconds |
| Background sync | < 5 seconds |
| App size | < 50 MB |

**Optimizations:** WebP images, lazy loading, split APK (Android), delta sync, low-data mode toggle.

---

## Success Criteria

- [ ] App builds and runs on Android (Release APK < 50MB)
- [ ] User can register, log in, and persist session offline
- [ ] Food logging works offline and syncs to PocketBase
- [ ] Step tracking runs in background and shows daily graph
- [ ] At least 3 workout videos playable via YouTube
- [ ] Karma points awarded and persisted correctly
- [ ] Medical report OCR extracts at least 3 key fields
- [ ] Razorpay subscription flow completes end-to-end
- [ ] PocketBase deployed to VPS with SSL
- [ ] All core actions work without internet connectivity

---

## Development Phases Overview

| Phase | Focus | Target |
|-------|-------|--------|
| 1 | MVP Foundation | Auth, food DB, workouts, karma, beta |
| 2 | Health & Community | OCR, social feed, GPS, challenges |
| 3 | Cultural Integration | Ayurveda, festivals, meal planner, voice |
| 4 | AI & Scale | AI Health Twin, WhatsApp bot, marketplace |
