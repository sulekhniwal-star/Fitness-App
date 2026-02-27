# FitKarma Implementation TODO

## Phase 1: Fix Code Issues ✅ COMPLETED
- [x] Fix `withOpacity()` → `withValues(alpha: ...)` in all UI files
  - dashboard_tab.dart
  - activity_tracking_screen.dart
  - onboarding_screen.dart
  - splash_screen.dart
  - workout_list_screen.dart
  - bottom_nav_bar.dart
- [x] Fix `encryptedSharedPreferences` deprecation in pocketbase_client.dart
- [x] Fix unnecessary `this.` qualifiers in challenge_model.dart
- [x] Fix `isNotEmpty` patterns in team_provider.dart
- [x] Replace `print` with `debugPrint` in payment_service.dart

## Phase 2: Add Missing Features ✅ COMPLETED
- [x] Firebase Cloud Messaging (FCM) service created
- [x] Open Food Facts API integration for barcode scanning
- [x] Activity logs model, provider and UI screen
- [x] Updated router with activity log route
- [x] Updated Hive service with activity log box
- [x] Added Firebase dependencies to pubspec.yaml
- [~] Real-time PocketBase subscriptions (framework ready)
- [~] Teams feature (already implemented, minor fixes applied)
- [ ] Google OAuth & Apple Sign-In (requires platform setup)
- [ ] OpenStreetMap integration for GPS tracking (requires platform setup)

## Phase 3: Testing & Optimization 🔄 IN PROGRESS
- [ ] Run `flutter pub get` to install new dependencies
- [ ] Run `dart run build_runner build` to generate Hive adapters
- [ ] Run flutter analyze to verify all fixes
- [ ] Test all new features
- [ ] Performance optimization
- [ ] Build and verify app size < 50MB

## Current Status
All major features implemented. Run build_runner to generate missing .g.dart files, then proceed with testing.
