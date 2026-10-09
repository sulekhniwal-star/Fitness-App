import 'package:fitkarma/core/localization/localization.dart';
import 'package:fitkarma/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:fitkarma/shared/presentation/theme/app_colors.dart';
import 'package:fitkarma/shared/presentation/theme/app_spacing.dart';
import 'package:fitkarma/shared/presentation/theme/app_typography.dart';
import 'package:fitkarma/shared/presentation/widgets/bento_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Step 2: Language Selection.
class LanguageStepView extends ConsumerWidget {
  const LanguageStepView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.stringsOf(context);
    final onboardingState = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return SingleChildScrollView(
      key: const Key('step_language_scroll'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.onboardingLanguageTitle,
            style: AppTypography.headline.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            strings.onboardingLanguageSubtitle,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Active fully-localized languages
          _buildLanguageTile(
            key: const Key('lang_option_en'),
            title: 'English',
            subtitle: 'Default language',
            nativeName: 'English',
            isSelected: onboardingState.selectedLocale == 'en',
            onTap: () => controller.setLocale('en'),
          ),
          const SizedBox(height: AppSpacing.md),

          _buildLanguageTile(
            key: const Key('lang_option_hi'),
            title: 'Hindi',
            subtitle: 'पूर्ण अनुवाद उपलब्ध',
            nativeName: 'हिन्दी',
            isSelected: onboardingState.selectedLocale == 'hi',
            onTap: () => controller.setLocale('hi'),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Expansion Languages Section Header
          Text(
            'REGIONAL LANGUAGES (PREPARING)',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Preview regional expansion chips
          Wrap(
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: [
              _buildComingSoonChip('தமிழ் (Tamil)'),
              _buildComingSoonChip('తెలుగు (Telugu)'),
              _buildComingSoonChip('ગુજરાતી (Gujarati)'),
              _buildComingSoonChip('বাংলা (Bengali)'),
              _buildComingSoonChip('मराठी (Marathi)'),
              _buildComingSoonChip('ਪੰਜਾਬੀ (Punjabi)'),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildLanguageTile({
    required Key key,
    required String title,
    required String subtitle,
    required String nativeName,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return BentoCard(
      key: key,
      onTap: onTap,
      iconColor: isSelected ? AppColors.primary : null,
      title: title,
      subtitle: subtitle,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            nativeName,
            style: AppTypography.titleMedium.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Icon(
            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildComingSoonChip(String label) {
    return Chip(
      backgroundColor: AppColors.surfaceElevated,
      side: BorderSide(color: AppColors.surfaceBorder.withAlpha(80)),
      label: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      avatar: const Icon(
        Icons.schedule,
        size: 14,
        color: AppColors.textSecondary,
      ),
    );
  }
}
