import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/meal_recommendation_model.dart';
import '../models/dosha_model.dart';
import '../repositories/meal_repository.dart';
import 'auth_provider.dart';
import 'festival_provider.dart';

class MealState {
  final DailyMealPlan? currentPlan;
  final bool isLoading;
  final String? error;

  MealState({this.currentPlan, this.isLoading = false, this.error});

  MealState copyWith(
      {DailyMealPlan? currentPlan, bool? isLoading, String? error}) {
    return MealState(
      currentPlan: currentPlan ?? this.currentPlan,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class MealNotifier extends StateNotifier<MealState> {
  final Ref _ref;

  MealNotifier(this._ref) : super(MealState());

  void generatePlan() {
    state = state.copyWith(isLoading: true);

    final user = _ref.read(authStateProvider).user;
    if (user == null) {
      state = state.copyWith(isLoading: false, error: 'User not logged in');
      return;
    }

    try {
      // Determine Dosha
      DoshaType userDosha = DoshaType.vata; // Default
      if (user.dosha != null) {
        userDosha = DoshaType.values.firstWhere(
          (e) => e.name == user.dosha,
          orElse: () => DoshaType.vata,
        );
      }

      // Determine Target Calories (Rough estimate for MVP)
      double target = 2000.0;
      if (user.weightKg != null && user.heightCm != null) {
        // Simple BMR approx: (10 * weight) + (6.25 * height) - (5 * age)
        // Using average age 25 for now
        target =
            (10 * user.weightKg!) + (6.25 * user.heightCm!) - (5 * 25) + 500;
      }

      // Apply Festival Fasting Mode Modifiers
      target =
          _ref.read(festivalProvider.notifier).getAdjustedCalorieGoal(target);

      final plan = MealRepository.generatePlan(
        dosha: userDosha,
        targetCalories: target,
        goal: 'maintenance',
      );

      state = state.copyWith(currentPlan: plan, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final mealProvider = StateNotifierProvider<MealNotifier, MealState>((ref) {
  return MealNotifier(ref);
});
