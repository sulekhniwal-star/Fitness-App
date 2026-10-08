import 'package:fitkarma/shared/presentation/theme/app_colors.dart';
import 'package:fitkarma/shared/presentation/theme/app_motion.dart';
import 'package:fitkarma/shared/presentation/theme/app_radii.dart';
import 'package:fitkarma/shared/presentation/theme/app_spacing.dart';
import 'package:fitkarma/shared/presentation/theme/app_typography.dart';
import 'package:flutter/material.dart';

/// Animated progress indicator with accessible semantics and custom gradient fill.
class AppProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final double height;
  final Gradient? gradient;
  final Color? trackColor;
  final String? label;
  final String? trailingText;
  final String? semanticLabel;

  const AppProgressBar({
    super.key,
    required this.value,
    this.height = 8.0,
    this.gradient,
    this.trackColor,
    this.label,
    this.trailingText,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    final clampedValue = value.clamp(0.0, 1.0);
    final percentage = (clampedValue * 100).round();
    final effectiveSemantic =
        semanticLabel ??
        (label != null ? '$label: $percentage%' : 'Progress: $percentage%');

    return Semantics(
      label: effectiveSemantic,
      value: '$percentage%',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null || trailingText != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  Text(
                    label!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (trailingText != null)
                  Text(
                    trailingText!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
          ],
          LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              return Container(
                height: height,
                width: totalWidth,
                decoration: BoxDecoration(
                  color: trackColor ?? AppColors.surfaceElevated,
                  borderRadius: AppRadii.roundedFull,
                ),
                child: Stack(
                  children: [
                    AnimatedContainer(
                      duration: AppMotion.normal,
                      curve: AppMotion.easeOut,
                      width: totalWidth * clampedValue,
                      height: height,
                      decoration: BoxDecoration(
                        gradient: gradient ?? AppColors.primaryGradient,
                        borderRadius: AppRadii.roundedFull,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
