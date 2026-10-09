import 'package:fitkarma/app/fitkarma_app.dart';
import 'package:fitkarma/core/config/app_config.dart';
import 'package:fitkarma/core/providers/core_providers.dart';
import 'package:fitkarma/core/supabase/mock_supabase_service.dart';
import 'package:fitkarma/core/supabase/supabase_providers.dart';
import 'package:fitkarma/features/profile/data/repositories/local_first_profile_repository.dart';
import 'package:fitkarma/features/profile/domain/models/profile_enums.dart';
import 'package:fitkarma/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testConfig = AppConfig.fromMap({
    'APP_ENV': 'development',
    'SUPABASE_URL': 'https://test.supabase.co',
    'SUPABASE_ANON_KEY': 'test-anon-key',
  });

  Widget buildTestApp({
    MockSupabaseService? mockSupabase,
    LocalFirstProfileRepository? profileRepository,
  }) {
    final supabase = mockSupabase ?? MockSupabaseService();
    final repo = profileRepository ??
        LocalFirstProfileRepository(supabaseService: supabase);

    return ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(testConfig),
        supabaseServiceProvider.overrideWithValue(supabase),
        supabaseAuthServiceProvider.overrideWithValue(supabase.auth),
        userProfileRepositoryProvider.overrideWithValue(repo),
      ],
      child: const FitKarmaApp(),
    );
  }

  group('FitKarma Complete Onboarding Flow End-to-End Tests', () {
    void setViewport(WidgetTester tester) {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    testWidgets(
      'Step 1 (Welcome): displays value proposition and advances to Language',
      (tester) async {
        setViewport(tester);

        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // 1. Assert Welcome & Value Proposition
        expect(find.byKey(const Key('screen_onboarding')), findsOneWidget);
        expect(find.text("India's Private Health OS"), findsOneWidget);
        expect(find.text('FITKARMA HEALTH OS'), findsOneWidget);
        expect(find.text('🇮🇳 India-First Nutrition'), findsOneWidget);
        expect(find.text('🔒 Privacy by Default'), findsOneWidget);
        expect(find.text('⚡ Offline-First Architecture'), findsOneWidget);
        expect(find.text('🌿 Holistic Wellness & Fasting'), findsOneWidget);

        // Progress to Step 2 (Language)
        final getStartedBtn = find.byKey(const Key('btn_onboarding_next'));
        expect(getStartedBtn, findsOneWidget);
        await tester.tap(getStartedBtn);
        await tester.pumpAndSettle();

        // Now at Language Selection
        expect(find.text('Choose Your Language'), findsOneWidget);
        expect(find.byKey(const Key('lang_option_en')), findsOneWidget);
        expect(find.byKey(const Key('lang_option_hi')), findsOneWidget);
      },
    );

    testWidgets(
      'Step 2 (Language): switches locale dynamically and previews regional languages',
      (tester) async {
        setViewport(tester);

        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Advance to Language step
        await tester.tap(find.byKey(const Key('btn_onboarding_next')));
        await tester.pumpAndSettle();

        expect(find.text('Choose Your Language'), findsOneWidget);
        expect(find.text('REGIONAL LANGUAGES (PREPARING)'), findsOneWidget);
        expect(find.text('தமிழ் (Tamil)'), findsOneWidget);
        expect(find.text('తెలుగు (Telugu)'), findsOneWidget);

        // Select Hindi
        await tester.tap(find.byKey(const Key('lang_option_hi')));
        await tester.pumpAndSettle();

        // Verify dynamic translation update across UI
        expect(find.text('अपनी भाषा चुनें'), findsOneWidget);
        expect(find.text('आगे बढ़ें'), findsOneWidget);

        // Select English again
        await tester.tap(find.byKey(const Key('lang_option_en')));
        await tester.pumpAndSettle();

        expect(find.text('Choose Your Language'), findsOneWidget);
        expect(find.text('Continue'), findsOneWidget);
      },
    );

    testWidgets(
      'Step 3 (Consent & Medical Disclaimer): blocks progression until affirmative consent',
      (tester) async {
        setViewport(tester);

        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Step 1 -> Step 2
        await tester.tap(find.byKey(const Key('btn_onboarding_next')));
        await tester.pumpAndSettle();

        // Step 2 -> Step 3 (Consent)
        await tester.tap(find.byKey(const Key('btn_onboarding_next')));
        await tester.pumpAndSettle();

        expect(find.text('Privacy & DPDP Consent'), findsOneWidget);
        expect(
          find.textContaining('Medical Disclaimer: FitKarma provides lifestyle'),
          findsOneWidget,
        );

        // Attempting to continue without checking consent
        await tester.tap(find.byKey(const Key('btn_onboarding_next')));
        await tester.pumpAndSettle();

        // Should display error banner and remain on Step 3
        expect(find.byKey(const Key('onboarding_error_banner')), findsOneWidget);
        expect(
          find.text(
            'Please agree to the privacy notice and data processing consent to continue.',
          ),
          findsOneWidget,
        );

        // Check consent checkbox
        await tester.tap(find.byKey(const Key('consent_checkbox')));
        await tester.pumpAndSettle();

        // Now progression succeeds
        await tester.tap(find.byKey(const Key('btn_onboarding_next')));
        await tester.pumpAndSettle();

        // Now at Basic Profile
        expect(find.text('Basic Profile'), findsOneWidget);
      },
    );

    testWidgets(
      'Step 4 (Basic Profile): enforces physiological boundaries and validates inputs',
      (tester) async {
        setViewport(tester);

        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Step 1 -> 2 -> 3
        await tester.tap(find.byKey(const Key('btn_onboarding_next')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('btn_onboarding_next')));
        await tester.pumpAndSettle();

        // Agree consent -> Step 4
        await tester.tap(find.byKey(const Key('consent_checkbox')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('btn_onboarding_next')));
        await tester.pumpAndSettle();

        expect(find.text('Basic Profile'), findsOneWidget);

        // Try continuing with empty display name
        await tester.tap(find.byKey(const Key('btn_onboarding_next')));
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('onboarding_error_banner')), findsOneWidget);

        // Enter valid name, age, height, weight
        await tester.enterText(
          find.byKey(const Key('input_display_name')),
          'Diya Sharma',
        );
        await tester.enterText(find.byKey(const Key('input_age')), '26');
        await tester.enterText(find.byKey(const Key('input_height_cm')), '165');
        await tester.enterText(find.byKey(const Key('input_weight_kg')), '58');

        // Select Female biological sex chip
        await tester.tap(find.byKey(const Key('chip_sex_female')));
        await tester.pumpAndSettle();

        // Progress to Step 5 (Goals)
        await tester.tap(find.byKey(const Key('btn_onboarding_next')));
        await tester.pumpAndSettle();

        expect(find.text('Fitness & Health Goals'), findsOneWidget);
      },
    );

    testWidgets(
      'Steps 5-9: verifies goals, dietary identity, activity, ayurveda, and permissions',
      (tester) async {
        setViewport(tester);

        await tester.pumpWidget(buildTestApp());
        await tester.pumpAndSettle();

        // Navigate to Step 4
        await tester.tap(find.byKey(const Key('btn_onboarding_next')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('btn_onboarding_next')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('consent_checkbox')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('btn_onboarding_next')));
        await tester.pumpAndSettle();

        // Fill Basic Profile
        await tester.enterText(
          find.byKey(const Key('input_display_name')),
          'Rohan Mehra',
        );
        await tester.enterText(find.byKey(const Key('input_age')), '30');
        await tester.enterText(find.byKey(const Key('input_height_cm')), '178');
        await tester.enterText(find.byKey(const Key('input_weight_kg')), '75');
        await tester.tap(find.byKey(const Key('btn_onboarding_next')));
        await tester.pumpAndSettle();

        // --- Step 5: Goals ---
        expect(find.text('Fitness & Health Goals'), findsOneWidget);
        await tester.tap(find.byKey(const Key('goal_card_muscleGain')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('btn_onboarding_next')));
        await tester.pumpAndSettle();

        // --- Step 6: Dietary Identity ---
        expect(find.text('Dietary Identity & Preferences'), findsOneWidget);
        expect(find.byKey(const Key('diet_card_pureVeg')), findsOneWidget);
        expect(find.byKey(const Key('diet_card_jain')), findsOneWidget);
        // Select Jain diet
        await tester.tap(find.byKey(const Key('diet_card_jain')));
        await tester.pumpAndSettle();
        // Select 16:8 fasting protocol
        await tester.tap(find.byKey(const Key('chip_fasting_16_8')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('btn_onboarding_next')));
        await tester.pumpAndSettle();

        // --- Step 7: Activity Baseline ---
        expect(find.text('Activity Baseline'), findsOneWidget);
        await tester.tap(find.byKey(const Key('activity_card_moderatelyActive')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('btn_onboarding_next')));
        await tester.pumpAndSettle();

        // --- Step 8: Ayurveda & Prakriti (Optional) ---
        expect(find.text('Ayurveda & Prakriti (Optional)'), findsOneWidget);
        expect(
          find.textContaining('Ayurvedic insights provide traditional lifestyle'),
          findsOneWidget,
        );
        expect(find.byKey(const Key('dosha_card_pitta')), findsOneWidget);
        // Select Pitta
        await tester.tap(find.byKey(const Key('dosha_card_pitta')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('btn_onboarding_next')));
        await tester.pumpAndSettle();

        // --- Step 9: Permissions ---
        expect(find.text('Permissions & Integrations'), findsOneWidget);
        expect(find.byKey(const Key('switch_notifications')), findsOneWidget);
        expect(find.byKey(const Key('switch_health_sync')), findsOneWidget);

        // Toggle Health sync
        await tester.tap(find.byKey(const Key('switch_health_sync')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('btn_onboarding_next')));
        await tester.pumpAndSettle();

        // --- Step 10: Account Setup ---
        expect(find.text('Account Setup'), findsOneWidget);
        expect(find.byKey(const Key('btn_signup_phone')), findsOneWidget);
        expect(find.byKey(const Key('btn_signup_google')), findsOneWidget);
        expect(find.byKey(const Key('btn_continue_as_guest')), findsOneWidget);
      },
    );

    testWidgets(
      'Full End-to-End: completing onboarding as Guest launches user into Dashboard and persists UserProfile',
      (tester) async {
        setViewport(tester);

        final mockSupabase = MockSupabaseService();
        final repository =
            LocalFirstProfileRepository(supabaseService: mockSupabase);

        await tester.pumpWidget(
          buildTestApp(
            mockSupabase: mockSupabase,
            profileRepository: repository,
          ),
        );
        await tester.pumpAndSettle();

        // 1. Welcome -> Language
        await tester.tap(find.byKey(const Key('btn_onboarding_next')));
        await tester.pumpAndSettle();

        // 2. Language -> Consent
        await tester.tap(find.byKey(const Key('btn_onboarding_next')));
        await tester.pumpAndSettle();

        // 3. Consent -> Basic Profile
        await tester.tap(find.byKey(const Key('consent_checkbox')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('btn_onboarding_next')));
        await tester.pumpAndSettle();

        // 4. Fill Profile -> Goals
        await tester.enterText(
          find.byKey(const Key('input_display_name')),
          'Kavita Nair',
        );
        await tester.enterText(find.byKey(const Key('input_age')), '29');
        await tester.enterText(find.byKey(const Key('input_height_cm')), '168');
        await tester.enterText(find.byKey(const Key('input_weight_kg')), '62');
        await tester.tap(find.byKey(const Key('chip_sex_female')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('btn_onboarding_next')));
        await tester.pumpAndSettle();

        // 5. Goals -> Dietary
        await tester.tap(find.byKey(const Key('btn_onboarding_next')));
        await tester.pumpAndSettle();

        // 6. Dietary -> Activity
        await tester.tap(find.byKey(const Key('diet_card_pureVeg')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const Key('btn_onboarding_next')));
        await tester.pumpAndSettle();

        // 7. Activity -> Ayurveda
        await tester.tap(find.byKey(const Key('btn_onboarding_next')));
        await tester.pumpAndSettle();

        // 8. Ayurveda -> Skip
        await tester.tap(find.byKey(const Key('btn_skip_ayurveda')));
        await tester.pumpAndSettle();

        // 9. Permissions -> Account Setup
        await tester.tap(find.byKey(const Key('btn_onboarding_next')));
        await tester.pumpAndSettle();

        // 10. Account Setup: Tap "Explore as Guest"
        expect(find.byKey(const Key('btn_continue_as_guest')), findsOneWidget);
        await tester.tap(find.byKey(const Key('btn_continue_as_guest')));
        await tester.pumpAndSettle();

        // Assert user reaches main app Dashboard!
        expect(find.byKey(const Key('screen_dashboard')), findsOneWidget);
        expect(find.text('Daily Intelligence Package (DIP)'), findsOneWidget);

        // Assert UserProfile was accurately constructed and saved in repository
        final savedProfileResult = await repository.getProfile();
        expect(savedProfileResult.isSuccess, isTrue);

        final profile = savedProfileResult.dataOrNull;
        expect(profile, isNotNull);
        expect(profile?.displayName, equals('Kavita Nair'));
        expect(profile?.age, equals(29));
        expect(profile?.biologicalSex, equals(BiologicalSex.female));
        expect(profile?.heightCm, equals(168.0));
        expect(profile?.weightKg, equals(62.0));
        expect(profile?.dietaryIdentity, equals(DietaryIdentity.pureVeg));
      },
    );
  });
}
