import 'package:fitkarma/shared/presentation/theme/app_colors.dart';
import 'package:fitkarma/shared/presentation/theme/app_motion.dart';
import 'package:fitkarma/shared/presentation/theme/app_radii.dart';
import 'package:fitkarma/shared/presentation/theme/app_spacing.dart';
import 'package:fitkarma/shared/presentation/theme/app_typography.dart';
import 'package:flutter/material.dart';

enum AppButtonVariant { primary, secondary, saffron, ghost }

/// Accessible, tactile button component with spring-physics touch feedback.
class AppButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final String? semanticLabel;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.semanticLabel,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  bool get _isEnabled => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final effectiveSemanticLabel = widget.semanticLabel ?? widget.label;

    return Semantics(
      button: true,
      enabled: _isEnabled,
      label: widget.isLoading
          ? '$effectiveSemanticLabel, loading'
          : effectiveSemanticLabel,
      child: GestureDetector(
        onTapDown: _isEnabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: _isEnabled ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: _isEnabled ? widget.onPressed : null,
        child: AnimatedScale(
          scale: _isPressed ? 0.97 : 1.0,
          duration: AppMotion.fast,
          curve: AppMotion.springBounce,
          child: Container(
            constraints: BoxConstraints(
              minHeight: AppSpacing.minTouchTarget,
              minWidth: widget.isFullWidth
                  ? double.infinity
                  : AppSpacing.minTouchTarget,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.xl,
              vertical: AppSpacing.md,
            ),
            decoration: _buildDecoration(),
            child: widget.isFullWidth
                ? Center(child: _buildContent())
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [_buildContent()],
                  ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration() {
    if (!_isEnabled && !widget.isLoading) {
      return BoxDecoration(
        color: AppColors.surfaceBorder,
        borderRadius: AppRadii.roundedMd,
      );
    }

    switch (widget.variant) {
      case AppButtonVariant.primary:
        return BoxDecoration(
          color: AppColors.primary,
          borderRadius: AppRadii.roundedMd,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case AppButtonVariant.secondary:
        return BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppRadii.roundedMd,
          border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
        );
      case AppButtonVariant.saffron:
        return BoxDecoration(
          color: AppColors.saffron,
          borderRadius: AppRadii.roundedMd,
          boxShadow: [
            BoxShadow(
              color: AppColors.saffron.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        );
      case AppButtonVariant.ghost:
        return const BoxDecoration(color: Colors.transparent);
    }
  }

  Widget _buildContent() {
    if (widget.isLoading) {
      final spinnerColor =
          widget.variant == AppButtonVariant.primary ||
              widget.variant == AppButtonVariant.saffron
          ? AppColors.textInverted
          : AppColors.primary;

      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.2,
          valueColor: AlwaysStoppedAnimation<Color>(spinnerColor),
        ),
      );
    }

    final textColor = _getTextColor();
    final textStyle = AppTypography.labelLarge.copyWith(color: textColor);

    if (widget.icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.icon, size: 18, color: textColor),
          const SizedBox(width: AppSpacing.sm),
          Text(widget.label, style: textStyle),
        ],
      );
    }

    return Text(widget.label, style: textStyle);
  }

  Color _getTextColor() {
    if (!_isEnabled) return AppColors.textMuted;

    switch (widget.variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.saffron:
        return AppColors.textInverted;
      case AppButtonVariant.secondary:
        return AppColors.textPrimary;
      case AppButtonVariant.ghost:
        return AppColors.primary;
    }
  }
}
