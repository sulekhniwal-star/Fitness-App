import 'package:fitkarma/shared/presentation/theme/app_colors.dart';
import 'package:fitkarma/shared/presentation/theme/app_radii.dart';
import 'package:fitkarma/shared/presentation/theme/app_spacing.dart';
import 'package:fitkarma/shared/presentation/theme/app_typography.dart';
import 'package:flutter/material.dart';

enum SnackBarType { success, error, warning, info }

/// Helper for displaying floating accessible snackbars/toasts in FitKarma.
abstract final class AppSnackBar {
  static void show(
    BuildContext context, {
    required String message,
    SnackBarType type = SnackBarType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final (Color iconColor, IconData icon) = _resolveType(type);

    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      elevation: 0,
      backgroundColor: Colors.transparent,
      duration: duration,
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: EdgeInsets.zero,
      content: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: AppRadii.roundedMd,
          border: Border.all(
            color: iconColor.withValues(alpha: 0.5),
            width: 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(width: AppSpacing.sm),
              TextButton(
                onPressed: () {
                  messenger.hideCurrentSnackBar();
                  onAction();
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  minimumSize: const Size(0, 32),
                ),
                child: Text(
                  actionLabel,
                  style: AppTypography.labelSmall.copyWith(
                    color: iconColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );

    messenger.showSnackBar(snackBar);
  }

  static (Color, IconData) _resolveType(SnackBarType type) {
    switch (type) {
      case SnackBarType.success:
        return (AppColors.success, Icons.check_circle_outline);
      case SnackBarType.error:
        return (AppColors.error, Icons.error_outline_rounded);
      case SnackBarType.warning:
        return (AppColors.warning, Icons.warning_amber_rounded);
      case SnackBarType.info:
        return (AppColors.techBlue, Icons.info_outline);
    }
  }
}
