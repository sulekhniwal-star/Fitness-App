import 'package:fitkarma/core/localization/localization.dart';
import 'package:fitkarma/shared/presentation/theme/app_colors.dart';
import 'package:fitkarma/shared/presentation/theme/app_spacing.dart';
import 'package:fitkarma/shared/presentation/theme/app_typography.dart';
import 'package:fitkarma/shared/presentation/widgets/bento_card.dart';
import 'package:flutter/material.dart';

/// Step 1: Welcome & Value Proposition.
class WelcomeStepView extends StatelessWidget {
  const WelcomeStepView({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.stringsOf(context);

    return SingleChildScrollView(
      key: const Key('step_welcome_scroll'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              border: Border.all(color: AppColors.primary.withAlpha(80)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.favorite,
                  color: AppColors.primary,
                  size: 16,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  'FITKARMA HEALTH OS',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Main Header
          Text(
            strings.onboardingWelcomeTitle,
            style: AppTypography.display.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            strings.onboardingWelcomeSubtitle,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Value Proposition Bento Grid
          const BentoCard(
            title: '🇮🇳 India-First Nutrition',
            subtitle:
                'Recognizes local foods, raw vs cooked yields, tadka oil slider, and household portion units.',
            icon: Icons.restaurant,
            iconColor: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.md),

          const BentoCard(
            title: '🔒 Privacy by Default',
            subtitle:
                'DPDP Act aligned. Local-first encrypted storage, no ad tracking, and complete data ownership.',
            icon: Icons.security,
            iconColor: AppColors.techBlue,
          ),
          const SizedBox(height: AppSpacing.md),

          const BentoCard(
            title: '⚡ Offline-First Architecture',
            subtitle:
                'Log workouts and meals without active cellular data. Reconciles seamlessly when online.',
            icon: Icons.cloud_off,
            iconColor: AppColors.primaryAccent,
          ),
          const SizedBox(height: AppSpacing.md),

          const BentoCard(
            title: '🌿 Holistic Wellness & Fasting',
            subtitle:
                'Personalized Daily Intelligence Package (DIP), circadian fasting schedules, and Ayurvedic balance.',
            icon: Icons.spa,
            iconColor: AppColors.saffron,
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
