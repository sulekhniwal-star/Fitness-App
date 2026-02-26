/// Application-wide constants for FitKarma
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'FitKarma';
  static const String appVersion = '1.0.0';
  static const String appTagline =
      'India\'s Most Affordable, Culturally-Rich Fitness App';

  // PocketBase Configuration
  static const String pocketBaseUrl =
      'https://api.fitkarma.in'; // TODO: Update with actual URL
  static const Duration apiTimeout = Duration(seconds: 30);

  // Hive Box Names
  static const String userBox = 'userBox';
  static const String foodLogBox = 'foodLogBox';
  static const String workoutLogBox = 'workoutLogBox';
  static const String stepsBox = 'stepsBox';
  static const String waterBox = 'waterBox';
  static const String weightBox = 'weightBox';
  static const String foodCacheBox = 'foodCacheBox';
  static const String syncQueueBox = 'syncQueueBox';
  static const String settingsBox = 'settingsBox';
  static const String medicalBox = 'medicalBox';
  static const String insightsBox = 'insightsBox';
  static const String teamsBox = 'teamsBox';
  static const String challengesBox = 'challengesBox';

  // Sync Configuration
  static const int maxSyncRetries = 3;
  static const Duration syncRetryDelay = Duration(seconds: 5);
  static const Duration backgroundSyncInterval = Duration(minutes: 15);

  // Default Values
  static const int defaultStepGoal = 8000;
  static const int defaultWaterGoalML = 2500;
  static const double defaultCalorieGoal = 2000;

  // Karma Points
  static const int karmaDailyLogin = 5;
  static const int karmaStepGoal = 10;
  static const int karmaMealLogged = 3;
  static const int karmaWorkoutComplete = 15;
  static const int karmaStreak7Days = 50;

  // Subscription Plans
  static const double monthlyPrice = 99.0;
  static const double quarterlyPrice = 249.0;
  static const double yearlyPrice = 799.0;
  static const double familyPrice = 1299.0;

  // Food API
  static const String openFoodFactsBaseUrl =
      'https://world.openfoodfacts.org/api/v2';
  static const int foodCacheSize = 500;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 350);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // UI Constants
  static const double borderRadius = 12.0;
  static const double cardBorderRadius = 16.0;
  static const double buttonBorderRadius = 8.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
}
