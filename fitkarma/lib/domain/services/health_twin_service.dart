import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/health_insight_model.dart';
import '../../data/models/user_model.dart';
import '../../data/providers/insight_provider.dart';
import '../../data/providers/auth_provider.dart';
import '../../core/storage/hive_service.dart';

class HealthTwinService {
  final Ref _ref;

  HealthTwinService(this._ref);

  Future<void> performAnalysis() async {
    final user = _ref.read(authStateProvider).user;
    if (user == null) return;

    // 1. Analyze Late Night Eating
    await _analyzeLateNightEating(user);

    // 2. Analyze Weekend Slump
    await _analyzeWeekendSlump(user);

    // 3. Analyze Dosha Alignment (Placeholder for now)
    await _analyzeDoshaAlignment(user);
  }

  Future<void> _analyzeLateNightEating(UserModel user) async {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    final recentLogs = HiveService.foodLogBox.values
        .where((log) => log.date.isAfter(sevenDaysAgo) && log.userId == user.id)
        .toList();

    int lateNightCount = 0;
    for (var log in recentLogs) {
      if (log.date.hour >= 22 || log.date.hour < 4) {
        lateNightCount++;
      }
    }

    if (lateNightCount >= 3) {
      final insight = HealthInsight(
        id: 'late_night_${now.day}_${now.month}',
        type: InsightType.warning,
        title: 'Late Night Snacking Pattern',
        description:
            'You\'ve logged $lateNightCount meals late at night this week. Eating late can disrupt sleep and digestion, especially for ${user.dosha ?? "your digestive system"}.',
        category: InsightCategory.diet,
        createdAt: now,
        score: 0.8,
      );
      await _ref.read(insightProvider.notifier).addInsight(insight);
    }
  }

  Future<void> _analyzeWeekendSlump(UserModel user) async {
    final now = DateTime.now();
    // Simplified weekend check for demo purposes
    // In a real app, we'd compare weekday avg steps vs weekend avg steps

    const weekdaySteps = [8000.0, 7500.0, 9000.0, 8200.0, 7800.0];
    final weekdayAvg =
        weekdaySteps.reduce((a, b) => a + b) / weekdaySteps.length;

    // Check Saturday steps (mocking data if not present)
    // For now, let's just trigger it if current day is Sunday and steps are low
    if (now.weekday == DateTime.sunday) {
      // Mocked check
      const todaySteps = 2500.0; // This should come from stepProvider
      if (todaySteps < (weekdayAvg * 0.5)) {
        final insight = HealthInsight(
          id: 'weekend_slump_${now.day}_${now.month}',
          type: InsightType.suggestion,
          title: 'Weekend Inactivity',
          description:
              'Your activity level drops significantly on weekends. A short 20-minute walk can help maintain your momentum.',
          category: InsightCategory.activity,
          createdAt: now,
          score: 0.7,
        );
        await _ref.read(insightProvider.notifier).addInsight(insight);
      }
    }
  }

  Future<void> _analyzeDoshaAlignment(UserModel user) async {
    // This would compare food_logs with MealRepository.suitableFor(user.dosha)
    // Placeholder logic
    final now = DateTime.now();
    final insight = HealthInsight(
      id: 'dosha_alignment_${now.day}_${now.month}',
      type: InsightType.achievement,
      title: 'Great Dosha Alignment!',
      description:
          'Your meals today perfectly aligned with your Kapha nature. You\'re choosing the right light and spicy foods.',
      category: InsightCategory.diet,
      createdAt: now,
      score: 0.9,
    );
    await _ref.read(insightProvider.notifier).addInsight(insight);
  }
}

final healthTwinServiceProvider = Provider<HealthTwinService>((ref) {
  return HealthTwinService(ref);
});
