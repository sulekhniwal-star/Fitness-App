import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../data/models/user_model.dart';
import '../../data/models/food_log_model.dart';
import '../../data/models/workout_model.dart';
import '../../data/models/weight_log_model.dart';
import '../../data/models/medical_record_model.dart';
import '../../data/models/post_model.dart';
import '../../data/models/challenge_model.dart';
import '../../data/models/tracking_point.dart';
import '../../data/models/health_insight_model.dart';

/// Service for managing local storage via Hive.
class HiveService {
  static late Box<UserModel> userBox;
  static late Box<FoodLogModel> foodLogBox;
  static late Box workoutLogBox;
  static late Box stepsBox;
  static late Box foodCacheBox;
  static late Box syncQueueBox;
  static late Box waterBox; // Added auxiliary box mentioned in constants
  static late Box<WeightLogModel>
      weightBox; // Added auxiliary box mentioned in constants
  static late Box settingsBox; // Added auxiliary box mentioned in constants
  static late Box<MedicalRecordModel> medicalBox;
  static late Box<PostModel> postsBox;
  static late Box<ChallengeModel> challengesBox;
  static late Box<HealthInsight> insightsBox;

  /// Initializes required Hive boxes internally.
  static Future<void> initBoxes() async {
    // Register adapters
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(FoodLogModelAdapter());
    Hive.registerAdapter(WorkoutModelAdapter());
    Hive.registerAdapter(WeightLogModelAdapter());
    Hive.registerAdapter(MedicalRecordModelAdapter());
    Hive.registerAdapter(PostModelAdapter());
    Hive.registerAdapter(ChallengeModelAdapter());
    Hive.registerAdapter(TrackingPointAdapter());
    Hive.registerAdapter(InsightTypeAdapter());
    Hive.registerAdapter(InsightCategoryAdapter());
    Hive.registerAdapter(HealthInsightAdapter());

    // Open required core boxes for offline-first capabilities
    userBox = await Hive.openBox<UserModel>(AppConstants.userBox);
    foodLogBox = await Hive.openBox<FoodLogModel>(AppConstants.foodLogBox);
    workoutLogBox = await Hive.openBox(AppConstants.workoutLogBox);
    stepsBox = await Hive.openBox(AppConstants.stepsBox);
    foodCacheBox = await Hive.openBox(AppConstants.foodCacheBox);
    syncQueueBox = await Hive.openBox(AppConstants.syncQueueBox);

    // Auxiliary boxes
    waterBox = await Hive.openBox(AppConstants.waterBox);
    weightBox = await Hive.openBox<WeightLogModel>(AppConstants.weightBox);
    settingsBox = await Hive.openBox(AppConstants.settingsBox);
    medicalBox =
        await Hive.openBox<MedicalRecordModel>(AppConstants.medicalBox);
    postsBox = await Hive.openBox<PostModel>('postsBox');
    challengesBox = await Hive.openBox<ChallengeModel>('challengesBox');
    insightsBox = await Hive.openBox<HealthInsight>(AppConstants.insightsBox);
  }

  /// Clears all stored data (useful for logout).
  static Future<void> clearAll() async {
    await userBox.clear();
    await foodLogBox.clear();
    await workoutLogBox.clear();
    await stepsBox.clear();
    await foodCacheBox.clear();
    await syncQueueBox.clear();
    await waterBox.clear();
    await weightBox.clear();
    await settingsBox.clear();
    await medicalBox.clear();
    await postsBox.clear();
    await challengesBox.clear();
    await insightsBox.clear();
  }

  // Settings operations
  static Future<void> saveSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);
  }

  static T? getSetting<T>(String key, {T? defaultValue}) {
    return settingsBox.get(key, defaultValue: defaultValue) as T?;
  }

  // User operations
  static Future<void> saveUser(UserModel user) async {
    await userBox.put('current_user', user);
  }

  static UserModel? getCurrentUser() {
    return userBox.get('current_user');
  }

  static Future<void> deleteUser() async {
    await userBox.delete('current_user');
  }
}
