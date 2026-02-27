import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/storage/hive_service.dart';
import '../../core/theme/app_theme.dart';
import '../../data/providers/auth_provider.dart';

class MacroSummaryCard extends ConsumerWidget {
  const MacroSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider).user;
    if (user == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    final todayLogs = HiveService.foodLogBox.values
        .where((log) => log.userId == user.id && log.date.isAfter(todayStart))
        .toList();

    if (todayLogs.isEmpty) return const SizedBox.shrink();

    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;

    for (final log in todayLogs) {
      totalCalories += log.calories;
      totalProtein += log.proteinGrams;
      totalCarbs += log.carbsGrams;
      totalFat += log.fatGrams;
    }

    // Rough daily targets
    const calorieGoal = 2000.0;
    const proteinGoal = 60.0;
    const carbsGoal = 250.0;
    const fatGoal = 65.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_fire_department,
                  color: AppTheme.saffronColor, size: 20),
              const SizedBox(width: 8),
              Text(
                "Today's Nutrition",
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Text(
                '${totalCalories.toInt()} / ${calorieGoal.toInt()} kcal',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _MacroBar(
            label: 'Calories',
            value: totalCalories,
            goal: calorieGoal,
            color: AppTheme.saffronColor,
          ),
          const SizedBox(height: 8),
          _MacroBar(
            label: 'Protein',
            value: totalProtein,
            goal: proteinGoal,
            color: AppTheme.primaryColor,
            unit: 'g',
          ),
          const SizedBox(height: 8),
          _MacroBar(
            label: 'Carbs',
            value: totalCarbs,
            goal: carbsGoal,
            color: AppTheme.secondaryColor,
            unit: 'g',
          ),
          const SizedBox(height: 8),
          _MacroBar(
            label: 'Fat',
            value: totalFat,
            goal: fatGoal,
            color: AppTheme.accentColor,
            unit: 'g',
          ),
        ],
      ),
    );
  }
}

class _MacroBar extends StatelessWidget {
  final String label;
  final double value;
  final double goal;
  final Color color;
  final String unit;

  const _MacroBar({
    required this.label,
    required this.value,
    required this.goal,
    required this.color,
    this.unit = 'kcal',
  });

  @override
  Widget build(BuildContext context) {
    final progress = (value / goal).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              '${value.toInt()}$unit',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
