import 'package:fitkarma/core/errors/failures.dart';
import 'package:fitkarma/core/observability/redaction.dart';
import 'package:fitkarma/features/profile/domain/models/notification_preferences.dart';
import 'package:fitkarma/features/profile/domain/models/nutrition_preferences.dart';
import 'package:fitkarma/features/profile/domain/models/profile_enums.dart';
import 'package:fitkarma/features/profile/domain/validation/user_profile_validator.dart';

/// Central domain entity representing a FitKarma user profile,
/// metabolic baselines, goals, dietary traditions, and preferences.
class UserProfile {
  final String id;
  final String userId;
  final String displayName;
  final int age;
  final BiologicalSex biologicalSex;
  final double heightCm;
  final double weightKg;
  final List<FitnessGoal> goals;
  final ActivityLevel activityLevel;
  final DietaryIdentity dietaryIdentity;
  final AyurvedicDosha? dosha;
  final NutritionPreferences nutritionPreferences;
  final NotificationPreferences notificationPreferences;
  final String locale;
  final bool isSynced;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.age,
    required this.biologicalSex,
    required this.heightCm,
    required this.weightKg,
    required this.goals,
    this.activityLevel = ActivityLevel.moderatelyActive,
    this.dietaryIdentity = DietaryIdentity.vegetarian,
    this.dosha,
    this.nutritionPreferences = NutritionPreferences.defaults,
    this.notificationPreferences = NotificationPreferences.defaults,
    this.locale = 'en',
    this.isSynced = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Body Mass Index (BMI = kg / m²).
  double get bmi {
    if (heightCm <= 0) return 0.0;
    final heightM = heightCm / 100.0;
    return weightKg / (heightM * heightM);
  }

  /// Basal Metabolic Rate (BMR) via the clinically validated Mifflin-St Jeor formula:
  /// BMR = (10 × weight in kg) + (6.25 × height in cm) - (5 × age) + sexOffset
  double calculateBmr() {
    return (10.0 * weightKg) +
        (6.25 * heightCm) -
        (5.0 * age) +
        biologicalSex.bmrOffset;
  }

  /// Total Daily Energy Expenditure (TDEE = BMR × Physical Activity Level).
  double calculateTdee() {
    return calculateBmr() * activityLevel.physicalActivityMultiplier;
  }

  /// Recommended daily calorie target adjusted for primary goal and clamped safely.
  int calculateRecommendedCalories() {
    final tdee = calculateTdee();
    final primaryGoal = goals.isNotEmpty
        ? goals.first
        : FitnessGoal.maintenance;
    final target = (tdee + primaryGoal.recommendedCalorieDelta).round();
    // Safety clamp ensuring metabolic baseline adequacy (min 1200 kcal)
    return target < 1200 ? 1200 : target;
  }

  /// Validates profile invariants according to [UserProfileValidator].
  ValidationFailure? validate() {
    return UserProfileValidator.validate(
      displayName: displayName,
      age: age,
      heightCm: heightCm,
      weightKg: weightKg,
      goals: goals,
      carbsRatio: nutritionPreferences.targetCarbsRatio,
      proteinRatio: nutritionPreferences.targetProteinRatio,
      fatRatio: nutritionPreferences.targetFatRatio,
      mealsPerDay: nutritionPreferences.mealsPerDay,
      locale: locale,
    );
  }

