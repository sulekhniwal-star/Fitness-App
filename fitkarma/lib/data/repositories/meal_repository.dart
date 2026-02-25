import '../models/meal_recommendation_model.dart';
import '../models/dosha_model.dart';

class MealRepository {
  static const List<MealRecommendation> _allMeals = [
    // Breakfast
    MealRecommendation(
      id: 'br_1',
      name: 'Oats Upma',
      description: 'Savory oats cooked with vegetables and mild spices.',
      type: MealType.breakfast,
      calories: 250,
      protein: 8,
      carbs: 45,
      fats: 6,
      ingredients: ['Oats', 'Carrots', 'Beans', 'Onions', 'Mustard seeds'],
      suitableFor: [DoshaType.kapha, DoshaType.pitta],
    ),
    MealRecommendation(
      id: 'br_2',
      name: 'Poha with Sprouts',
      description: 'Flattened rice with steamed moong sprouts.',
      type: MealType.breakfast,
      calories: 300,
      protein: 12,
      carbs: 55,
      fats: 4,
      ingredients: ['Poha', 'Moong Sprouts', 'Peanuts', 'Lemon'],
      suitableFor: [DoshaType.kapha, DoshaType.pitta, DoshaType.vata],
    ),
    MealRecommendation(
      id: 'br_3',
      name: 'Moong Dal Chilla',
      description: 'Lentil pancakes rich in protein.',
      type: MealType.breakfast,
      calories: 280,
      protein: 15,
      carbs: 40,
      fats: 8,
      ingredients: ['Moong Dal', 'Ginger', 'Chili', 'Paneer stuffing'],
      suitableFor: [DoshaType.vata, DoshaType.pitta],
    ),

    // Lunch
    MealRecommendation(
      id: 'ln_1',
      name: 'Dal Tadka & Brown Rice',
      description: 'Yellow lentils with tempered spices and whole grain rice.',
      type: MealType.lunch,
      calories: 450,
      protein: 18,
      carbs: 70,
      fats: 10,
      ingredients: ['Arhar Dal', 'Brown Rice', 'Garlic', 'Cumin'],
      suitableFor: [DoshaType.vata, DoshaType.pitta, DoshaType.kapha],
    ),
    MealRecommendation(
      id: 'ln_2',
      name: 'Paneer Bhurji & Roti',
      description: 'Scrambled paneer with whole wheat rotis.',
      type: MealType.lunch,
      calories: 500,
      protein: 25,
      carbs: 50,
      fats: 22,
      ingredients: ['Paneer', 'Wheat Flour', 'Tomatoes', 'Capsicum'],
      suitableFor: [DoshaType.vata, DoshaType.pitta],
    ),
    MealRecommendation(
      id: 'ln_3',
      name: 'Bajra Khichdi',
      description: 'Pearl millet and moong dal porridge.',
      type: MealType.lunch,
      calories: 400,
      protein: 12,
      carbs: 65,
      fats: 8,
      ingredients: ['Bajra', 'Moong Dal', 'Ghee', 'Ginger'],
      suitableFor: [DoshaType.kapha, DoshaType.vata],
    ),

    // Snacks
    MealRecommendation(
      id: 'sn_1',
      name: 'Roasted Makhana',
      description: 'Fox nuts roasted with rock salt and pepper.',
      type: MealType.snack,
      calories: 120,
      protein: 3,
      carbs: 22,
      fats: 2,
      ingredients: ['Makhana', 'Black Pepper', 'Olive oil'],
      suitableFor: [DoshaType.kapha, DoshaType.pitta, DoshaType.vata],
    ),
    MealRecommendation(
      id: 'sn_2',
      name: 'Fruit Salad with Chaat Masala',
      description: 'Seasonal fruits with a tangy twist.',
      type: MealType.snack,
      calories: 150,
      protein: 2,
      carbs: 35,
      fats: 0,
      ingredients: ['Apple', 'Papaya', 'Guava', 'Chaat Masala'],
      suitableFor: [DoshaType.pitta, DoshaType.kapha],
    ),

    // Dinner
    MealRecommendation(
      id: 'dn_1',
      name: 'Veg Dalia',
      description: 'Broken wheat cooked with plenty of veggies.',
      type: MealType.dinner,
      calories: 350,
      protein: 10,
      carbs: 60,
      fats: 5,
      ingredients: ['Dalia', 'Green Peas', 'Onion', 'Turmeric'],
      suitableFor: [DoshaType.kapha, DoshaType.vata, DoshaType.pitta],
    ),
    MealRecommendation(
      id: 'dn_2',
      name: 'Grilled Soya Chunks & Salad',
      description: 'Protein packed soya nuggets with fresh greens.',
      type: MealType.dinner,
      calories: 380,
      protein: 35,
      carbs: 25,
      fats: 12,
      ingredients: ['Soya Chunks', 'Cucumber', 'Lettuce', 'Yogurt dip'],
      suitableFor: [DoshaType.pitta, DoshaType.kapha],
    ),
  ];

  static DailyMealPlan generatePlan({
    required DoshaType dosha,
    required double targetCalories,
    required String goal, // 'weight_loss', 'maintenance', 'muscle_gain'
  }) {
    final Map<MealType, MealRecommendation> selectedMeals = {};

    // Simple rule-based selection: filter by Dosha and pick best fits
    for (var type in MealType.values) {
      final candidates = _allMeals
          .where((m) => m.type == type && m.suitableFor.contains(dosha))
          .toList();

      if (candidates.isEmpty) {
        // Fallback to any meal of that type if no dosha match found
        selectedMeals[type] = _allMeals.firstWhere((m) => m.type == type);
      } else {
        // In a real AI system, we'd use an optimization algorithm here
        // For MVP, we pick the first one or randomize
        candidates.shuffle();
        selectedMeals[type] = candidates.first;
      }
    }

    double totalCal = 0, totalProt = 0, totalCarb = 0, totalFat = 0;
    selectedMeals.forEach((key, meal) {
      totalCal += meal.calories;
      totalProt += meal.protein;
      totalCarb += meal.carbs;
      totalFat += meal.fats;
    });

    return DailyMealPlan(
      date: DateTime.now(),
      meals: selectedMeals,
      totalCalories: totalCal,
      totalProtein: totalProt,
      totalCarbs: totalCarb,
      totalFats: totalFat,
    );
  }
}
