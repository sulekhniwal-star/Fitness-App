import 'package:fitkarma/core/localization/localization.dart';
import 'package:fitkarma/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:fitkarma/shared/presentation/theme/app_colors.dart';
import 'package:fitkarma/shared/presentation/theme/app_spacing.dart';
import 'package:fitkarma/shared/presentation/theme/app_typography.dart';
import 'package:fitkarma/shared/presentation/widgets/bento_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Step 3: Consent & Privacy Explanation.
class ConsentPrivacyStepView extends ConsumerWidget {
  const ConsentPrivacyStepView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.stringsOf(context);
    final onboardingState = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return SingleChildScrollView(
      key: const Key('step_consent_scroll'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.onboardingPrivacyTitle,
            style: AppTypography.headline.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            strings.onboardingPrivacySubtitle,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Privacy Principles Bento
          const BentoCard(
            title: 'Digital Personal Data Protection (DPDP) Act Aligned',
            subtitle:
                'We only collect information needed to personalize nutritional calculations, daily routines, and fitness metrics.',
            icon: Icons.verified_user,
            iconColor: AppColors.techBlue,
          ),
          const SizedBox(height: AppSpacing.md),

          const BentoCard(
            title: 'Local-First Encryption',
            subtitle:
                'Your logs and observations remain on your device in encrypted storage. You can export or delete all data anytime from the Data Vault.',
            icon: Icons.lock,
            iconColor: AppColors.primary,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Required Non-Medical Disclaimer Box
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
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    strings.onboardingMedicalDisclaimer,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Consent Checkbox
          InkWell(
            key: const Key('consent_checkbox_tile'),
            onTap: () {
              controller.setConsent(!onboardingState.consentGranted);
            },
            borderRadius: BorderRadius.circular(AppSpacing.sm),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: onboardingState.consentGranted
                    ? AppColors.primary.withAlpha(20)
                    : AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                border: Border.all(
                  color: onboardingState.consentGranted
                      ? AppColors.primary
                      : AppColors.surfaceBorder,
                ),
              ),
              child: Row(
                children: [
                  Checkbox(
                    key: const Key('consent_checkbox'),
                    value: onboardingState.consentGranted,
                    activeColor: AppColors.primary,
                    checkColor: AppColors.background,
                    onChanged: (val) {
                      controller.setConsent(val ?? false);
                    },
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      strings.onboardingPrivacyConsentLabel,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
