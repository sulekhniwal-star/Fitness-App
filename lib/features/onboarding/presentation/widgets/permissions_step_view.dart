import 'package:fitkarma/core/localization/localization.dart';
import 'package:fitkarma/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:fitkarma/shared/presentation/theme/app_colors.dart';
import 'package:fitkarma/shared/presentation/theme/app_spacing.dart';
import 'package:fitkarma/shared/presentation/theme/app_typography.dart';
import 'package:fitkarma/shared/presentation/widgets/bento_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Step 9: Permissions & Health Platform Integrations.
class PermissionsStepView extends ConsumerWidget {
  const PermissionsStepView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.stringsOf(context);
    final onboardingState = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return SingleChildScrollView(
      key: const Key('step_permissions_scroll'),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.onboardingPermissionsTitle,
            style: AppTypography.headline.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            strings.onboardingPermissionsSubtitle,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Notification Permissions Tile
          BentoCard(
            key: const Key('permission_tile_notifications'),
            icon: Icons.notifications_active,
            iconColor: onboardingState.notificationsEnabled
                ? AppColors.primary
                : AppColors.textSecondary,
            title: strings.onboardingNotificationsLabel,
            subtitle:
                'Receive your Daily Intelligence Package (DIP) at 7:00 AM, meal logging prompts, and hydration reminders. Zero marketing spam.',
            trailing: Switch(
              key: const Key('switch_notifications'),
              value: onboardingState.notificationsEnabled,
              activeThumbColor: AppColors.primary,
              onChanged: (val) => controller.setNotificationsEnabled(val),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Health Platform Permission Entry Point
          BentoCard(
            key: const Key('permission_tile_health_sync'),
            icon: Icons.monitor_heart,
            iconColor: onboardingState.healthSyncEnabled
                ? AppColors.techBlue
                : AppColors.textSecondary,
            title: strings.onboardingHealthSyncLabel,
            subtitle:
                'Aggregate daily steps, active energy, heart rate, and sleep metrics from Android Health Connect / Apple HealthKit. Processed locally.',
            trailing: Switch(
              key: const Key('switch_health_sync'),
              value: onboardingState.healthSyncEnabled,
              activeThumbColor: AppColors.techBlue,
              onChanged: (val) => controller.setHealthSyncEnabled(val),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
