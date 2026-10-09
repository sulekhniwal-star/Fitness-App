import 'package:fitkarma/core/errors/failures.dart';
import 'package:fitkarma/core/errors/result.dart';
import 'package:fitkarma/core/observability/redaction.dart';
import 'package:fitkarma/core/supabase/mock_supabase_service.dart';
import 'package:fitkarma/features/profile/data/repositories/local_first_profile_repository.dart';
import 'package:fitkarma/features/profile/domain/models/notification_preferences.dart';
import 'package:fitkarma/features/profile/domain/models/nutrition_preferences.dart';
import 'package:fitkarma/features/profile/domain/models/profile_enums.dart';
import 'package:fitkarma/features/profile/domain/models/user_profile.dart';
import 'package:fitkarma/features/profile/domain/validation/user_profile_validator.dart';
import 'package:fitkarma/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testDateTime = DateTime.utc(2026, 10, 8, 12, 0, 0);

  UserProfile createValidProfile({
    String id = 'profile-123',
    String userId = 'user-abc',
    String displayName = 'Aarav Sharma',
    int age = 28,
    BiologicalSex biologicalSex = BiologicalSex.male,
    double heightCm = 175.0,
    double weightKg = 72.0,
    List<FitnessGoal>? goals,
    ActivityLevel activityLevel = ActivityLevel.moderatelyActive,
    DietaryIdentity dietaryIdentity = DietaryIdentity.vegetarian,
    NutritionPreferences? nutritionPreferences,
    NotificationPreferences? notificationPreferences,
    String locale = 'en',
    bool isSynced = true,
  }) {
    return UserProfile(
      id: id,
      userId: userId,
      displayName: displayName,
      age: age,
      biologicalSex: biologicalSex,
      heightCm: heightCm,
      weightKg: weightKg,
      goals: goals ?? [FitnessGoal.weightLoss, FitnessGoal.metabolicHealth],
      activityLevel: activityLevel,
      dietaryIdentity: dietaryIdentity,
      nutritionPreferences:
          nutritionPreferences ?? const NutritionPreferences(),
      notificationPreferences:
          notificationPreferences ?? const NotificationPreferences(),
      locale: locale,
      isSynced: isSynced,
      createdAt: testDateTime,
      updatedAt: testDateTime,
    );
  }

  group('UserProfileValidator Tests', () {
    test('passes for valid profile arguments', () {
      final failure = UserProfileValidator.validate(
        displayName: 'Priya Patel',
        age: 26,
        heightCm: 162.0,
        weightKg: 58.0,
        goals: [FitnessGoal.maintenance],
        carbsRatio: 0.50,
        proteinRatio: 0.25,
        fatRatio: 0.25,
        mealsPerDay: 3,
        locale: 'hi',
      );

      expect(failure, isNull);
    });

    test('rejects display names shorter than 2 or longer than 60 chars', () {
      final tooShort = UserProfileValidator.validate(
        displayName: 'A',
        age: 25,
        heightCm: 170.0,
        weightKg: 70.0,
        goals: [FitnessGoal.maintenance],
      );
      expect(tooShort, isA<ValidationFailure>());
      expect(tooShort?.fieldErrors?['displayName'], contains('between 2 and 60'));

      final tooLong = UserProfileValidator.validate(
        displayName: 'A' * 61,
        age: 25,
        heightCm: 170.0,
        weightKg: 70.0,
        goals: [FitnessGoal.maintenance],
      );
      expect(tooLong, isA<ValidationFailure>());
      expect(tooLong?.fieldErrors?['displayName'], contains('between 2 and 60'));
    });

    test('enforces physiological age boundaries (13 - 120)', () {
      final tooYoung = UserProfileValidator.validate(
        displayName: 'Young Kid',
        age: 12,
        heightCm: 150.0,
        weightKg: 45.0,
        goals: [FitnessGoal.maintenance],
      );
      expect(tooYoung, isA<ValidationFailure>());
      expect(tooYoung?.fieldErrors?['age'], contains('between 13 and 120'));

      final tooOld = UserProfileValidator.validate(
        displayName: 'Elder',
        age: 121,
        heightCm: 160.0,
        weightKg: 60.0,
        goals: [FitnessGoal.maintenance],
      );
      expect(tooOld, isA<ValidationFailure>());
      expect(tooOld?.fieldErrors?['age'], contains('between 13 and 120'));
    });

    test('enforces height boundaries (50 - 250 cm)', () {
      final tooShort = UserProfileValidator.validate(
        displayName: 'Test',
        age: 25,
        heightCm: 49.0,
        weightKg: 50.0,
        goals: [FitnessGoal.maintenance],
      );
      expect(tooShort, isA<ValidationFailure>());
      expect(tooShort?.fieldErrors?['heightCm'], contains('between 50.0 cm and 250.0 cm'));

      final tooTall = UserProfileValidator.validate(
        displayName: 'Test',
        age: 25,
        heightCm: 251.0,
        weightKg: 90.0,
        goals: [FitnessGoal.maintenance],
      );
      expect(tooTall, isA<ValidationFailure>());
      expect(tooTall?.fieldErrors?['heightCm'], contains('between 50.0 cm and 250.0 cm'));
    });

    test('enforces weight boundaries (20 - 400 kg)', () {
      final tooLight = UserProfileValidator.validate(
        displayName: 'Test',
        age: 25,
        heightCm: 170.0,
        weightKg: 19.5,
        goals: [FitnessGoal.maintenance],
      );
      expect(tooLight, isA<ValidationFailure>());
      expect(tooLight?.fieldErrors?['weightKg'], contains('between 20.0 kg and 400.0 kg'));

      final tooHeavy = UserProfileValidator.validate(
        displayName: 'Test',
        age: 25,
        heightCm: 170.0,
        weightKg: 405.0,
        goals: [FitnessGoal.maintenance],
      );
      expect(tooHeavy, isA<ValidationFailure>());
      expect(tooHeavy?.fieldErrors?['weightKg'], contains('between 20.0 kg and 400.0 kg'));
    });

    test('requires at least one fitness goal', () {
      final emptyGoals = UserProfileValidator.validate(
        displayName: 'Test',
        age: 25,
        heightCm: 170.0,
        weightKg: 70.0,
        goals: [],
      );
      expect(emptyGoals, isA<ValidationFailure>());
      expect(emptyGoals?.fieldErrors?['goals'], contains('at least one fitness goal'));
    });

    test('validates macronutrient distribution summing to approximately 100%', () {
      final invalidMacros = UserProfileValidator.validate(
        displayName: 'Test',
        age: 25,
        heightCm: 170.0,
        weightKg: 70.0,
        goals: [FitnessGoal.maintenance],
        carbsRatio: 0.20,
        proteinRatio: 0.20,
        fatRatio: 0.20, // Sums to 60%
      );
      expect(invalidMacros, isA<ValidationFailure>());
      expect(invalidMacros?.fieldErrors?['macroRatios'], contains('must sum to 100%'));
    });

    test('validates meals per day within reasonable bounds (1 - 10)', () {
      final invalidMeals = UserProfileValidator.validate(
        displayName: 'Test',
        age: 25,
        heightCm: 170.0,
        weightKg: 70.0,
        goals: [FitnessGoal.maintenance],
        mealsPerDay: 0,
      );
      expect(invalidMeals, isA<ValidationFailure>());
      expect(invalidMeals?.fieldErrors?['mealsPerDay'], contains('between 1 and 10'));
    });

    test('validates locale code non-empty', () {
      final emptyLocale = UserProfileValidator.validate(
        displayName: 'Test',
        age: 25,
        heightCm: 170.0,
        weightKg: 70.0,
        goals: [FitnessGoal.maintenance],
        locale: '   ',
      );
      expect(emptyLocale, isA<ValidationFailure>());
      expect(emptyLocale?.fieldErrors?['locale'], contains('cannot be empty'));
    });
  });

  group('Metabolic & Physical Calculation Tests', () {
    test('calculates accurate BMI for standard height and weight', () {
      final profile = createValidProfile(
        heightCm: 175.0,
        weightKg: 72.0,
      );
      // BMI = 72 / (1.75 * 1.75) = 72 / 3.0625 = 23.51
      expect(profile.bmi, closeTo(23.51, 0.05));
    });

    test('calculates BMR using Mifflin-St Jeor equation for male and female', () {
      // Male: (10 * 70) + (6.25 * 170) - (5 * 25) + 5 = 700 + 1062.5 - 125 + 5 = 1642.5
      final maleProfile = createValidProfile(
        biologicalSex: BiologicalSex.male,
        weightKg: 70.0,
        heightCm: 170.0,
        age: 25,
      );
      expect(maleProfile.calculateBmr(), closeTo(1642.5, 0.01));

      // Female: (10 * 60) + (6.25 * 160) - (5 * 30) - 161 = 600 + 1000 - 150 - 161 = 1289.0
      final femaleProfile = createValidProfile(
        biologicalSex: BiologicalSex.female,
        weightKg: 60.0,
        heightCm: 160.0,
        age: 30,
      );
      expect(femaleProfile.calculateBmr(), closeTo(1289.0, 0.01));

      // Other / midpoint: (10 * 65) + (6.25 * 165) - (5 * 28) - 78 = 650 + 1031.25 - 140 - 78 = 1463.25
      final otherProfile = createValidProfile(
        biologicalSex: BiologicalSex.other,
        weightKg: 65.0,
        heightCm: 165.0,
        age: 28,
      );
      expect(otherProfile.calculateBmr(), closeTo(1463.25, 0.01));
    });

    test('calculates TDEE across different activity levels', () {
      final profile = createValidProfile(
        biologicalSex: BiologicalSex.male,
        weightKg: 70.0,
        heightCm: 170.0,
        age: 25, // BMR = 1642.5
      );

      final sedentary = profile.copyWith(activityLevel: ActivityLevel.sedentary);
      expect(sedentary.calculateTdee(), closeTo(1642.5 * 1.20, 0.01));

      final moderate = profile.copyWith(activityLevel: ActivityLevel.moderatelyActive);
      expect(moderate.calculateTdee(), closeTo(1642.5 * 1.55, 0.01));

      final extreme = profile.copyWith(activityLevel: ActivityLevel.extremelyActive);
      expect(extreme.calculateTdee(), closeTo(1642.5 * 1.90, 0.01));
    });

    test('calculates recommended calories with goal delta and minimum clamp', () {
      final profile = createValidProfile(
        biologicalSex: BiologicalSex.male,
        weightKg: 70.0,
        heightCm: 170.0,
        age: 25, // BMR = 1642.5, TDEE at moderate (1.55) = 2545.875
        activityLevel: ActivityLevel.moderatelyActive,
      );

      // Weight Loss: TDEE - 500 = 2046
      final weightLossProfile = profile.copyWith(goals: [FitnessGoal.weightLoss]);
      expect(weightLossProfile.calculateRecommendedCalories(), equals(2046));

      // Muscle Gain: TDEE + 300 = 2846
      final muscleGainProfile = profile.copyWith(goals: [FitnessGoal.muscleGain]);
      expect(muscleGainProfile.calculateRecommendedCalories(), equals(2846));

      // Low calorie clamp safety: target cannot drop below 1200 kcal
      final veryLowCalorie = createValidProfile(
        biologicalSex: BiologicalSex.female,
        weightKg: 35.0,
        heightCm: 120.0,
        age: 65,
        activityLevel: ActivityLevel.sedentary,
        goals: [FitnessGoal.weightLoss],
      );
      expect(veryLowCalorie.calculateRecommendedCalories(), equals(1200));
    });
  });

  group('Dietary Identity Taxonomy & Preferences Tests', () {
    test('dietary identity respects Indian cultural and ethical exclusions', () {
      expect(DietaryIdentity.pureVeg.excludesEggs, isTrue);
      expect(DietaryIdentity.pureVeg.excludesMeat, isTrue);

      expect(DietaryIdentity.jain.excludesEggs, isTrue);
      expect(DietaryIdentity.jain.excludesMeat, isTrue);

      expect(DietaryIdentity.vegetarian.excludesEggs, isTrue);
      expect(DietaryIdentity.vegetarian.excludesMeat, isTrue);

      expect(DietaryIdentity.eggetarian.excludesEggs, isFalse);
      expect(DietaryIdentity.eggetarian.excludesMeat, isTrue);

      expect(DietaryIdentity.vegan.excludesEggs, isTrue);
      expect(DietaryIdentity.vegan.excludesMeat, isTrue);

      expect(DietaryIdentity.nonVegetarian.excludesEggs, isFalse);
      expect(DietaryIdentity.nonVegetarian.excludesMeat, isFalse);

      expect(DietaryIdentity.pescatarian.excludesEggs, isFalse);
      expect(DietaryIdentity.pescatarian.excludesMeat, isTrue);
    });

    test('serializes and deserializes NutritionPreferences accurately', () {
      const prefs = NutritionPreferences(
        targetDailyCalories: 2100,
        targetCarbsRatio: 0.55,
        targetProteinRatio: 0.25,
        targetFatRatio: 0.20,
        allergies: ['peanuts', 'lactose'],
        fastingProtocol: '16:8',
        mealsPerDay: 4,
      );

      final json = prefs.toJson();
      expect(json['target_daily_calories'], equals(2100));
      expect(json['fasting_protocol'], equals('16:8'));
      expect(json['allergies'], equals(['peanuts', 'lactose']));

      final restored = NutritionPreferences.fromJson(json);
      expect(restored.targetDailyCalories, equals(2100));
      expect(restored.targetCarbsRatio, equals(0.55));
      expect(restored.allergies, contains('peanuts'));
      expect(restored.fastingProtocol, equals('16:8'));
      expect(restored.mealsPerDay, equals(4));
    });

    test('serializes and deserializes NotificationPreferences accurately', () {
      const prefs = NotificationPreferences(
        dailyDIPDigest: true,
        mealReminders: false,
        hydrationReminders: true,
        fastingReminders: false,
        workoutReminders: true,
        weeklySummary: true,
      );

      final json = prefs.toJson();
      expect(json['daily_dip_digest'], isTrue);
      expect(json['meal_reminders'], isFalse);

      final restored = NotificationPreferences.fromJson(json);
      expect(restored.dailyDIPDigest, isTrue);
      expect(restored.mealReminders, isFalse);
      expect(restored.hydrationReminders, isTrue);
      expect(restored.fastingReminders, isFalse);
    });
  });

  group('Sensitive Data Handling & Redaction Tests', () {
    test('toRedactedJson masks PII and sensitive physical metrics per DPDP guidelines', () {
      final profile = createValidProfile(
        displayName: 'Vikram Sengupta',
        age: 34,
        weightKg: 85.5,
      );

      final redacted = profile.toRedactedJson();

      // Display name, age, and weight must be redacted
      expect(redacted['display_name'], equals(DataRedactor.redactedPlaceholder));
      expect(redacted['age'], equals(DataRedactor.redactedPlaceholder));
      expect(redacted['weight_kg'], equals(DataRedactor.redactedPlaceholder));

      // Non-sensitive clinical / configuration parameters remain accessible
      expect(redacted['biological_sex'], equals('male'));
      expect(redacted['height_cm'], equals(175.0));
      expect(redacted['goals'], contains('weightLoss'));
      expect(redacted['dietary_identity'], equals('vegetarian'));
      expect(redacted['locale'], equals('en'));
    });
  });

  group('Database Row Mapping Tests', () {
    test('encapsulates rich domain models within public.profiles metadata column', () {
      final profile = createValidProfile();
      final row = profile.toDatabaseRow();

      expect(row['id'], equals('profile-123'));
      expect(row['user_id'], equals('user-abc'));
      expect(row['display_name'], equals('Aarav Sharma'));
      expect(row['locale'], equals('en'));
      expect(row['metadata'], isA<Map<String, dynamic>>());

      final meta = row['metadata'] as Map<String, dynamic>;
      expect(meta['age'], equals(28));
      expect(meta['biological_sex'], equals('male'));
      expect(meta['weight_kg'], equals(72.0));
      expect(meta['activity_level'], equals('moderatelyActive'));
      expect(meta['dietary_identity'], equals('vegetarian'));
    });

    test('reconstitutes full UserProfile domain entity from database row', () {
      final original = createValidProfile();
      final row = original.toDatabaseRow();

      final reconstituted = UserProfile.fromDatabaseRow(row);

      expect(reconstituted.id, equals(original.id));
      expect(reconstituted.userId, equals(original.userId));
      expect(reconstituted.displayName, equals(original.displayName));
      expect(reconstituted.age, equals(original.age));
      expect(reconstituted.biologicalSex, equals(original.biologicalSex));
      expect(reconstituted.heightCm, equals(original.heightCm));
      expect(reconstituted.weightKg, equals(original.weightKg));
      expect(reconstituted.goals, equals(original.goals));
      expect(reconstituted.dietaryIdentity, equals(original.dietaryIdentity));
      expect(reconstituted.activityLevel, equals(original.activityLevel));
      expect(reconstituted.locale, equals(original.locale));
    });
  });

  group('LocalFirstProfileRepository Tests', () {
    late MockSupabaseService mockSupabase;
    late LocalFirstProfileRepository repository;

    setUp(() {
      mockSupabase = MockSupabaseService();
      repository = LocalFirstProfileRepository(
        supabaseService: mockSupabase,
      );
    });

    tearDown(() {
      repository.dispose();
    });

    test('emits local cached profile immediately upon watching', () async {
      final profile = createValidProfile();
      final repoWithCache = LocalFirstProfileRepository(
        supabaseService: mockSupabase,
        initialProfile: profile,
      );

      final initialEmission = await repoWithCache.watchProfile().first;
      expect(initialEmission, equals(profile));
      repoWithCache.dispose();
    });

    test('saves valid profile locally and returns success', () async {
      final profile = createValidProfile();
      final result = await repository.saveProfile(profile);

      expect(result, isA<Success<UserProfile>>());
      final savedProfile = (result as Success<UserProfile>).data;
      expect(savedProfile.id, equals(profile.id));
      expect(savedProfile.displayName, equals(profile.displayName));

      // Repository watch stream reflects updated profile
      final currentStreamValue = await repository.watchProfile().first;
      expect(currentStreamValue?.displayName, equals(profile.displayName));
    });

    test('rejects profile update with validation error before writing to cache', () async {
      final invalidProfile = createValidProfile(age: 5); // Invalid age
      final result = await repository.saveProfile(invalidProfile);

      expect(result, isA<FailureResult<UserProfile>>());
      final failure = (result as FailureResult<UserProfile>).failure;
      expect(failure, isA<ValidationFailure>());

      final getResult = await repository.getProfile();
      expect((getResult as Success<UserProfile?>).data, isNull);
    });

    test('clears local cache completely upon sign-out', () async {
      final profile = createValidProfile();
      await repository.saveProfile(profile);

      await repository.clearLocalCache();

      final getResult = await repository.getProfile();
      expect((getResult as Success<UserProfile?>).data, isNull);
    });
  });

  group('ProfileNotifier & Providers Tests', () {
    test('loads, saves and reacts to profile state updates via Riverpod', () async {
      final mockSupabase = MockSupabaseService();
      final initialProfile = createValidProfile();
      final repository = LocalFirstProfileRepository(
        supabaseService: mockSupabase,
        initialProfile: initialProfile,
      );

      final container = ProviderContainer(
        overrides: [
          userProfileRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(profileNotifierProvider.notifier);
      await notifier.loadProfile();

      final state = container.read(profileNotifierProvider);
      expect(state.value, equals(initialProfile));

      // Update profile
      final updated = initialProfile.copyWith(displayName: 'Rohan Verma');
      final saveResult = await notifier.saveProfile(updated);
      expect(saveResult, isA<Success<UserProfile>>());

      final updatedState = container.read(profileNotifierProvider);
      expect(updatedState.value?.displayName, equals('Rohan Verma'));

      // Sign out / clear cache
      await notifier.clearCache();
      final clearedState = container.read(profileNotifierProvider);
      expect(clearedState.value, isNull);
    });
  });
}
