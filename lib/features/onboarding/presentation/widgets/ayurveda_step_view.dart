import 'package:fitkarma/core/localization/localization.dart';
import 'package:fitkarma/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:fitkarma/features/profile/domain/models/profile_enums.dart';
import 'package:fitkarma/shared/presentation/theme/app_colors.dart';
import 'package:fitkarma/shared/presentation/theme/app_spacing.dart';
import 'package:fitkarma/shared/presentation/theme/app_typography.dart';
import 'package:fitkarma/shared/presentation/widgets/bento_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Step 8: Optional Ayurveda & Prakriti Personalization Flow.
class AyurvedaStepView extends ConsumerWidget {
  const AyurvedaStepView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.stringsOf(context);
    final onboardingState = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return SingleChildScrollView(
      key: const Key('step_ayurveda_scroll'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.spa, color: AppColors.saffron, size: 24),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  strings.onboardingAyurvedaTitle,
                  style: AppTypography.headline.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            strings.onboardingAyurvedaSubtitle,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Non-Medical Disclaimer Banner
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.saffron.withAlpha(20),
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              border: Border.all(color: AppColors.saffron.withAlpha(120)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.saffron,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    strings.onboardingAyurvedaDisclaimer,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Dosha Cards
          _buildDoshaCard(
            key: const Key('dosha_card_vata'),
            dosha: AyurvedicDosha.vata,
            isSelected: onboardingState.dosha == AyurvedicDosha.vata,
            onTap: () => controller.setDosha(AyurvedicDosha.vata),
          ),
          const SizedBox(height: AppSpacing.md),

          _buildDoshaCard(
            key: const Key('dosha_card_pitta'),
            dosha: AyurvedicDosha.pitta,
            isSelected: onboardingState.dosha == AyurvedicDosha.pitta,
            onTap: () => controller.setDosha(AyurvedicDosha.pitta),
          ),
          const SizedBox(height: AppSpacing.md),

          _buildDoshaCard(
            key: const Key('dosha_card_kapha'),
            dosha: AyurvedicDosha.kapha,
            isSelected: onboardingState.dosha == AyurvedicDosha.kapha,
            onTap: () => controller.setDosha(AyurvedicDosha.kapha),
          ),
          const SizedBox(height: AppSpacing.md),

          _buildDoshaCard(
            key: const Key('dosha_card_tridoshic'),
            dosha: AyurvedicDosha.tridoshic,
            isSelected: onboardingState.dosha == AyurvedicDosha.tridoshic,
            onTap: () => controller.setDosha(AyurvedicDosha.tridoshic),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Skip / Not Sure Button
          Center(
            child: TextButton.icon(
              key: const Key('btn_skip_ayurveda'),
              onPressed: () {
                controller.setDosha(null);
                controller.nextStep();
              },
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: Text(strings.onboardingSkip),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildDoshaCard({
    required Key key,
    required AyurvedicDosha dosha,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return BentoCard(
      key: key,
      onTap: onTap,
      icon: Icons.self_improvement,
      iconColor: isSelected ? AppColors.saffron : AppColors.textSecondary,
      title: dosha.displayName,
      subtitle: dosha.description,
      trailing: Icon(
        isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
        color: isSelected ? AppColors.saffron : AppColors.textSecondary,
      ),
    );
  }
}
