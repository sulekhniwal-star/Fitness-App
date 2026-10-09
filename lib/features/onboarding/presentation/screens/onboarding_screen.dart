import 'package:fitkarma/core/localization/localization.dart';
import 'package:fitkarma/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:fitkarma/features/onboarding/presentation/widgets/account_setup_step_view.dart';
import 'package:fitkarma/features/onboarding/presentation/widgets/activity_step_view.dart';
import 'package:fitkarma/features/onboarding/presentation/widgets/ayurveda_step_view.dart';
import 'package:fitkarma/features/onboarding/presentation/widgets/basic_profile_step_view.dart';
import 'package:fitkarma/features/onboarding/presentation/widgets/consent_privacy_step_view.dart';
import 'package:fitkarma/features/onboarding/presentation/widgets/dietary_step_view.dart';
import 'package:fitkarma/features/onboarding/presentation/widgets/fitness_goals_step_view.dart';
import 'package:fitkarma/features/onboarding/presentation/widgets/language_step_view.dart';
import 'package:fitkarma/features/onboarding/presentation/widgets/permissions_step_view.dart';
import 'package:fitkarma/features/onboarding/presentation/widgets/welcome_step_view.dart';
import 'package:fitkarma/shared/presentation/theme/app_colors.dart';
import 'package:fitkarma/shared/presentation/theme/app_spacing.dart';
import 'package:fitkarma/shared/presentation/theme/app_typography.dart';
import 'package:fitkarma/shared/presentation/widgets/app_button.dart';
import 'package:fitkarma/shared/presentation/widgets/app_progress_bar.dart';
import 'package:fitkarma/shared/presentation/widgets/app_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Complete FitKarma multi-step onboarding wizard.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.stringsOf(context);
    final onboardingState = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    final currentStep = onboardingState.currentStep;
    final isWelcome = currentStep == OnboardingStep.welcome;
    final isLastStep = onboardingState.isLastStep;

    return AppScaffold(
      key: const Key('screen_onboarding'),
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: onboardingState.canGoBack
            ? IconButton(
                key: const Key('btn_onboarding_top_back'),
                icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                onPressed: () => controller.previousStep(),
              )
            : null,
        title: Text(
          isWelcome
              ? strings.appTitle
              : 'Step ${onboardingState.currentStepIndex + 1} of ${onboardingState.totalSteps}',
          style: AppTypography.titleMedium.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: AppProgressBar(
            key: const Key('onboarding_progress_bar'),
            value: onboardingState.progress,
            height: 4,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Error banner if validation fails
            if (onboardingState.errorMessage != null)
              Container(
                key: const Key('onboarding_error_banner'),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                margin: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(25),
                  borderRadius: BorderRadius.circular(AppSpacing.sm),
                  border: Border.all(color: AppColors.error.withAlpha(120)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 20,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        onboardingState.errorMessage!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Step Content View
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: KeyedSubtree(
                  key: ValueKey(onboardingState.currentStepIndex),
                  child: switch (currentStep) {
                    OnboardingStep.welcome => const WelcomeStepView(),
                    OnboardingStep.language => const LanguageStepView(),
                    OnboardingStep.consent => const ConsentPrivacyStepView(),
                    OnboardingStep.basicProfile =>
                      const BasicProfileStepView(),
                    OnboardingStep.goals => const FitnessGoalsStepView(),
                    OnboardingStep.dietary => const DietaryStepView(),
                    OnboardingStep.activity => const ActivityStepView(),
                    OnboardingStep.ayurveda => const AyurvedaStepView(),
                    OnboardingStep.permissions => const PermissionsStepView(),
                    OnboardingStep.accountSetup =>
                      const AccountSetupStepView(),
                  },
                ),
              ),
            ),

            // Bottom Navigation Actions (except on Account Setup where actions are embedded)
            if (!isLastStep)
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(
                    top: BorderSide(color: AppColors.surfaceBorder),
                  ),
                ),
                child: Row(
                  children: [
                    if (onboardingState.canGoBack) ...[
                      Expanded(
                        flex: 1,
                        child: AppButton(
                          key: const Key('btn_onboarding_back'),
                          label: strings.back,
                          variant: AppButtonVariant.secondary,
                          onPressed: () => controller.previousStep(),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                    ],
                    Expanded(
                      flex: 2,
                      child: AppButton(
                        key: const Key('btn_onboarding_next'),
                        label: isWelcome
                            ? strings.onboardingGetStarted
                            : strings.continueAction,
                        icon: Icons.arrow_forward,
                        onPressed: () => controller.nextStep(),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
