import 'package:fitkarma/shared/presentation/accessibility/accessibility_helpers.dart';
import 'package:fitkarma/shared/presentation/theme/app_colors.dart';
import 'package:fitkarma/shared/presentation/theme/app_motion.dart';
import 'package:fitkarma/shared/presentation/theme/app_radii.dart';
import 'package:fitkarma/shared/presentation/theme/app_spacing.dart';
import 'package:fitkarma/shared/presentation/theme/app_typography.dart';
import 'package:fitkarma/shared/presentation/widgets/glass_container.dart';
import 'package:flutter/material.dart';

/// Bento-grid building block for FitKarma dashboard and domain modules.
class BentoCard extends StatefulWidget {
  final String? title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;
  final Widget? child;
  final VoidCallback? onTap;
  final bool isGlass;
  final EdgeInsetsGeometry? padding;
  final String? semanticLabel;

  const BentoCard({
    super.key,
    this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.trailing,
    this.child,
    this.onTap,
    this.isGlass = false,
    this.padding,
    this.semanticLabel,
  });

  @override
  State<BentoCard> createState() => _BentoCardState();
}

class _BentoCardState extends State<BentoCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final effectivePadding = widget.padding ?? AppSpacing.cardPadding;
    final content = _buildCardContent(effectivePadding);
    final animationDuration = AccessibilityHelpers.getAccessibleDuration(
      context,
      AppMotion.fast,
    );

    final cardWidget = widget.isGlass
        ? GlassContainer(
            borderRadius: AppRadii.roundedMd,
            padding: EdgeInsets.zero,
            child: content,
          )
        : Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadii.roundedMd,
              border: Border.all(color: AppColors.surfaceBorder, width: 1.0),
            ),
            child: content,
          );

    final semanticText =
        widget.semanticLabel ??
        [widget.title, widget.subtitle].whereType<String>().join(', ');

    Widget result = Semantics(
      container: true,
      button: widget.onTap != null,
      label: semanticText.isNotEmpty ? semanticText : null,
      child: widget.onTap != null
          ? GestureDetector(
              onTapDown: (_) => setState(() => _isPressed = true),
              onTapUp: (_) => setState(() => _isPressed = false),
              onTapCancel: () => setState(() => _isPressed = false),
              onTap: widget.onTap,
              child: AnimatedScale(
                scale: _isPressed ? 0.98 : 1.0,
                duration: animationDuration,
                curve: AppMotion.springBounce,
                child: cardWidget,
              ),
            )
          : cardWidget,
    );

    return result;
  }

  Widget _buildCardContent(EdgeInsetsGeometry padding) {
    final hasHeader =
        widget.title != null || widget.icon != null || widget.trailing != null;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasHeader) ...[
            Row(
              children: [
                if (widget.icon != null) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs + 2),
                    decoration: BoxDecoration(
                      color: (widget.iconColor ?? AppColors.primary).withValues(
                        alpha: 0.15,
                      ),
                      borderRadius: AppRadii.roundedSm,
                    ),
                    child: Icon(
                      widget.icon,
                      size: 18,
                      color: widget.iconColor ?? AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                ],
                if (widget.title != null)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title!,
                          style: AppTypography.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle!,
                            style: AppTypography.bodySmall,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                if (widget.trailing != null) widget.trailing!,
              ],
            ),
            if (widget.child != null) const SizedBox(height: AppSpacing.md),
          ],
          if (widget.child != null) widget.child!,
        ],
      ),
    );
  }
}
