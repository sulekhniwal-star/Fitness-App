import 'package:fitkarma/core/localization/localization.dart';
import 'package:fitkarma/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:fitkarma/features/profile/domain/models/profile_enums.dart';
import 'package:fitkarma/shared/presentation/theme/app_colors.dart';
import 'package:fitkarma/shared/presentation/theme/app_spacing.dart';
import 'package:fitkarma/shared/presentation/theme/app_typography.dart';
import 'package:fitkarma/shared/presentation/widgets/bento_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Step 6: Dietary Identity & Nutrition Preferences.
class DietaryStepView extends ConsumerWidget {
  const DietaryStepView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.stringsOf(context);
    final onboardingState = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return SingleChildScrollView(
      key: const Key('step_dietary_scroll'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.onboardingDietTitle,
            style: AppTypography.headline.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            strings.onboardingDietSubtitle,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Dietary Taxonomy Selection
          Text(
            'DIETARY IDENTITY',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          ...DietaryIdentity.values.map((identity) {
            final isSelected = onboardingState.dietaryIdentity == identity;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: BentoCard(
                key: Key('diet_card_${identity.name}'),
                onTap: () => controller.setDietaryIdentity(
                  identity,
                  mealsPerDay: onboardingState.mealsPerDay,
                  fastingProtocol: onboardingState.fastingProtocol,
                ),
                icon: Icons.restaurant_menu,
                iconColor: isSelected ? AppColors.primary : AppColors.textSecondary,
                title: identity.displayName,
                trailing: Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.lg),

          // Daily Meals Count
          Text(
            'MEALS PER DAY: ${onboardingState.mealsPerDay}',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Slider(
            key: const Key('slider_meals_per_day'),
            value: onboardingState.mealsPerDay.toDouble(),
            min: 1,
            max: 6,
            divisions: 5,
            activeColor: AppColors.primary,
            inactiveColor: AppColors.surfaceElevated,
            label: '${onboardingState.mealsPerDay} Meals',
            onChanged: (val) {
              controller.setDietaryIdentity(
                onboardingState.dietaryIdentity,
                mealsPerDay: val.round(),
                fastingProtocol: onboardingState.fastingProtocol,
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),

          // Fasting Protocol (Optional)
          Text(
            'INTERMITTENT FASTING PROTOCOL (OPTIONAL)',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _buildFastingChip(
                key: const Key('chip_fasting_none'),
                label: 'None / Standard',
                isSelected: onboardingState.fastingProtocol == null,
                onTap: () => controller.setDietaryIdentity(
                  onboardingState.dietaryIdentity,
                  mealsPerDay: onboardingState.mealsPerDay,
                  fastingProtocol: null,
                ),
              ),
              _buildFastingChip(
                key: const Key('chip_fasting_14_10'),
                label: '14:10 (Gentle)',
                isSelected: onboardingState.fastingProtocol == '14:10',
                onTap: () => controller.setDietaryIdentity(
                  onboardingState.dietaryIdentity,
                  mealsPerDay: onboardingState.mealsPerDay,
                  fastingProtocol: '14:10',
                ),
              ),
              _buildFastingChip(
                key: const Key('chip_fasting_16_8'),
                label: '16:8 (Popular)',
                isSelected: onboardingState.fastingProtocol == '16:8',
                onTap: () => controller.setDietaryIdentity(
                  onboardingState.dietaryIdentity,
                  mealsPerDay: onboardingState.mealsPerDay,
                  fastingProtocol: '16:8',
                ),
              ),
              _buildFastingChip(
                key: const Key('chip_fasting_circadian'),
                label: 'Circadian (Sun Cycle)',
                isSelected: onboardingState.fastingProtocol == 'circadian',
                onTap: () => controller.setDietaryIdentity(
                  onboardingState.dietaryIdentity,
                  mealsPerDay: onboardingState.mealsPerDay,
                  fastingProtocol: 'circadian',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildFastingChip({
    required Key key,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return ChoiceChip(
      key: key,
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.saffron.withAlpha(50),
      backgroundColor: AppColors.surfaceElevated,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.saffron : AppColors.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (_) => onTap(),
    );
  }
}
