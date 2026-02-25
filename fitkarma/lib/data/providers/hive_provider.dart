import 'package:hive_flutter/hive_flutter.dart';

import '../models/user_model.dart';
import '../models/food_log_model.dart';
import '../../core/constants/app_constants.dart';

/// Provider for managing Hive boxes
class HiveProvider {
  static late Box<UserModel> userBox;
  static late Box<FoodLogModel> foodLogBox;
  static late Box workoutLogBox;
  static late Box stepsBox;
  static late Box waterBox;
  static late Box weightBox;
  static late Box foodCacheBox;
  static late Box syncQueueBox;
  static late Box settingsBox;

  static Future<void> initializeBoxes() async {
    // Register adapters
    Hive.registerAdapter(UserModelAdapter());
    Hive.registerAdapter(FoodLogModelAdapter());

    // Open boxes
    userBox = await Hive.openBox<UserModel>(AppConstants.userBox);
    foodLogBox = await Hive.openBox<FoodLogModel>(AppConstants.foodLogBox);
    workoutLogBox = await Hive.openBox(AppConstants.workoutLogBox);
    stepsBox = await Hive.openBox(AppConstants.stepsBox);
    waterBox = await Hive.openBox(AppConstants.waterBox);
    weightBox = await Hive.openBox(AppConstants.weightBox);
    foodCacheBox = await Hive.openBox(AppConstants.foodCacheBox);
    syncQueueBox = await Hive.openBox(AppConstants.syncQueueBox);
    settingsBox = await Hive.openBox(AppConstants.settingsBox);
  }

  static Future<void> clearAllBoxes() async {
    await userBox.clear();
    await foodLogBox.clear();
    await workoutLogBox.clear();
    await stepsBox.clear();
    await waterBox.clear();
    await weightBox.clear();
    await foodCacheBox.clear();
    await syncQueueBox.clear();
    await settingsBox.clear();
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

  // Food log operations
  static Future<void> addFoodLog(FoodLogModel log) async {
    await foodLogBox.put(log.id, log);
  }

  static List<FoodLogModel> getFoodLogsForDate(DateTime date) {
    return foodLogBox.values.where((log) {
      return log.date.year == date.year &&
          log.date.month == date.month &&
          log.date.day == date.day;
    }).toList();
  }

  static List<FoodLogModel> getUnsyncedFoodLogs() {
    return foodLogBox.values.where((log) => !log.isSynced).toList();
  }

  static Future<void> markFoodLogSynced(String id) async {
    final log = foodLogBox.get(id);
    if (log != null) {
      await foodLogBox.put(
        id,
        log.copyWith(isSynced: true),
      );
    }
  }

  // Settings operations
  static Future<void> saveSetting(String key, dynamic value) async {
    await settingsBox.put(key, value);
  }

  static T? getSetting<T>(String key, {T? defaultValue}) {
    return settingsBox.get(key, defaultValue: defaultValue) as T?;
  }
}
