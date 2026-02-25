import 'dosha_model.dart';

enum MealType { breakfast, lunch, snack, dinner }

class MealRecommendation {
  final String id;
  final String name;
  final String description;
  final MealType type;
  final double calories;
  final double protein;
  final double carbs;
  final double fats;
  final List<String> ingredients;
  final List<DoshaType> suitableFor;
  final String
      regionalOrigin; // e.g., North Indian, South Indian, Maharashtrian

  const MealRecommendation({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.ingredients,
    required this.suitableFor,
    this.regionalOrigin = 'General Indian',
  });
}

class DailyMealPlan {
  final DateTime date;
  final Map<MealType, MealRecommendation> meals;
  final double totalCalories;
  final double totalProtein;
  final double totalCarbs;
  final double totalFats;

  DailyMealPlan({
    required this.date,
    required this.meals,
    required this.totalCalories,
    required this.totalProtein,
    required this.totalCarbs,
    required this.totalFats,
  });
}
