import 'package:fitkarma/shared/presentation/theme/app_colors.dart';
import 'package:fitkarma/shared/presentation/theme/app_spacing.dart';
import 'package:fitkarma/shared/presentation/theme/app_typography.dart';
import 'package:fitkarma/shared/presentation/widgets/app_chip.dart';
import 'package:fitkarma/shared/presentation/widgets/app_progress_bar.dart';
import 'package:fitkarma/shared/presentation/widgets/bento_card.dart';
import 'package:flutter/material.dart';

/// Specialized Bento card for presenting health and biometric metrics.
class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color? iconColor;
  final double? progress; // 0.0 to 1.0
  final String? goalText;
  final String? trendText;
  final StatusType? trendStatus;
  final VoidCallback? onTap;
  final bool isGlass;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    this.iconColor,
    this.progress,
    this.goalText,
    this.trendText,
    this.trendStatus,
    this.onTap,
    this.isGlass = false,
  });

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      title: title,
      icon: icon,
      iconColor: iconColor ?? AppColors.primary,
      isGlass: isGlass,
      onTap: onTap,
      trailing: trendText != null
          ? AppStatusBadge(
              label: trendText!,
              type: trendStatus ?? StatusType.info,
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: AppTypography.metricNumeral),
              const SizedBox(width: AppSpacing.xs),
              Text(unit, style: AppTypography.metricUnit),
            ],
          ),
          if (progress != null || goalText != null) ...[
            const SizedBox(height: AppSpacing.sm),
            if (progress != null)
              AppProgressBar(value: progress!, trailingText: goalText)
            else if (goalText != null)
              Text(goalText!, style: AppTypography.bodySmall),
          ],
        ],
      ),
    );
  }
}
