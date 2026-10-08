import 'package:fitkarma/core/localization/localization.dart';
import 'package:fitkarma/shared/presentation/theme/app_colors.dart';
import 'package:fitkarma/shared/presentation/theme/app_radii.dart';
import 'package:fitkarma/shared/presentation/theme/app_spacing.dart';
import 'package:fitkarma/shared/presentation/theme/app_typography.dart';
import 'package:fitkarma/shared/presentation/widgets/app_button.dart';
import 'package:flutter/material.dart';

/// Modal confirmation dialog with standard or destructive confirmation states.
class AppConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? confirmLabel;
  final String? cancelLabel;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final bool isDestructive;

  const AppConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmLabel,
    this.cancelLabel,
    required this.onConfirm,
    this.onCancel,
    this.isDestructive = false,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String message,
    String? confirmLabel,
    String? cancelLabel,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AppConfirmationDialog(
        title: title,
        message: message,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        onConfirm: () => Navigator.of(ctx).pop(true),
        onCancel: () => Navigator.of(ctx).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.stringsOf(context);

    return Dialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.roundedLg,
        side: const BorderSide(color: AppColors.surfaceBorder, width: 1.0),
      ),
      insetPadding: const EdgeInsets.all(AppSpacing.xl),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (isDestructive) ...[
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.error,
                    size: 24,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                Expanded(child: Text(title, style: AppTypography.titleLarge)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(message, style: AppTypography.bodyMedium),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onCancel ?? () => Navigator.of(context).pop(),
                  child: Text(
                    cancelLabel ?? strings.cancel,
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                AppButton(
                  label:
                      confirmLabel ??
                      (isDestructive ? strings.delete : strings.confirm),
                  variant: isDestructive
                      ? AppButtonVariant.ghost
                      : AppButtonVariant.primary,
                  onPressed: onConfirm,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// DPDP Act 2023 compliant consent dialog explaining processing purposes and revocability.
class AppConsentDialog extends StatelessWidget {
  final String title;
  final String purposeDescription;
  final List<String> dataElements;
  final VoidCallback onGrant;
  final VoidCallback? onDecline;
  final String? grantLabel;
  final String? declineLabel;

  const AppConsentDialog({
    super.key,
    required this.title,
    required this.purposeDescription,
    required this.dataElements,
    required this.onGrant,
    this.onDecline,
    this.grantLabel,
    this.declineLabel,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String title,
    required String purposeDescription,
    required List<String> dataElements,
    String? grantLabel,
    String? declineLabel,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AppConsentDialog(
        title: title,
        purposeDescription: purposeDescription,
        dataElements: dataElements,
        grantLabel: grantLabel,
        declineLabel: declineLabel,
        onGrant: () => Navigator.of(ctx).pop(true),
        onDecline: () => Navigator.of(ctx).pop(false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surfaceElevated,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadii.roundedLg,
        side: const BorderSide(color: AppColors.surfaceBorder, width: 1.0),
      ),
      insetPadding: const EdgeInsets.all(AppSpacing.xl),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(title, style: AppTypography.titleLarge)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(purposeDescription, style: AppTypography.bodyMedium),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Data categories accessed:',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            ...dataElements.map(
              (element) => Padding(
                padding: const EdgeInsets.only(left: AppSpacing.sm, bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.circle, size: 6, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text(element, style: AppTypography.bodySmall),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: AppRadii.roundedSm,
              ),
              child: Text(
                'DPDP Act 2023 Notice: You may review or revoke this consent at any time via Settings -> Data Vault.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onDecline ?? () => Navigator.of(context).pop(),
                  child: Text(
                    declineLabel ?? 'Decline',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                AppButton(
                  label: grantLabel ?? 'Grant Consent',
                  onPressed: onGrant,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Inline error notification banner for forms, card modules, and sync alerts.
class AppErrorPanel extends StatelessWidget {
  final String message;
  final String? errorCode;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const AppErrorPanel({
    super.key,
    required this.message,
    this.errorCode,
    this.onRetry,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Error notification: $message',
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.errorSubtle,
          borderRadius: AppRadii.roundedMd,
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.4),
            width: 1.0,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: AppColors.error,
              size: 20,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    message,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (errorCode != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Code: $errorCode',
                      style: AppTypography.bodySmall.copyWith(
                        fontFamily: 'monospace',
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: AppSpacing.sm),
              IconButton(
                icon: const Icon(
                  Icons.refresh,
                  size: 18,
                  color: AppColors.error,
                ),
                tooltip: 'Retry',
                onPressed: onRetry,
              ),
            ],
            if (onDismiss != null) ...[
              const SizedBox(width: AppSpacing.xs),
              IconButton(
                icon: const Icon(
                  Icons.close,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                tooltip: 'Dismiss',
                onPressed: onDismiss,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
