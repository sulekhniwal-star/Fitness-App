import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/meal_recommendation_model.dart';
import '../../../data/providers/meal_provider.dart';

class MealPlannerScreen extends ConsumerStatefulWidget {
  const MealPlannerScreen({super.key});

  @override
  ConsumerState<MealPlannerScreen> createState() => _MealPlannerScreenState();
}

class _MealPlannerScreenState extends ConsumerState<MealPlannerScreen> {
  @override
  void initState() {
    super.initState();
    // Generate plan on first load if not exists
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ref.read(mealProvider).currentPlan == null) {
        ref.read(mealProvider.notifier).generatePlan();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final mealState = ref.watch(mealProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('AI Meal Planner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(mealProvider.notifier).generatePlan(),
            tooltip: 'Regenerate Plan',
          ),
        ],
      ),
      body: mealState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : mealState.currentPlan == null
              ? _buildEmptyState()
              : _buildPlanView(mealState.currentPlan!),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text('No plan generated yet.'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(mealProvider.notifier).generatePlan(),
            child: const Text('GENERATE MY PLAN'),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanView(DailyMealPlan plan) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMacroSummary(plan),
          const SizedBox(height: 24),
          const Text(
            'Today\'s Menu',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...plan.meals.entries.map((e) => _buildMealCard(e.key, e.value)),
          const SizedBox(height: 32),
          _buildGritTip(),
        ],
      ),
    );
  }

  Widget _buildMacroSummary(DailyMealPlan plan) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMacroItem('Calories', '${plan.totalCalories.toInt()}',
                  'kcal', Colors.orange),
              _buildMacroItem(
                  'Protein', '${plan.totalProtein.toInt()}', 'g', Colors.blue),
              _buildMacroItem(
                  'Carbs', '${plan.totalCarbs.toInt()}', 'g', Colors.green),
              _buildMacroItem(
                  'Fats', '${plan.totalFats.toInt()}', 'g', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String label, String value, String unit, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold, color: color),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildMealCard(MealType type, MealRecommendation meal) {
    final color = _getMealColor(type);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_getMealIcon(type), color: color),
          ),
          title: Text(
            type.name.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 1.2,
            ),
          ),
          subtitle: Text(
            meal.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    meal.description,
                    style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  const Text('Key Ingredients:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    children: meal.ingredients
                        .map((i) => Chip(
                              label:
                                  Text(i, style: const TextStyle(fontSize: 12)),
                              backgroundColor: Colors.grey.shade100,
                              side: BorderSide.none,
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildMiniBadge('${meal.calories.toInt()} kcal'),
                      const SizedBox(width: 8),
                      _buildMiniBadge('${meal.protein.toInt()}g Protein'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildGritTip() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.mintColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.mintColor.withValues(alpha: 0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.lightbulb_outline, color: AppTheme.mintColor),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Grit Tip: Your meals are balanced for your Dosha. Try to eat mindfully and chew well!',
              style: TextStyle(fontSize: 13, color: Colors.teal),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getMealIcon(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Icons.wb_sunny_outlined;
      case MealType.lunch:
        return Icons.lunch_dining_outlined;
      case MealType.snack:
        return Icons.coffee_outlined;
      case MealType.dinner:
        return Icons.nightlight_round_outlined;
    }
  }

  Color _getMealColor(MealType type) {
    switch (type) {
      case MealType.breakfast:
        return Colors.orange;
      case MealType.lunch:
        return Colors.blue;
      case MealType.snack:
        return Colors.green;
      case MealType.dinner:
        return Colors.indigo;
    }
  }
}
