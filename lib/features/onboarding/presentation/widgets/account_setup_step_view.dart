import 'package:fitkarma/core/localization/localization.dart';
import 'package:fitkarma/core/routing/app_routes.dart';
import 'package:fitkarma/core/supabase/supabase_providers.dart';
import 'package:fitkarma/features/auth/presentation/controllers/google_auth_controller.dart';
import 'package:fitkarma/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:fitkarma/shared/presentation/theme/app_colors.dart';
import 'package:fitkarma/shared/presentation/theme/app_spacing.dart';
import 'package:fitkarma/shared/presentation/theme/app_typography.dart';
import 'package:fitkarma/shared/presentation/widgets/app_button.dart';
import 'package:fitkarma/shared/presentation/widgets/bento_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Step 10: Account Setup & Launch.
class AccountSetupStepView extends ConsumerWidget {
  const AccountSetupStepView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.stringsOf(context);
    final onboardingState = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final currentUser = ref.watch(currentUserProvider);

    return SingleChildScrollView(
      key: const Key('step_account_setup_scroll'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.onboardingAccountSetupTitle,
            style: AppTypography.headline.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            strings.onboardingAccountSetupSubtitle,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // If user is already authenticated (e.g. from prior login)
          if (currentUser != null) ...[
            BentoCard(
              title: 'Signed in as ${currentUser.phone ?? currentUser.email ?? "User"}',
              subtitle: 'Ready to finalize your profile and initialize your Daily Intelligence Package.',
              icon: Icons.check_circle,
              iconColor: AppColors.primary,
            ),
            const SizedBox(height: AppSpacing.xl),

            AppButton(
              key: const Key('btn_complete_authenticated'),
              label: strings.onboardingComplete,
              icon: Icons.rocket_launch,
              isLoading: onboardingState.isLoading,
              onPressed: () async {
                final result =
                    await controller.completeForCurrentUser(currentUser.id);
                if (context.mounted && result.isSuccess) {
                  context.go(AppRoutes.dashboard);
                }
              },
            ),
          ] else ...[
            // Option 1: Mobile Phone OTP (+91)
            AppButton(
              key: const Key('btn_signup_phone'),
              label: 'Continue with Mobile Number (+91 🇮🇳)',
              icon: Icons.phone_android,
              onPressed: () {
                context.push(AppRoutes.login);
              },
            ),
            const SizedBox(height: AppSpacing.md),

            // Option 2: Google Sign-In
            AppButton(
              key: const Key('btn_signup_google'),
              label: strings.continueWithGoogle,
              icon: Icons.g_mobiledata,
              variant: AppButtonVariant.secondary,
              onPressed: () async {
                final googleController =
                    ref.read(googleAuthControllerProvider.notifier);
                final success = await googleController.signInWithGoogle();
                if (success && context.mounted) {
                  final user = ref.read(currentUserProvider);
                  if (user != null) {
                    await controller.completeForCurrentUser(user.id);
                  }
                  if (context.mounted) {
                    context.go(AppRoutes.dashboard);
                  }
                }
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            // Option 3: Guest / Offline Mode
            Center(
              child: TextButton.icon(
                key: const Key('btn_continue_as_guest'),
                onPressed: onboardingState.isLoading
                    ? null
                    : () async {
                        final result = await controller.completeAsGuest();
                        if (context.mounted && result.isSuccess) {
                          context.go(AppRoutes.dashboard);
                        }
                      },
                icon: const Icon(Icons.person_outline, size: 18),
                label: Text(strings.onboardingContinueAsGuest),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                ),
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
