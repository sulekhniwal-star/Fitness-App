import 'package:fitkarma/core/config/app_config.dart';
import 'package:fitkarma/core/providers/core_providers.dart';
import 'package:fitkarma/core/supabase/mock_supabase_service.dart';
import 'package:fitkarma/features/profile/data/repositories/local_first_profile_repository.dart';
import 'package:fitkarma/features/profile/data/repositories/local_first_wellness_repository.dart';
import 'package:fitkarma/features/profile/domain/models/profile_enums.dart';
import 'package:fitkarma/features/profile/domain/wellness/dosha_question.dart';
import 'package:fitkarma/features/profile/presentation/providers/profile_providers.dart';
import 'package:fitkarma/features/profile/presentation/providers/wellness_providers.dart';
import 'package:fitkarma/features/profile/presentation/screens/dosha_wellness_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testConfig = AppConfig.fromMap({
    'APP_ENV': 'development',
    'SUPABASE_URL': 'https://test.supabase.co',
    'SUPABASE_ANON_KEY': 'test-anon-key',
  });

  Widget buildTestScreen({
    required LocalFirstWellnessRepository wellnessRepo,
    required LocalFirstProfileRepository profileRepo,
  }) {
    return ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(testConfig),
        userProfileRepositoryProvider.overrideWithValue(profileRepo),
        wellnessProfileRepositoryProvider.overrideWithValue(wellnessRepo),
      ],
      child: const MaterialApp(
        home: DoshaWellnessScreen(),
      ),
    );
  }

  group('DoshaWellnessScreen Widget Tests', () {
    void setViewport(WidgetTester tester) {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    testWidgets(
      'Renders questionnaire with non-medical disclaimer and navigation controls',
      (tester) async {
        setViewport(tester);

        final mockSupabase = MockSupabaseService();
        final profileRepo =
            LocalFirstProfileRepository(supabaseService: mockSupabase);
        final wellnessRepo = LocalFirstWellnessRepository(
          supabaseService: mockSupabase,
          profileRepository: profileRepo,
        );

        await tester.pumpWidget(
          buildTestScreen(
            wellnessRepo: wellnessRepo,
            profileRepo: profileRepo,
          ),
        );
        await tester.pumpAndSettle();

        // 1. Verify Screen and Header
        expect(find.byKey(const Key('screen_dosha_wellness')), findsOneWidget);
        expect(find.text('Ayurveda & Prakriti'), findsOneWidget);
        expect(find.text('Question 1 of 7'), findsOneWidget);

        // 2. Verify Mandatory Non-Medical Disclaimer Banner
        expect(
          find.byKey(const Key('banner_wellness_disclaimer')),
          findsOneWidget,
        );
        expect(
          find.textContaining(
            'FitKarma Ayurvedic insights provide traditional lifestyle',
          ),
          findsOneWidget,
        );
        expect(
          find.textContaining('They are NOT clinical diagnoses'),
          findsOneWidget,
        );

        // 3. Verify Question Content & Options
        expect(
          find.text('Physical Frame & Skeletal Build'),
          findsOneWidget,
        );
        expect(find.text('Slender & Light'), findsOneWidget);
        expect(find.text('Medium & Athletic'), findsOneWidget);
        expect(find.text('Broad & Sturdy'), findsOneWidget);

        // 4. Verify Skip action is available
        expect(find.byKey(const Key('btn_skip_wellness_quiz')), findsOneWidget);
      },
    );

    testWidgets(
      'Selecting options advances through questions and completes assessment',
      (tester) async {
        setViewport(tester);

        final mockSupabase = MockSupabaseService();
        final profileRepo =
            LocalFirstProfileRepository(supabaseService: mockSupabase);
        final wellnessRepo = LocalFirstWellnessRepository(
          supabaseService: mockSupabase,
          profileRepository: profileRepo,
        );

        await tester.pumpWidget(
          buildTestScreen(
            wellnessRepo: wellnessRepo,
            profileRepo: profileRepo,
          ),
        );
        await tester.pumpAndSettle();

        // Answer all 7 questions with Pitta options
        final questions = DoshaQuestion.standardQuestions;
        for (int i = 0; i < questions.length; i++) {
          final q = questions[i];
          final pittaOption = q.options.firstWhere(
            (o) => o.dosha == AyurvedicDosha.pitta,
          );

          // Tap option
          await tester.tap(find.byKey(Key('option_${pittaOption.id}')));
          await tester.pumpAndSettle();

          // Tap Next / Complete button
          final nextBtn = find.byKey(const Key('btn_dosha_next'));
          expect(nextBtn, findsOneWidget);
          await tester.tap(nextBtn);
          await tester.pumpAndSettle();
        }

        // Assessment completed -> verify Results Screen is displayed
        expect(find.byKey(const Key('scroll_dosha_results')), findsOneWidget);
        expect(find.text('Pitta (Fire & Water)'), findsNWidgets(2));
        expect(
          find.text('Constitutional Balance Breakdown'),
          findsOneWidget,
        );
        expect(find.text('100%'), findsOneWidget); // 100% Pitta
        expect(find.text('Holistic Lifestyle Guidance'), findsOneWidget);
        expect(find.text('Cooling & Nourishing Foods'), findsOneWidget);

        // Retake button should be present
        expect(find.byKey(const Key('btn_retake_dosha')), findsOneWidget);
      },
    );

    testWidgets(
      'Tapping Skip records skipped status and allows retaking later',
      (tester) async {
        setViewport(tester);

        final mockSupabase = MockSupabaseService();
        final profileRepo =
            LocalFirstProfileRepository(supabaseService: mockSupabase);
        final wellnessRepo = LocalFirstWellnessRepository(
          supabaseService: mockSupabase,
          profileRepository: profileRepo,
        );

        await tester.pumpWidget(
          buildTestScreen(
            wellnessRepo: wellnessRepo,
            profileRepo: profileRepo,
          ),
        );
        await tester.pumpAndSettle();

        // Tap skip
        await tester.tap(find.byKey(const Key('btn_skip_wellness_quiz')));
        await tester.pumpAndSettle();

        // Verify skipped profile was saved in repository
        final saved = await wellnessRepo.getWellnessProfile();
        expect(saved.isSuccess, isTrue);
        expect(saved.dataOrNull?.isSkipped, isTrue);
        expect(saved.dataOrNull?.isCompleted, isFalse);
      },
    );
  });
}
