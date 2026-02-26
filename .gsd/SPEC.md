# FitKarma Product Specification

Status: FINALIZED

## Overview
India's Most Affordable, Culturally-Rich Fitness App

Tech Stack: Flutter 3.x + PocketBase
Target Platform: Android & iOS
Architecture: Offline-first, Server-synced
State Management: Riverpod 2.x
Database: Hive (local) + SQLite (server)
Budget: Zero API costs in MVP

## 1. SYSTEM ARCHITECTURE
### Three-Tier Architecture
| Layer | Technology | Responsibility |
|-------|------------|----------------|
| Frontend | Flutter 3.x | UI/UX, Local business logic |
| Local Storage | Hive | Offline data persistence |
| Backend | PocketBase | Data sync, Authentication, File storage |
| External APIs | Free tier services | Food data, OCR, Maps, Notifications |

### Data Flow

**Create/Update:**
User Action → Save to Hive → Sync to PocketBase → Conflict resolution (last-write-wins)

**Read:**
Load from Hive → Background sync → Merge → Update UI

### Key Principles
* Offline-first
* Zero API costs
* Privacy-focused (medical data encrypted)
* App < 50MB
* Dashboard < 1 sec
* Battery optimized

## 2. TECHNOLOGY STACK
### Frontend
Flutter 3.x

Key Packages:
* flutter_riverpod
* hive
* pocketbase
* pedometer
* health
* camera
* image_picker
* barcode_scan2
* google_ml_kit
* geolocator
* flutter_map
* youtube_player_flutter
* fl_chart
* razorpay_flutter

### Backend
PocketBase (Open-source backend)
* Authentication
* SQLite database
* File storage
* REST API
* Real-time subscriptions

Hosting: VPS (2GB RAM, 50GB storage)

### External APIs (Free Tier)
* Open Food Facts
* Google ML Kit
* OpenStreetMap
* YouTube
* Firebase FCM
* Razorpay

## 3. DATABASE SCHEMA
### Core Collections
* Users
* Food Items
* Food Logs
* Workouts
* Workout Logs
* Medical Reports
* weight_logs
* steps_logs
* water_logs
* karma_transactions
* challenges
* posts
* subscriptions

### Local Hive Storage
* User profile
* 7-day food logs
* 30-day workout logs
* Steps data
* Top 500 food items
* Sync queue

## 4. CORE FEATURES
### Step Tracking
* Pedometer plugin
* Background tracking
* Graphs
* Calorie estimation
* Cricket overs conversion

### Food Logging
* Search
* Barcode scan
* Photo OCR
* Voice logging
* WhatsApp bot (Phase 2)

### Workout System
* YouTube-hosted videos
* Yoga
* Bollywood Dance
* Desi Workouts
* HIIT
* Indian Sports
* GPS tracking

### Medical Report OCR
* Google ML Kit
* Regex parsing
* Manual fallback
* Personalized recommendations

### Karma System
Earn via:
* Daily login
* Step goals
* Logging meals
* Workouts
* Streaks
* Community engagement

Redeem for:
* Premium features
* Physical rewards
* Donations

## 5. AI & ADVANCED FEATURES
### AI Health Twin
* Pattern learning
* Predictive alerts
* Rule-based → Claude → TensorFlow Lite roadmap

### Voice-First System
* Speech-to-text
* Multi-language support
* TTS responses

### AI Ayurvedic Personalization
* Dosha + Weather + Sleep + Stress → Custom recommendations

### AI Food Scanner
* Detect thali items
* 80% accuracy target
* ML Kit + TensorFlow Lite

## 6. API INTEGRATION
* Open Food Facts (barcode)
* Google ML Kit (OCR/object detection)
* Razorpay (subscriptions)

Subscription Plans:
* Monthly
* Quarterly
* Yearly
* Family

## 7. OFFLINE-FIRST ARCHITECTURE
### Write Flow
Hive → Sync Queue → PocketBase → Retry with exponential backoff

### Conflict Resolution
* Client wins (food/workout/weight)
* Server wins (karma, social posts)

### Offline Capabilities
* ✅ Food logging
* ✅ Workouts
* ✅ Step tracking
* ❌ Social feed
* ❌ Leaderboards

## 8. SECURITY & PRIVACY
### Encryption
* flutter_secure_storage
* HTTPS
* Certificate pinning
* AES for Hive

### Authentication
* Email
* Google OAuth
* Phone OTP
* Apple Sign-In

### Privacy Controls
* Profile visibility
* Data export
* Account deletion
* Medical data never shared

## 9. PERFORMANCE OPTIMIZATION
Targets:
* Splash < 2 sec
* Dashboard < 1 sec
* Video start < 3 sec
* Sync < 5 sec
* App size < 50MB

Optimizations:
* WebP images
* Lazy loading
* Split APK
* Delta sync
* Low data mode

## 10. DEVELOPMENT ROADMAP
### Phase 1 – MVP (Months 1–4)
Auth, food DB, workouts, karma, beta testing

### Phase 2 – Health & Community
OCR, social feed, challenges, GPS

### Phase 3 – Cultural Integration
Ayurveda, festivals, meal planner

### Phase 4 – AI & Scale
AI Health Twin, WhatsApp bot, marketplace

Year 1 Goal:
* 10,000 users
* 1,500 DAU
* 500 subscriptions

## 11–14. DevOps & Deployment
* Clean architecture folder structure
* Unit, widget, integration testing
* GitHub Actions CI/CD
* Crashlytics + Mixpanel + Sentry
* VPS deployment with SSL
* Play Store + App Store rollout
* Backup strategy
* Common troubleshooting steps

## 15. CONCLUSION
FitKarma aims to combine:
* Offline-first reliability
* Cultural relevance
* Zero-cost MVP
* Privacy-first approach
* Gamification

This is a living document to evolve with development.
