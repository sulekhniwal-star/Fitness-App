import 'package:flutter/material.dart' hide StepState;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/app_localizations.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/providers/step_provider.dart';
import '../../../data/providers/festival_provider.dart';
import '../../../core/storage/hive_service.dart';
import '../profile/subscription_screen.dart';
import '../../widgets/voice_assistant_sheet.dart';
import '../../../core/utils/voice_service.dart';
import '../../widgets/health_twin_card.dart';
import '../../../domain/services/health_twin_service.dart';

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;
    final stepState = ref.watch(stepProvider);
    final l10n = AppLocalizations.of(context)!;

    // Trigger AI analysis on build (HealthTwinService handles debounce/checks internally)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(healthTwinServiceProvider).performAnalysis();
    });

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                'Hello, ${user?.name ?? 'User'}! 👋',
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            if (user?.subscriptionTier != 'free')
                              const Padding(
                                padding: EdgeInsets.only(left: 8.0),
                                child: Icon(Icons.verified,
                                    color: AppTheme.primaryColor),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.appTitle,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  // Karma Points Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.saffronColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.stars,
                          color: AppTheme.saffronColor,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${user?.karmaPoints ?? 0}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.saffronColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Step Counter Card
              _buildStepCounterCard(context, stepState, l10n),
              const SizedBox(height: 16),
              // Premium Ad for Free Users
              if (user?.subscriptionTier == 'free')
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline, color: Colors.grey),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Support FitKarma & remove ads. Upgrade to Premium today!',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (ctx) => const SubscriptionScreen()),
                          );
                        },
                        child: const Text('UPGRADE'),
                      ),
                    ],
                  ),
                ),
              // Festival Banner
              _buildFestivalBanner(context, ref),
              const HealthTwinCard(),
              // Quick Actions
              _buildQuickActions(context, l10n),
              const SizedBox(height: 24),
              // Weekly Progress
              Text(
                l10n.dashboard,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              _buildWeeklyChart(context, stepState),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showVoiceAssistant(context),
        backgroundColor: AppTheme.saffronColor,
        child: const Icon(Icons.mic, color: Colors.white),
      ),
    );
  }

  void _showVoiceAssistant(BuildContext context) async {
    final intent = await showModalBottomSheet<VoiceIntent>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const VoiceAssistantSheet(),
    );

    if (intent != null && context.mounted) {
      _handleVoiceIntent(context, intent);
    }
  }

  void _handleVoiceIntent(BuildContext context, VoiceIntent intent) {
    // Basic intent routing for MVP
    switch (intent.action) {
      case 'log_food':
        context.push('/food/logging');
        break;
      case 'track_steps':
        context.push('/home/activity-tracking');
        break;
      case 'log_workout':
        context.push('/workouts');
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Heard: "${intent.data['query']}"'),
            backgroundColor: AppTheme.saffronColor,
          ),
        );
    }
  }

  Widget _buildStepCounterCard(
      BuildContext context, StepState stepState, AppLocalizations l10n) {
    final todaySteps = stepState.steps;
    const goal = AppConstants.defaultStepGoal;
    final progress = (todaySteps / goal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryColor,
            AppTheme.primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.steps,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${stepState.overs} overs 🏏',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 0,
                    centerSpaceRadius: 70,
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(
                        value: todaySteps.toDouble(),
                        color: Colors.white,
                        radius: 25,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: (goal - todaySteps).clamp(0, goal).toDouble(),
                        color: Colors.white.withOpacity(0.2),
                        radius: 25,
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$todaySteps',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'of $goal',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${(progress * 100).toInt()}% of daily goal',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.restaurant_menu,
            label: l10n.food,
            color: AppTheme.secondaryColor,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.fitness_center,
            label: l10n.workouts,
            color: AppTheme.accentColor,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.water_drop,
            label: l10n.waterIntake,
            color: AppTheme.mintColor,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            context,
            icon: Icons.map_outlined,
            label: l10n.trackWalk,
            color: Colors.orange,
            onTap: () => context.push('/home/activity-tracking'),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFestivalBanner(BuildContext context, WidgetRef ref) {
    final festivalState = ref.watch(festivalProvider);
    if (!festivalState.isFestivalDay) {
      return const SizedBox.shrink();
    }

    final festival = festivalState.todayFestival!;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.saffronColor, Colors.orange],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.saffronColor.withValues(alpha: 0.3),
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
              const Icon(Icons.celebration, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Happy ${festival.name}!',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: Colors.white),
                onPressed: () => context.push('/home/festival-calendar'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Enjoy your day with +${((festival.calorieMultiplier - 1) * 100).toInt()}% calorie flexibility. Try ${festival.workoutSuggestion} today!',
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context, StepState stepState) {
    final box = HiveService.stepsBox;
    final now = DateTime.now();

    String getDateStr(DateTime date) {
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }

    final weekData = <int>[];
    final days = <String>[];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateStr = getDateStr(date);
      final dayLetter = ['M', 'T', 'W', 'T', 'F', 'S', 'S'][date.weekday - 1];
      days.add(dayLetter);

      if (i == 0) {
        weekData.add(stepState.steps);
      } else {
        final val = box.get('history_$dateStr');
        weekData.add(val is int ? val : 0);
      }
    }

    final maxVal = weekData.reduce((a, b) => a > b ? a : b).toDouble();
    final maxY = maxVal < 1000 ? 1000.0 : maxVal * 1.2;

    return Container(
      height: 200,
      padding: const EdgeInsets.all(AppConstants.paddingMedium),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY,
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  return Text(
                    days[value.toInt()],
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (index) {
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: weekData[index].toDouble(),
                  color: AppTheme.primaryColor,
                  width: 20,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