  UserProfile copyWith({
    String? id,
    String? userId,
    String? displayName,
    int? age,
    BiologicalSex? biologicalSex,
    double? heightCm,
    double? weightKg,
    List<FitnessGoal>? goals,
    ActivityLevel? activityLevel,
    DietaryIdentity? dietaryIdentity,
    AyurvedicDosha? dosha,
    NutritionPreferences? nutritionPreferences,
    NotificationPreferences? notificationPreferences,
    String? locale,
    bool? isSynced,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      age: age ?? this.age,
      biologicalSex: biologicalSex ?? this.biologicalSex,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      goals: goals ?? this.goals,
      activityLevel: activityLevel ?? this.activityLevel,
      dietaryIdentity: dietaryIdentity ?? this.dietaryIdentity,
      dosha: dosha ?? this.dosha,
      nutritionPreferences: nutritionPreferences ?? this.nutritionPreferences,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
      locale: locale ?? this.locale,
      isSynced: isSynced ?? this.isSynced,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Serializes into JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'display_name': displayName,
      'age': age,
      'biological_sex': biologicalSex.name,
      'height_cm': heightCm,
      'weight_kg': weightKg,
      'goals': goals.map((g) => g.name).toList(),
      'activity_level': activityLevel.name,
      'dietary_identity': dietaryIdentity.name,
      if (dosha != null) 'dosha': dosha!.name,
      'nutrition_preferences': nutritionPreferences.toJson(),
      'notification_preferences': notificationPreferences.toJson(),
      'locale': locale,
      'is_synced': isSynced,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Deserializes from JSON.
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      displayName: json['display_name'] as String? ?? '',
      age: json['age'] as int? ?? 25,
      biologicalSex: BiologicalSex.values.firstWhere(
        (e) => e.name == json['biological_sex'],
        orElse: () => BiologicalSex.other,
      ),
      heightCm: (json['height_cm'] as num?)?.toDouble() ?? 170.0,
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 70.0,
      goals: (json['goals'] as List<dynamic>?)
              ?.map(
                (e) => FitnessGoal.values.firstWhere(
                  (g) => g.name == e,
                  orElse: () => FitnessGoal.maintenance,
                ),
              )
              .toList() ??
          const [FitnessGoal.maintenance],
      activityLevel: ActivityLevel.values.firstWhere(
        (e) => e.name == json['activity_level'],
        orElse: () => ActivityLevel.moderatelyActive,
      ),
      dietaryIdentity: DietaryIdentity.values.firstWhere(
        (e) => e.name == json['dietary_identity'],
        orElse: () => DietaryIdentity.vegetarian,
      ),
      dosha: json['dosha'] != null
          ? AyurvedicDosha.values.firstWhere(
              (e) => e.name == json['dosha'],
              orElse: () => AyurvedicDosha.unknown,
            )
          : null,
      nutritionPreferences: json['nutrition_preferences'] != null
          ? NutritionPreferences.fromJson(
              json['nutrition_preferences'] as Map<String, dynamic>,
            )
          : NutritionPreferences.defaults,
      notificationPreferences: json['notification_preferences'] != null
          ? NotificationPreferences.fromJson(
              json['notification_preferences'] as Map<String, dynamic>,
            )
          : NotificationPreferences.defaults,
      locale: json['locale'] as String? ?? 'en',
      isSynced: json['is_synced'] as bool? ?? true,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  /// Maps to physical Supabase `public.profiles` row storing domain attributes
  /// within the documented metadata JSONB column.
  Map<String, dynamic> toDatabaseRow() {
    return {
      'id': id,
      'user_id': userId,
      'display_name': displayName,
      'locale': locale,
      'metadata': {
        'age': age,
        'biological_sex': biologicalSex.name,
        'height_cm': heightCm,
        'weight_kg': weightKg,
        'goals': goals.map((g) => g.name).toList(),
        'activity_level': activityLevel.name,
        'dietary_identity': dietaryIdentity.name,
        if (dosha != null) 'dosha': dosha!.name,
        'nutrition_preferences': nutritionPreferences.toJson(),
        'notification_preferences': notificationPreferences.toJson(),
      },
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Reconstitutes a [UserProfile] from a Supabase `public.profiles` database row.
  factory UserProfile.fromDatabaseRow(
    Map<String, dynamic> row, {
    bool isSynced = true,
  }) {
    final meta = (row['metadata'] as Map<String, dynamic>?) ?? const {};

    return UserProfile(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      displayName: row['display_name'] as String? ?? '',
      locale: row['locale'] as String? ?? 'en',
      age: meta['age'] as int? ?? 25,
      biologicalSex: BiologicalSex.values.firstWhere(
        (e) => e.name == meta['biological_sex'],
        orElse: () => BiologicalSex.other,
      ),
      heightCm: (meta['height_cm'] as num?)?.toDouble() ?? 170.0,
      weightKg: (meta['weight_kg'] as num?)?.toDouble() ?? 70.0,
      goals: (meta['goals'] as List<dynamic>?)
              ?.map(
                (e) => FitnessGoal.values.firstWhere(
                  (g) => g.name == e,
                  orElse: () => FitnessGoal.maintenance,
                ),
              )
              .toList() ??
          const [FitnessGoal.maintenance],
      activityLevel: ActivityLevel.values.firstWhere(
        (e) => e.name == meta['activity_level'],
        orElse: () => ActivityLevel.moderatelyActive,
      ),
      dietaryIdentity: DietaryIdentity.values.firstWhere(
        (e) => e.name == meta['dietary_identity'],
        orElse: () => DietaryIdentity.vegetarian,
      ),
      dosha: meta['dosha'] != null
          ? AyurvedicDosha.values.firstWhere(
              (e) => e.name == meta['dosha'],
              orElse: () => AyurvedicDosha.unknown,
            )
          : null,
      nutritionPreferences: meta['nutrition_preferences'] != null
          ? NutritionPreferences.fromJson(
              meta['nutrition_preferences'] as Map<String, dynamic>,
            )
          : NutritionPreferences.defaults,
      notificationPreferences: meta['notification_preferences'] != null
          ? NotificationPreferences.fromJson(
              meta['notification_preferences'] as Map<String, dynamic>,
            )
          : NotificationPreferences.defaults,
      isSynced: isSynced,
      createdAt: DateTime.tryParse(row['created_at'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(row['updated_at'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  /// Redacted JSON payload safe for application logs, telemetry, and crash reports.
  ///
  /// Sensitive biological indicators (weight, exact age, PII) are replaced with
  /// DPDP-compliant redaction placeholders per Brain/security.md.
  Map<String, dynamic> toRedactedJson() {
    return {
      'id': id,
      'user_id': userId,
      'display_name': DataRedactor.redactedPlaceholder,
      'age': DataRedactor.redactedPlaceholder,
      'biological_sex': biologicalSex.name,
      'height_cm': heightCm,
      'weight_kg': DataRedactor.redactedPlaceholder,
      'goals': goals.map((g) => g.name).toList(),
      'activity_level': activityLevel.name,
      'dietary_identity': dietaryIdentity.name,
      if (dosha != null) 'dosha': dosha!.name,
      'locale': locale,
      'is_synced': isSynced,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          displayName == other.displayName &&
          age == other.age &&
          biologicalSex == other.biologicalSex &&
          heightCm == other.heightCm &&
          weightKg == other.weightKg &&
          activityLevel == other.activityLevel &&
          dietaryIdentity == other.dietaryIdentity &&
          dosha == other.dosha &&
          locale == other.locale &&
          isSynced == other.isSynced;

  @override
  int get hashCode => Object.hash(
    id,
    userId,
    displayName,
    age,
    biologicalSex,
    heightCm,
    weightKg,
    activityLevel,
    dietaryIdentity,
    dosha,
    locale,
    isSynced,
  );
}
