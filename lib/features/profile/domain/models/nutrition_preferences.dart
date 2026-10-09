/// Nutrition configuration and dietary preferences for a user profile.
class NutritionPreferences {
  final int? targetDailyCalories;
  final double targetCarbsRatio; // Default 0.50 (50%)
  final double targetProteinRatio; // Default 0.25 (25%)
  final double targetFatRatio; // Default 0.25 (25%)
  final List<String> allergies;
  final String? fastingProtocol; // E.g. '16:8', '14:10', 'circadian'
  final int mealsPerDay;

  const NutritionPreferences({
    this.targetDailyCalories,
    this.targetCarbsRatio = 0.50,
    this.targetProteinRatio = 0.25,
    this.targetFatRatio = 0.25,
    this.allergies = const [],
    this.fastingProtocol,
    this.mealsPerDay = 3,
  });

  /// Default baseline preferences for Indian dietary intake.
  static const NutritionPreferences defaults = NutritionPreferences();

  NutritionPreferences copyWith({
    int? targetDailyCalories,
    double? targetCarbsRatio,
    double? targetProteinRatio,
    double? targetFatRatio,
    List<String>? allergies,
    String? fastingProtocol,
    int? mealsPerDay,
  }) {
    return NutritionPreferences(
      targetDailyCalories: targetDailyCalories ?? this.targetDailyCalories,
      targetCarbsRatio: targetCarbsRatio ?? this.targetCarbsRatio,
      targetProteinRatio: targetProteinRatio ?? this.targetProteinRatio,
      targetFatRatio: targetFatRatio ?? this.targetFatRatio,
      allergies: allergies ?? this.allergies,
      fastingProtocol: fastingProtocol ?? this.fastingProtocol,
      mealsPerDay: mealsPerDay ?? this.mealsPerDay,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (targetDailyCalories != null)
        'target_daily_calories': targetDailyCalories,
      'target_carbs_ratio': targetCarbsRatio,
      'target_protein_ratio': targetProteinRatio,
      'target_fat_ratio': targetFatRatio,
      'allergies': allergies,
      if (fastingProtocol != null) 'fasting_protocol': fastingProtocol,
      'meals_per_day': mealsPerDay,
    };
  }

  factory NutritionPreferences.fromJson(Map<String, dynamic> json) {
    return NutritionPreferences(
      targetDailyCalories: json['target_daily_calories'] as int?,
      targetCarbsRatio:
          (json['target_carbs_ratio'] as num?)?.toDouble() ?? 0.50,
      targetProteinRatio:
          (json['target_protein_ratio'] as num?)?.toDouble() ?? 0.25,
      targetFatRatio: (json['target_fat_ratio'] as num?)?.toDouble() ?? 0.25,
      allergies: (json['allergies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      fastingProtocol: json['fasting_protocol'] as String?,
      mealsPerDay: json['meals_per_day'] as int? ?? 3,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutritionPreferences &&
          runtimeType == other.runtimeType &&
          targetDailyCalories == other.targetDailyCalories &&
          targetCarbsRatio == other.targetCarbsRatio &&
          targetProteinRatio == other.targetProteinRatio &&
          targetFatRatio == other.targetFatRatio &&
          fastingProtocol == other.fastingProtocol &&
          mealsPerDay == other.mealsPerDay;

  @override
  int get hashCode => Object.hash(
    targetDailyCalories,
    targetCarbsRatio,
    targetProteinRatio,
    targetFatRatio,
    fastingProtocol,
    mealsPerDay,
  );
}
