# STATE.md

## Current Position
- **Phase**: 3 (Workouts & Medical Records)
- **Status**: Planning Complete - Ready for Execution
- **Last Updated**: 2026-02-24

## Progress Summary

### Phase 2 Completed Tasks:
✅ [Plan 2.1] Implemented FoodRepository calling Open Food Facts API and caching to Hive. Exposed FoodProvider StateNotifier.
✅ [Plan 2.2] Created StepProvider capturing `pedometer` stream safely mapping daily tracking logic into Hive, including Android permissions.
✅ [Plan 2.3] Setup KarmaNotifier mapped explicitly to auth state and sync provider for reliable currency rewards local-first updates.
✅ [Plan 2.4] Connected `barcode_scan2` scanning mapping directly into `FoodSearchDelegate` capturing meal logging securely giving UI visibility into `FoodLogs` offline.
✅ [Plan 2.5] Bound `StepProvider` output and `KarmaNotifier` state securely into `DashboardTab` mapping progress directly to `HiveService` historical steps on native un-mocked visual interfaces.

### Phase 1 Completed Tasks:
✅ [Plan 1.1] Flutter project formally scaffolded with correct `.android`/`.ios`/`.web` configs in `fitkarma` subdirectory
✅ [Plan 1.1] pubspec.yaml updated with all requested dependencies and resolved via `flutter pub get`
✅ [Plan 1.1] Clean architecture folder structure generated under `lib/features` and `lib/shared`
✅ Legacy mock files migrated into `fitkarma` prefix
✅ App constants defined (colors, strings, box names)
✅ App theme configured (Indian-inspired colors - Saffron, Green, etc.)
✅ User model with Hive annotations
✅ Food log model with Hive annotations
✅ Hive adapters generated for UserModel and FoodLogModel
✅ HiveProvider for managing all Hive boxes
✅ PocketBaseProvider for backend connection and auth token management
✅ AuthProvider with Riverpod state management (email/password, Google placeholder)
✅ Router configured with go_router (auth redirects, all routes)
✅ Splash screen with animations
✅ Onboarding screen (4 screens)
✅ Login screen with email/password
✅ Register screen
✅ Phone OTP screen (placeholder)
✅ Home screen with bottom navigation
✅ Dashboard tab with step counter, charts, quick actions
✅ Bottom nav bar widget
✅ Food logging screen (meal types, quick add)
✅ Workout list screen (categories: Yoga, Bollywood, Desi, HIIT, Sports)
✅ Profile screen with menu items

✅ Prepare PocketBase config (`backend/pb_schema.json` for all core entities)
✅ Created backend folder and PocketBase setup instructions
✅ [Plan 1.2] Initialize Hive in `main.dart` and `hive_service.dart` with all required boxes.
✅ [Plan 1.2] Setup PocketBase Client via `pocketbase_client.dart` with secure storage persistence.
✅ Addressed all known UI/legacy code issues within `lib/presentation`.
✅ Executed `build_runner` to clean and regenerate `.g.dart` files.
✅ Validated codebase with `flutter analyze` perfectly.
✅ [Plan 1.3] Set up GoRouter StatefulShellRoute configuration with bottom navigation tabs.
✅ [Plan 1.3] Developed AppShell to seamlessly preserve state and display BottomNavBar.
✅ [Plan 1.4] Built cultured Splash and Onboarding UI flow with GoRouter redirects.
✅ [Plan 1.4] Set up standard Registration and Login logic tied to PocketBase provider and GoRouter auth state.
✅ [Plan 1.5] Built SyncService tracking `connectivity_plus` to listen for network state and iteratively drain `syncQueueBox` tracking retries with exponential back-off into `PocketBase` clients.

### Files Created:
- backend/README.md
- backend/pb_schema.json
- fitkarma/pubspec.yaml
- fitkarma/lib/main.dart
- fitkarma/lib/core/constants/app_constants.dart
- fitkarma/lib/core/theme/app_theme.dart
- fitkarma/lib/core/utils/router.dart
- fitkarma/lib/data/models/user_model.dart
- fitkarma/lib/data/models/user_model.g.dart
- fitkarma/lib/data/models/food_log_model.dart
- fitkarma/lib/data/models/food_log_model.g.dart
- fitkarma/lib/data/providers/hive_provider.dart
- fitkarma/lib/data/providers/pocketbase_client.dart
- fitkarma/lib/data/providers/auth_provider.dart
- fitkarma/lib/presentation/screens/home/splash_screen.dart
- fitkarma/lib/presentation/screens/home/onboarding_screen.dart
- fitkarma/lib/presentation/screens/home/home_screen.dart
- fitkarma/lib/presentation/screens/home/dashboard_tab.dart
- fitkarma/lib/presentation/screens/auth/login_screen.dart
- fitkarma/lib/presentation/screens/auth/register_screen.dart
- fitkarma/lib/presentation/screens/auth/phone_otp_screen.dart
- fitkarma/lib/presentation/screens/food/food_logging_screen.dart
- fitkarma/lib/presentation/screens/workouts/workout_list_screen.dart
- fitkarma/lib/presentation/screens/profile/profile_screen.dart
- fitkarma/lib/presentation/widgets/bottom_nav_bar.dart
- fitkarma/lib/shared/widgets/app_shell.dart
- fitkarma/lib/core/sync/sync_service.dart
- fitkarma/lib/data/repositories/food_repository.dart
- fitkarma/lib/data/providers/food_provider.dart
- fitkarma/lib/data/providers/step_provider.dart
- fitkarma/lib/data/providers/karma_provider.dart
- fitkarma/lib/presentation/screens/food/food_search_delegate.dart

## Deviations/Constraints
- **GSD Executor Note**: Flutter command rejected root folder "Fitness App" due to dart package naming conventions. The Flutter root directory is officially designated as `fitkarma/`. Future plans running Flutter CLI tools must use `fitkarma/` as their working directory.

## Last Session Summary
Phase 2 executed successfully. 5 plans, 7 tasks completed mapping pedometer streams, barcode scanners, open food facts APIs, and local caching.

## Next Steps
1. Execute Plan 3.1 `3.1-workout-data.md`
2. Run `/execute 3` when ready.

## Known Issues (require flutter run / build runner)
- None. `flutter analyze` passes perfectly.
