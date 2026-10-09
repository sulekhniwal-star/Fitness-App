import 'package:fitkarma/core/supabase/mock_supabase_service.dart';
import 'package:fitkarma/features/profile/data/repositories/local_first_profile_repository.dart';
import 'package:fitkarma/features/profile/data/repositories/local_first_wellness_repository.dart';
import 'package:fitkarma/features/profile/domain/models/profile_enums.dart';
import 'package:fitkarma/features/profile/domain/models/user_profile.dart';
import 'package:fitkarma/features/profile/domain/wellness/dosha_wellness_service.dart';
import 'package:fitkarma/features/profile/domain/wellness/wellness_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DoshaWellnessService Deterministic Scoring Rules', () {
    const service = DoshaWellnessService();

    test('100% Vata responses calculate pure Vata dominant constitution', () {
      final answers = {
        'body_frame': AyurvedicDosha.vata,
        'skin_tendency': AyurvedicDosha.vata,
        'appetite_digestion': AyurvedicDosha.vata,
        'energy_movement': AyurvedicDosha.vata,
        'sleep_pattern': AyurvedicDosha.vata,
        'stress_response': AyurvedicDosha.vata,
        'climate_affinity': AyurvedicDosha.vata,
      };

      final score = service.calculateScore(answers: answers);

      expect(score.vataPoints, equals(7));
      expect(score.pittaPoints, equals(0));
      expect(score.kaphaPoints, equals(0));
      expect(score.answeredQuestions, equals(7));
      expect(score.vataPercentage, equals(1.0));
      expect(score.pittaPercentage, equals(0.0));
      expect(score.kaphaPercentage, equals(0.0));
      expect(score.dominantDosha, equals(AyurvedicDosha.vata));
      expect(score.secondaryDosha, isNull);
      expect(score.isTridoshic, isFalse);
      expect(score.isDualDosha, isFalse);
    });

    test('100% Pitta responses calculate pure Pitta dominant constitution', () {
      final answers = {
        'body_frame': AyurvedicDosha.pitta,
        'skin_tendency': AyurvedicDosha.pitta,
        'appetite_digestion': AyurvedicDosha.pitta,
        'energy_movement': AyurvedicDosha.pitta,
        'sleep_pattern': AyurvedicDosha.pitta,
        'stress_response': AyurvedicDosha.pitta,
        'climate_affinity': AyurvedicDosha.pitta,
      };

      final score = service.calculateScore(answers: answers);

      expect(score.pittaPoints, equals(7));
      expect(score.pittaPercentage, equals(1.0));
      expect(score.dominantDosha, equals(AyurvedicDosha.pitta));
      expect(score.secondaryDosha, isNull);
      expect(score.isTridoshic, isFalse);
      expect(score.isDualDosha, isFalse);
    });

    test('100% Kapha responses calculate pure Kapha dominant constitution', () {
      final answers = {
        'body_frame': AyurvedicDosha.kapha,
        'skin_tendency': AyurvedicDosha.kapha,
        'appetite_digestion': AyurvedicDosha.kapha,
        'energy_movement': AyurvedicDosha.kapha,
        'sleep_pattern': AyurvedicDosha.kapha,
        'stress_response': AyurvedicDosha.kapha,
        'climate_affinity': AyurvedicDosha.kapha,
      };

      final score = service.calculateScore(answers: answers);

      expect(score.kaphaPoints, equals(7));
      expect(score.kaphaPercentage, equals(1.0));
      expect(score.dominantDosha, equals(AyurvedicDosha.kapha));
      expect(score.secondaryDosha, isNull);
      expect(score.isTridoshic, isFalse);
      expect(score.isDualDosha, isFalse);
    });

    test(
        'Balanced responses within 15% spread calculate Tridoshic equilibrium',
        () {
      // 3 Vata, 2 Pitta, 2 Kapha -> Vata: 42.8%, Pitta: 28.6%, Kapha: 28.6%
      // All within 25% - 40% mid-range or <= 15% difference
      final answers = {
        'q1': AyurvedicDosha.vata,
        'q2': AyurvedicDosha.vata,
        'q3': AyurvedicDosha.vata,
        'q4': AyurvedicDosha.pitta,
        'q5': AyurvedicDosha.pitta,
        'q6': AyurvedicDosha.kapha,
        'q7': AyurvedicDosha.kapha,
      };

      final score = service.calculateScore(answers: answers, totalQuestions: 7);

      expect(score.vataPoints, equals(3));
      expect(score.pittaPoints, equals(2));
      expect(score.kaphaPoints, equals(2));
      expect(score.isTridoshic, isTrue);
      expect(score.dominantDosha, equals(AyurvedicDosha.tridoshic));
      expect(score.secondaryDosha, isNull);
      expect(score.isDualDosha, isFalse);
    });

    test(
        'Dual-Dosha constitution identified when top two are within 15% and third is low',
        () {
      // 4 Pitta, 3 Kapha, 0 Vata -> Pitta: 57.1%, Kapha: 42.9%, Vata: 0%
      // Difference between top two is 14.2% (<= 15%), but min is 0% (so not tridoshic)
      final answers = {
        'q1': AyurvedicDosha.pitta,
        'q2': AyurvedicDosha.pitta,
        'q3': AyurvedicDosha.pitta,
        'q4': AyurvedicDosha.pitta,
        'q5': AyurvedicDosha.kapha,
        'q6': AyurvedicDosha.kapha,
        'q7': AyurvedicDosha.kapha,
      };

      final score = service.calculateScore(answers: answers);

      expect(score.pittaPoints, equals(4));
      expect(score.kaphaPoints, equals(3));
      expect(score.vataPoints, equals(0));
      expect(score.isTridoshic, isFalse);
      expect(score.isDualDosha, isTrue);
      expect(score.dominantDosha, equals(AyurvedicDosha.pitta));
      expect(score.secondaryDosha, equals(AyurvedicDosha.kapha));
    });

    test('Single dominant constitution when top score exceeds runner-up by > 15%',
        () {
      // 5 Vata, 1 Pitta, 1 Kapha -> Vata: 71.4%, Pitta: 14.3%, Kapha: 14.3%
      final answers = {
        'q1': AyurvedicDosha.vata,
        'q2': AyurvedicDosha.vata,
        'q3': AyurvedicDosha.vata,
        'q4': AyurvedicDosha.vata,
        'q5': AyurvedicDosha.vata,
        'q6': AyurvedicDosha.pitta,
        'q7': AyurvedicDosha.kapha,
      };

      final score = service.calculateScore(answers: answers);

      expect(score.dominantDosha, equals(AyurvedicDosha.vata));
      expect(score.secondaryDosha, isNull);
      expect(score.isDualDosha, isFalse);
      expect(score.isTridoshic, isFalse);
    });

    test('Deterministic tie-breaking prioritizes classical Ayurvedic order (Vata -> Pitta -> Kapha)',
        () {
      // Exact tie: 3 Vata, 3 Pitta, 0 Kapha -> both 50%
      final answers = {
        'q1': AyurvedicDosha.vata,
        'q2': AyurvedicDosha.vata,
        'q3': AyurvedicDosha.vata,
        'q4': AyurvedicDosha.pitta,
        'q5': AyurvedicDosha.pitta,
        'q6': AyurvedicDosha.pitta,
      };

      final score = service.calculateScore(answers: answers);

      expect(score.dominantDosha, equals(AyurvedicDosha.vata));
      expect(score.secondaryDosha, equals(AyurvedicDosha.pitta));
      expect(score.isDualDosha, isTrue);
    });

    test('Partial/incomplete answers handled gracefully', () {
      final answers = {
        'q1': AyurvedicDosha.vata,
        'q2': AyurvedicDosha.vata,
      };

      final score = service.calculateScore(answers: answers, totalQuestions: 7);

      expect(score.answeredQuestions, equals(2));
      expect(score.totalQuestions, equals(7));
      expect(score.vataPercentage, equals(1.0));
      expect(score.dominantDosha, equals(AyurvedicDosha.vata));
    });

    test('Empty responses return empty unassessed score state', () {
      final score = service.calculateScore(answers: const {});

      expect(score.answeredQuestions, equals(0));
      expect(score.dominantDosha, equals(AyurvedicDosha.unknown));
      expect(score.secondaryDosha, isNull);
      expect(score.isTridoshic, isFalse);
      expect(score.isDualDosha, isFalse);
    });
  });

  group('Non-Medical Safeguards & Disclaimer Enforcement', () {
    const service = DoshaWellnessService();

    test('All calculated profiles include explicit non-medical disclaimer', () {
      final profile = service.buildProfile(
        userId: 'user_123',
        rawAnswers: {
          'body_frame': 'body_frame_vata',
          'skin_tendency': 'skin_vata',
        },
      );

      expect(
        WellnessProfile.nonMedicalDisclaimer,
        contains('NOT clinical diagnoses, medical treatments'),
      );
      expect(
        profile.toJson()['disclaimer'],
        contains('NOT clinical diagnoses, medical treatments'),
      );
    });

    test(
        'Generated recommendations are marked strictly as non-medical lifestyle guidance',
        () {
      final recs = service.generateRecommendations(
        dominantDosha: AyurvedicDosha.pitta,
      );

      expect(recs, isNotEmpty);
      for (final rec in recs) {
        expect(rec.isMedicalClaim, isFalse);
        expect(rec.title, isNotEmpty);
        expect(rec.description, isNotEmpty);
      }
    });

    test(
        'Traditional wellness layer is strictly decoupled from evidence-based health measurements',
        () {
      // Create baseline clinical profile
      final baselineProfile = UserProfile(
        id: 'prof_1',
        userId: 'user_1',
        displayName: 'Aarav Patel',
        age: 30,
        biologicalSex: BiologicalSex.male,
        heightCm: 175.0,
        weightKg: 70.0,
        goals: const [FitnessGoal.maintenance],
        activityLevel: ActivityLevel.moderatelyActive,
        dietaryIdentity: DietaryIdentity.vegetarian,
        dosha: null, // initially null
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final baselineBmr = baselineProfile.calculateBmr();
      final baselineTdee = baselineProfile.calculateTdee();
      final baselineBmi = baselineProfile.bmi;
      final baselineTargetCalories =
          baselineProfile.calculateRecommendedCalories();

      // Verify for every dosha state (vata, pitta, kapha, tridoshic, unknown)
      for (final dosha in AyurvedicDosha.values) {
        final profileWithDosha = baselineProfile.copyWith(dosha: dosha);

        // Clinical equations MUST remain 100% mathematically identical
        expect(
          profileWithDosha.calculateBmr(),
          equals(baselineBmr),
          reason: 'BMR must not be influenced by Dosha $dosha',
        );
        expect(
          profileWithDosha.calculateTdee(),
          equals(baselineTdee),
          reason: 'TDEE must not be influenced by Dosha $dosha',
        );
        expect(
          profileWithDosha.bmi,
          equals(baselineBmi),
          reason: 'BMI must not be influenced by Dosha $dosha',
        );
        expect(
          profileWithDosha.calculateRecommendedCalories(),
          equals(baselineTargetCalories),
          reason: 'Calorie targets must not be influenced by Dosha $dosha',
        );
      }
    });
  });

  group('Wellness Profile Repository, Skip, and Revisitability', () {
    late LocalFirstProfileRepository profileRepository;
    late LocalFirstWellnessRepository wellnessRepository;

    setUp(() {
      final mockSupabase = MockSupabaseService();
      profileRepository =
          LocalFirstProfileRepository(supabaseService: mockSupabase);
      wellnessRepository = LocalFirstWellnessRepository(
        supabaseService: mockSupabase,
        profileRepository: profileRepository,
      );
    });

    test('User can skip assessment and profile is recorded as skipped', () async {
      final skipResult =
          await wellnessRepository.skipWellnessProfile(userId: 'user_test');

      expect(skipResult.isSuccess, isTrue);

      final fetchedResult =
          await wellnessRepository.getWellnessProfile(userId: 'user_test');
      expect(fetchedResult.isSuccess, isTrue);

      final profile = fetchedResult.dataOrNull;
      expect(profile, isNotNull);
      expect(profile!.isSkipped, isTrue);
      expect(profile.isCompleted, isFalse);
      expect(profile.dominantDosha, equals(AyurvedicDosha.unknown));
    });

    test(
        'User can revisit and complete assessment after previously skipping',
        () async {
      // 1. Skip initially
      await wellnessRepository.skipWellnessProfile(userId: 'user_test');

      // 2. Revisit and take assessment
      const service = DoshaWellnessService();
      final calculated = service.buildProfile(
        userId: 'user_test',
        rawAnswers: {
          'body_frame': 'body_frame_kapha',
          'skin_tendency': 'skin_kapha',
          'appetite_digestion': 'appetite_kapha',
          'energy_movement': 'energy_kapha',
          'sleep_pattern': 'sleep_kapha',
          'stress_response': 'stress_kapha',
          'climate_affinity': 'climate_kapha',
        },
      );

      final saveResult =
          await wellnessRepository.saveWellnessProfile(calculated);
      expect(saveResult.isSuccess, isTrue);

      // 3. Verify state is now completed with Kapha dominance
      final revisitedResult =
          await wellnessRepository.getWellnessProfile(userId: 'user_test');
      expect(revisitedResult.isSuccess, isTrue);

      final updated = revisitedResult.dataOrNull;
      expect(updated, isNotNull);
      expect(updated!.isSkipped, isFalse);
      expect(updated.isCompleted, isTrue);
      expect(updated.dominantDosha, equals(AyurvedicDosha.kapha));
    });

    test('User can reset/retake assessment clearing existing profile', () async {
      const service = DoshaWellnessService();
      final calculated = service.buildProfile(
        userId: 'user_test',
        rawAnswers: {'body_frame': 'body_frame_pitta'},
      );
      await wellnessRepository.saveWellnessProfile(calculated);

      // Reset
      final resetResult =
          await wellnessRepository.resetWellnessProfile(userId: 'user_test');
      expect(resetResult.isSuccess, isTrue);

      final result =
          await wellnessRepository.getWellnessProfile(userId: 'user_test');
      expect(result.dataOrNull, isNull);
    });

    test('Serialization roundtrip preserves all fields without data loss', () {
      const service = DoshaWellnessService();
      final original = service.buildProfile(
        userId: 'user_123',
        rawAnswers: {
          'body_frame': 'body_frame_vata',
          'skin_tendency': 'skin_pitta',
        },
      );

      final json = original.toJson();
      final restored = WellnessProfile.fromJson(json);

      expect(restored.userId, equals(original.userId));
      expect(restored.dominantDosha, equals(original.dominantDosha));
      expect(restored.secondaryDosha, equals(original.secondaryDosha));
      expect(restored.score.vataPoints, equals(original.score.vataPoints));
      expect(restored.score.pittaPoints, equals(original.score.pittaPoints));
      expect(restored.isCompleted, equals(original.isCompleted));
      expect(restored.isSkipped, equals(original.isSkipped));
      expect(restored.recommendations.length, equals(original.recommendations.length));
    });
  });
}
