import 'package:fitkarma/core/errors/failures.dart';
import 'package:fitkarma/features/profile/domain/models/profile_enums.dart';

/// Validator for UserProfile domain entities and updates.
class UserProfileValidator {
  const UserProfileValidator._();

  static const int minAge = 13;
  static const int maxAge = 120;
  static const double minHeightCm = 50.0;
  static const double maxHeightCm = 250.0;
  static const double minWeightKg = 20.0;
  static const double maxWeightKg = 400.0;
  static const int minDisplayNameLength = 2;
  static const int maxDisplayNameLength = 60;

  /// Validates all individual profile attributes.
  ///
  /// Returns null if valid; returns a [ValidationFailure] with granular
  /// field errors if any rules are violated.
  static ValidationFailure? validate({
    required String displayName,
    required int age,
    required double heightCm,
    required double weightKg,
    required List<FitnessGoal> goals,
    double carbsRatio = 0.50,
    double proteinRatio = 0.25,
    double fatRatio = 0.25,
    int mealsPerDay = 3,
    String locale = 'en',
  }) {
    final fieldErrors = <String, String>{};

    final trimmedName = displayName.trim();
    if (trimmedName.length < minDisplayNameLength ||
        trimmedName.length > maxDisplayNameLength) {
      fieldErrors['displayName'] =
          'Display name must be between $minDisplayNameLength and $maxDisplayNameLength characters';
    }

    if (age < minAge || age > maxAge) {
      fieldErrors['age'] = 'Age must be between $minAge and $maxAge years';
    }

    if (heightCm < minHeightCm || heightCm > maxHeightCm) {
      fieldErrors['heightCm'] =
          'Height must be between $minHeightCm cm and $maxHeightCm cm';
    }

    if (weightKg < minWeightKg || weightKg > maxWeightKg) {
      fieldErrors['weightKg'] =
          'Weight must be between $minWeightKg kg and $maxWeightKg kg';
    }

    if (goals.isEmpty) {
      fieldErrors['goals'] = 'Please select at least one fitness goal';
    }

    final totalMacros = carbsRatio + proteinRatio + fatRatio;
    if (totalMacros < 0.95 || totalMacros > 1.05) {
      fieldErrors['macroRatios'] =
          'Carbohydrate, protein, and fat ratios must sum to 100% (got ${(totalMacros * 100).toStringAsFixed(0)}%)';
    }

    if (mealsPerDay < 1 || mealsPerDay > 10) {
      fieldErrors['mealsPerDay'] = 'Meals per day must be between 1 and 10';
    }

    if (locale.trim().isEmpty) {
      fieldErrors['locale'] = 'Preferred language code cannot be empty';
    }

    if (fieldErrors.isNotEmpty) {
      return ValidationFailure(
        message: 'Please review and correct the invalid profile information',
        fieldErrors: fieldErrors,
      );
    }

    return null;
  }
}
