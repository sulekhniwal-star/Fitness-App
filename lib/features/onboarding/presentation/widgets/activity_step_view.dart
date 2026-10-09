import 'package:fitkarma/core/localization/localization.dart';
import 'package:fitkarma/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:fitkarma/features/profile/domain/models/profile_enums.dart';
import 'package:fitkarma/shared/presentation/theme/app_colors.dart';
import 'package:fitkarma/shared/presentation/theme/app_spacing.dart';
import 'package:fitkarma/shared/presentation/theme/app_typography.dart';
import 'package:fitkarma/shared/presentation/widgets/bento_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Step 7: Activity Baseline Selection.
class ActivityStepView extends ConsumerWidget {
  const ActivityStepView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.stringsOf(context);
    final onboardingState = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return SingleChildScrollView(
      key: const Key('step_activity_scroll'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.onboardingActivityTitle,
            style: AppTypography.headline.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            strings.onboardingActivitySubtitle,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          ...ActivityLevel.values.map((level) {
            final isSelected = onboardingState.activityLevel == level;
            final (title, subtitle, icon) = switch (level) {
              ActivityLevel.sedentary => (
                  'Sedentary (1.20x PAL)',
                  'Desk job, little to no routine exercise',
                  Icons.chair,
                ),
              ActivityLevel.lightlyActive => (
                  'Lightly Active (1.375x PAL)',
                  'Light exercise or sports 1–3 days per week',
                  Icons.directions_walk,
                ),
              ActivityLevel.moderatelyActive => (
                  'Moderately Active (1.55x PAL)',
                  'Moderate exercise or sports 3–5 days per week',
                  Icons.directions_run,
                ),
              ActivityLevel.veryActive => (
                  'Very Active (1.725x PAL)',
                  'Hard training or sports 6–7 days per week',
                  Icons.fitness_center,
                ),
              ActivityLevel.extremelyActive => (
                  'Extremely Active (1.90x PAL)',
                  'Physical job or training multiple times a day',
                  Icons.sports_martial_arts,
                ),
            };

            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: BentoCard(
                key: Key('activity_card_${level.name}'),
                onTap: () => controller.setActivityLevel(level),
                icon: icon,
                iconColor: isSelected ? AppColors.primary : AppColors.textSecondary,
                title: title,
                subtitle: subtitle,
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
