import 'package:flutter_test/flutter_test.dart';
import 'package:fitkarma/core/constants/app_constants.dart';

void main() {
  group('AppConstants', () {
    test('should have correct app info', () {
      expect(AppConstants.appName, 'FitKarma');
      expect(AppConstants.appVersion, '1.0.0');
      expect(AppConstants.appTagline, contains('India'));
    });

    test('should have correct PocketBase URL', () {
      expect(AppConstants.pocketBaseUrl, 'http://127.0.0.1:8090');
    });

    test('should have correct Hive box names', () {
      expect(AppConstants.userBox, 'userBox');
      expect(AppConstants.foodLogBox, 'foodLogBox');
      expect(AppConstants.workoutLogBox, 'workoutLogBox');
      expect(AppConstants.stepsBox, 'stepsBox');
      expect(AppConstants.waterBox, 'waterBox');
      expect(AppConstants.syncQueueBox, 'syncQueueBox');
    });

    test('should have default goals', () {
      expect(AppConstants.defaultStepGoal, 8000);
      expect(AppConstants.defaultWaterGoalML, 2500);
      expect(AppConstants.defaultCalorieGoal, 2000);
    });

    test('should have karma point values', () {
      expect(AppConstants.karmaDailyLogin, 5);
      expect(AppConstants.karmaStepGoal, 10);
      expect(AppConstants.karmaMealLogged, 3);
      expect(AppConstants.karmaWorkoutComplete, 15);
      expect(AppConstants.karmaStreak7Days, 50);
    });

    test('should have subscription prices', () {
      expect(AppConstants.monthlyPrice, 99.0);
      expect(AppConstants.quarterlyPrice, 249.0);
      expect(AppConstants.yearlyPrice, 799.0);
      expect(AppConstants.familyPrice, 1299.0);
    });

    test('should have food API config', () {
      expect(AppConstants.openFoodFactsBaseUrl, contains('openfoodfacts.org'));
      expect(AppConstants.foodCacheSize, 500);
    });

    test('should have animation durations', () {
      expect(AppConstants.shortAnimation.inMilliseconds, 200);
      expect(AppConstants.mediumAnimation.inMilliseconds, 350);
      expect(AppConstants.longAnimation.inMilliseconds, 500);
    });

    test('should have UI constants', () {
      expect(AppConstants.borderRadius, 12.0);
      expect(AppConstants.cardBorderRadius, 16.0);
      expect(AppConstants.buttonBorderRadius, 8.0);
      expect(AppConstants.paddingSmall, 8.0);
      expect(AppConstants.paddingMedium, 16.0);
      expect(AppConstants.paddingLarge, 24.0);
    });
  });
}
