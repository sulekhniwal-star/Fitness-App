import '../models/workout_model.dart';
import '../../core/storage/hive_service.dart';

class WorkoutRepository {
  /// Defines our static mapped Indian/Cultural workouts avoiding API loading penalties explicitly
  static final List<WorkoutModel> _staticWorkouts = [
    // Yoga
    WorkoutModel(
      id: 'w_yoga_1',
      title: 'Surya Namaskar for Beginners',
      category: 'Yoga',
      youtubeId: 'v7AYKMP6rOE',
      estimatedCaloriesPerMin: 4.5,
      durationMins: 15,
      imageUrl: 'https://img.youtube.com/vi/v7AYKMP6rOE/0.jpg',
    ),
    WorkoutModel(
      id: 'w_yoga_2',
      title: 'Yoga for Flexibility',
      category: 'Yoga',
      youtubeId: 'B_XEE5sZt10',
      estimatedCaloriesPerMin: 3.5,
      durationMins: 20,
      imageUrl: 'https://img.youtube.com/vi/B_XEE5sZt10/0.jpg',
    ),
    WorkoutModel(
      id: 'w_yoga_3',
      title: 'Power Yoga Workout',
      category: 'Yoga',
      youtubeId: 'L_xrDAtykMI',
      estimatedCaloriesPerMin: 6.0,
      durationMins: 30,
      imageUrl: 'https://img.youtube.com/vi/L_xrDAtykMI/0.jpg',
    ),
    // Bollywood Dance
    WorkoutModel(
      id: 'w_bol_1',
      title: 'Bollywood Dance Cardio',
      category: 'Bollywood',
      youtubeId: 'xS-lZc6cIfM',
      estimatedCaloriesPerMin: 7.5,
      durationMins: 20,
      imageUrl: 'https://img.youtube.com/vi/xS-lZc6cIfM/0.jpg',
    ),
    WorkoutModel(
      id: 'w_bol_2',
      title: 'Bhangra Workout',
      category: 'Bollywood',
      youtubeId: 'dOpxX0JbbL0',
      estimatedCaloriesPerMin: 8.5,
      durationMins: 25,
      imageUrl: 'https://img.youtube.com/vi/dOpxX0JbbL0/0.jpg',
    ),
    WorkoutModel(
      id: 'w_bol_3',
      title: 'Desi Hip Hop Dance Fitness',
      category: 'Bollywood',
      youtubeId: 'u6fN0D9hH8s',
      estimatedCaloriesPerMin: 7.0,
      durationMins: 15,
      imageUrl: 'https://img.youtube.com/vi/u6fN0D9hH8s/0.jpg',
    ),
    // Desi / Bodyweight
    WorkoutModel(
      id: 'w_desi_1',
      title: 'Desi Akhada Workout',
      category: 'Desi',
      youtubeId: 'J4tM3JjP4E4', // Hindu pushups, squats
      estimatedCaloriesPerMin: 9.0,
      durationMins: 15,
      imageUrl: 'https://img.youtube.com/vi/J4tM3JjP4E4/0.jpg',
    ),
    WorkoutModel(
      id: 'w_desi_2',
      title: 'Traditional Dand Baithak',
      category: 'Desi',
      youtubeId: 'b_7hQ0xZ0R0',
      estimatedCaloriesPerMin: 8.0,
      durationMins: 10,
      imageUrl: 'https://img.youtube.com/vi/b_7hQ0xZ0R0/0.jpg',
    ),
    // HIIT
    WorkoutModel(
      id: 'w_hiit_1',
      title: '15 Min Home HIIT',
      category: 'HIIT',
      youtubeId: 'ml6cT4AZDqw',
      estimatedCaloriesPerMin: 10.0,
      durationMins: 15,
      imageUrl: 'https://img.youtube.com/vi/ml6cT4AZDqw/0.jpg',
    ),
    WorkoutModel(
      id: 'w_hiit_2',
      title: 'Fat Burning HIIT',
      category: 'HIIT',
      youtubeId: 'cbKkB3oa6OE',
      estimatedCaloriesPerMin: 11.0,
      durationMins: 20,
      imageUrl: 'https://img.youtube.com/vi/cbKkB3oa6OE/0.jpg',
    ),
    // Indian Sports
    WorkoutModel(
      id: 'w_sports_1',
      title: 'Cricket Fitness Drills',
      category: 'Sports',
      youtubeId: '7B5sSxwH8i0',
      estimatedCaloriesPerMin: 7.0,
      durationMins: 20,
      imageUrl: 'https://img.youtube.com/vi/7B5sSxwH8i0/0.jpg',
    ),
  ];

  /// Initialize and load static models into Hive cache guaranteeing robust data access
  Future<void> prefillCache() async {
    final box = HiveService.workoutLogBox;
    for (var workout in _staticWorkouts) {
      if (!box.containsKey(workout.id)) {
        box.put(workout.id, workout);
      }
    }
  }

  /// Get all workouts
  List<WorkoutModel> getAllWorkouts() {
    return _staticWorkouts;
  }

  /// Get workouts by category
  List<WorkoutModel> getWorkoutsByCategory(String category) {
    if (category.toLowerCase() == 'all') return _staticWorkouts;
    return _staticWorkouts
        .where((w) => w.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  /// Get a specific workout by ID
  WorkoutModel? getWorkoutById(String id) {
    try {
      return _staticWorkouts.firstWhere((w) => w.id == id);
    } catch (e) {
      return null;
    }
  }
}
