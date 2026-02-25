import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/workout_repository.dart';
import '../models/workout_model.dart';

final workoutRepositoryProvider = Provider<WorkoutRepository>((ref) {
  return WorkoutRepository();
});

class WorkoutNotifier extends StateNotifier<List<WorkoutModel>> {
  final Ref _ref;

  WorkoutNotifier(this._ref) : super([]) {
    // Initial load: Fetch all automatically on init
    loadWorkouts('All');
  }

  void loadWorkouts(String category) {
    final repo = _ref.read(workoutRepositoryProvider);
    state = repo.getWorkoutsByCategory(category);
  }
}

final workoutProvider =
    StateNotifierProvider<WorkoutNotifier, List<WorkoutModel>>((ref) {
  return WorkoutNotifier(ref);
});

final currentWorkoutCategoryProvider = StateProvider<String>((ref) => 'All');
