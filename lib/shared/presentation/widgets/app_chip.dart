import 'package:fitkarma/shared/presentation/theme/app_colors.dart';
import 'package:fitkarma/shared/presentation/theme/app_radii.dart';
import 'package:fitkarma/shared/presentation/theme/app_spacing.dart';
import 'package:fitkarma/shared/presentation/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Interactive filter or category chip.
class AppChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final ValueChanged<bool>? onSelected;
  final IconData? icon;
  final String? semanticLabel;

  const AppChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onSelected,
    this.icon,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: semanticLabel ?? label,
      child: FilterChip(
        selected: isSelected,
        label: Text(label),
        avatar: icon != null
            ? Icon(
                icon,
                size: 14,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              )
            : null,
        onSelected: onSelected,
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.primary.withValues(alpha: 0.15),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
          width: 1.0,
        ),
        labelStyle: AppTypography.labelSmall.copyWith(
          color: isSelected ? AppColors.primary : AppColors.textPrimary,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.roundedFull),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),
    );
  }
}

enum StatusType { success, warning, error, info, saffron }

/// Accessible status badge with color, text, and optional icon.
///
/// Complies with UI spec non-color-only rule: always pairs color with clear textual status.
class AppStatusBadge extends StatelessWidget {
  final String label;
  final StatusType type;
  final IconData? icon;

  const AppStatusBadge({
    super.key,
    required this.label,
    this.type = StatusType.info,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final (Color fgColor, Color bgColor) = _resolveColors();

    return Semantics(
      label: 'Status: $label',
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xxs + 1,
        ),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadii.roundedFull,
          border: Border.all(color: fgColor.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 12, color: fgColor),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: fgColor,
                fontWeight: FontWeight.w600,
                fontSize: 10.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  (Color, Color) _resolveColors() {
    switch (type) {
      case StatusType.success:
        return (AppColors.success, AppColors.success.withValues(alpha: 0.15));
      case StatusType.warning:
        return (AppColors.warning, AppColors.warning.withValues(alpha: 0.15));
      case StatusType.error:
        return (AppColors.error, AppColors.error.withValues(alpha: 0.15));
      case StatusType.info:
        return (AppColors.techBlue, AppColors.techBlue.withValues(alpha: 0.15));
      case StatusType.saffron:
        return (AppColors.saffron, AppColors.saffron.withValues(alpha: 0.15));
    }
  }
}
