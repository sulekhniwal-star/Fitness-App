import 'package:fitkarma/core/localization/localization.dart';
import 'package:fitkarma/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:fitkarma/features/profile/domain/models/profile_enums.dart';
import 'package:fitkarma/shared/presentation/theme/app_colors.dart';
import 'package:fitkarma/shared/presentation/theme/app_spacing.dart';
import 'package:fitkarma/shared/presentation/theme/app_typography.dart';
import 'package:fitkarma/shared/presentation/widgets/bento_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Step 5: Fitness & Health Goals.
class FitnessGoalsStepView extends ConsumerWidget {
  const FitnessGoalsStepView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.stringsOf(context);
    final onboardingState = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return SingleChildScrollView(
      key: const Key('step_goals_scroll'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.onboardingGoalsTitle,
            style: AppTypography.headline.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            strings.onboardingGoalsSubtitle,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          ...FitnessGoal.values.map((goal) {
            final isSelected = onboardingState.goals.contains(goal);
            final title = switch (goal) {
              FitnessGoal.weightLoss => 'Weight Loss & Calorie Deficit (-500 kcal)',
              FitnessGoal.maintenance => 'Weight Maintenance & Balance (0 kcal)',
              FitnessGoal.muscleGain => 'Muscle Gain & Hypertrophy (+300 kcal)',
              FitnessGoal.metabolicHealth => 'Metabolic Health & Glucose Stability (-250 kcal)',
              FitnessGoal.fasting => 'Intermittent Fasting & Autophagy (-350 kcal)',
              FitnessGoal.improveEndurance => 'Cardiovascular Endurance (+150 kcal)',
              FitnessGoal.stressReduction => 'Stress Reduction & Recovery (0 kcal)',
            };

            final icon = switch (goal) {
              FitnessGoal.weightLoss => Icons.trending_down,
              FitnessGoal.maintenance => Icons.balance,
              FitnessGoal.muscleGain => Icons.fitness_center,
              FitnessGoal.metabolicHealth => Icons.monitor_heart,
              FitnessGoal.fasting => Icons.timer,
              FitnessGoal.improveEndurance => Icons.directions_run,
              FitnessGoal.stressReduction => Icons.self_improvement,
            };

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: BentoCard(
                key: Key('goal_card_${goal.name}'),
                onTap: () => controller.toggleGoal(goal),
                icon: icon,
                iconColor: isSelected ? AppColors.primary : AppColors.textSecondary,
                title: title,
                trailing: Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
