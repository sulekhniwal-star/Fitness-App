/// Biological sex where required by clinical and metabolic calculations
/// (such as BMR / TDEE formulas per Mifflin-St Jeor).
enum BiologicalSex {
  male,
  female,
  other,
  preferNotToSay;

  /// BMR offset constant in the Mifflin-St Jeor formula:
  /// Male: +5 kcal, Female: -161 kcal, Other: -78 kcal (midpoint).
  double get bmrOffset => switch (this) {
    BiologicalSex.male => 5.0,
    BiologicalSex.female => -161.0,
    _ => -78.0,
  };
}

/// Physical activity level used for Total Daily Energy Expenditure (TDEE).
enum ActivityLevel {
  sedentary,
  lightlyActive,
  moderatelyActive,
  veryActive,
  extremelyActive;

  /// Physical Activity Level (PAL) multiplier applied to Basal Metabolic Rate (BMR).
  double get physicalActivityMultiplier => switch (this) {
    ActivityLevel.sedentary => 1.20,
    ActivityLevel.lightlyActive => 1.375,
    ActivityLevel.moderatelyActive => 1.55,
    ActivityLevel.veryActive => 1.725,
    ActivityLevel.extremelyActive => 1.90,
  };
}

/// Primary fitness and health goals.
enum FitnessGoal {
  weightLoss,
  maintenance,
  muscleGain,
  metabolicHealth,
  fasting,
  improveEndurance,
  stressReduction;

  /// Daily calorie delta recommended relative to maintenance TDEE.
  int get recommendedCalorieDelta => switch (this) {
    FitnessGoal.weightLoss => -500,
    FitnessGoal.muscleGain => 300,
    FitnessGoal.maintenance => 0,
    FitnessGoal.metabolicHealth => -250,
    FitnessGoal.fasting => -350,
    FitnessGoal.improveEndurance => 150,
    FitnessGoal.stressReduction => 0,
  };
}

/// India-first dietary identity taxonomy.
///
/// Vital for respecting Indian food traditions, Ayurveda, and filtering recipes
/// (e.g. Pure Vegetarian with no onion/garlic, Jain, Eggetarian).
enum DietaryIdentity {
  pureVeg,
  jain,
  vegetarian,
  eggetarian,
  vegan,
  nonVegetarian,
  pescatarian;

  /// Human-readable display label.
  String get displayName => switch (this) {
    DietaryIdentity.pureVeg => 'Pure Vegetarian (No Onion/Garlic)',
    DietaryIdentity.jain => 'Jain Vegetarian',
    DietaryIdentity.vegetarian => 'Vegetarian (Lacto-Vegetarian)',
    DietaryIdentity.eggetarian => 'Eggetarian',
    DietaryIdentity.vegan => 'Vegan (Plant-Based)',
    DietaryIdentity.nonVegetarian => 'Non-Vegetarian',
    DietaryIdentity.pescatarian => 'Pescatarian',
  };

  /// Whether the diet strictly prohibits eggs.
  bool get excludesEggs => switch (this) {
    DietaryIdentity.pureVeg ||
    DietaryIdentity.jain ||
    DietaryIdentity.vegetarian ||
    DietaryIdentity.vegan => true,
    _ => false,
  };

  /// Whether the diet strictly prohibits meat and poultry.
  bool get excludesMeat => this != DietaryIdentity.nonVegetarian;
}
