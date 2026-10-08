import 'package:fitkarma/shared/presentation/accessibility/accessibility_helpers.dart';
import 'package:fitkarma/shared/presentation/theme/app_colors.dart';
import 'package:fitkarma/shared/presentation/theme/app_motion.dart';
import 'package:fitkarma/shared/presentation/theme/app_radii.dart';
import 'package:fitkarma/shared/presentation/theme/app_spacing.dart';
import 'package:fitkarma/shared/presentation/theme/app_typography.dart';
import 'package:fitkarma/shared/presentation/widgets/glass_container.dart';
import 'package:flutter/material.dart';

/// Navigation item model for bottom navigation shell.
class BottomNavTab {
  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final String? semanticLabel;

  const BottomNavTab({
    required this.label,
    required this.icon,
    this.activeIcon,
    this.semanticLabel,
  });
}

/// Glassmorphic bottom navigation shell for primary application tabs.
class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final List<BottomNavTab> tabs;

  const AppBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      borderRadius: AppRadii.roundedLg,
      fillColor: AppColors.surface.withValues(alpha: 0.85),
      borderColor: AppColors.surfaceBorder,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(tabs.length, (index) {
          final tab = tabs[index];
          final isSelected = index == currentIndex;

          return _NavBarItem(
            tab: tab,
            isSelected: isSelected,
            onTap: () => onTabSelected(index),
          );
        }),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final BottomNavTab tab;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveLabel = tab.semanticLabel ?? tab.label;
    final animationDuration = AccessibilityHelpers.getAccessibleDuration(
      context,
      AppMotion.fast,
    );

    return Semantics(
      button: true,
      selected: isSelected,
      label: '$effectiveLabel tab${isSelected ? ", selected" : ""}',
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.roundedMd,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: AnimatedContainer(
            duration: animationDuration,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs + 2,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : Colors.transparent,
              borderRadius: AppRadii.roundedMd,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isSelected ? (tab.activeIcon ?? tab.icon) : tab.icon,
                  size: 22,
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                ),
                const SizedBox(height: 2),
                Text(
                  tab.label,
                  style: AppTypography.labelSmall.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textMuted,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
