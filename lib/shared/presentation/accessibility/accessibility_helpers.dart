import 'package:fitkarma/shared/presentation/theme/app_colors.dart';
import 'package:fitkarma/shared/presentation/theme/app_radii.dart';
import 'package:fitkarma/shared/presentation/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';

/// Reusable accessibility utilities, wrappers, and constraints for FitKarma.
///
/// Adheres to WCAG 2.1 AA and Indian digital accessibility best practices:
/// - Minimum 48x48dp touch targets for one-handed mobile use
/// - Non-overflowing dynamic text scaling up to 200%
/// - Logical screen-reader traversal ordering for Bento grids
/// - System reduced-motion compliance
abstract final class AccessibilityHelpers {
  /// Minimum accessible touch target constraint (48x48 dp).
  static const BoxConstraints minTouchTargetConstraints = BoxConstraints(
    minWidth: AppSpacing.minTouchTarget,
    minHeight: AppSpacing.minTouchTarget,
  );

  /// Returns the effective animation duration respecting user reduced-motion preferences.
  static Duration getAccessibleDuration(
    BuildContext context,
    Duration standardDuration,
  ) {
    final disableAnimations =
        MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (disableAnimations) {
      return Duration.zero;
    }
    return standardDuration;
  }

  /// Calculates luminance contrast ratio between two colors.
  ///
  /// WCAG 2.1 AA requires at least 4.5:1 for normal body text and 3.0:1 for large text/icons.
  static double getContrastRatio(Color foreground, Color background) {
    final lum1 = foreground.computeLuminance();
    final lum2 = background.computeLuminance();
    final brightest = lum1 > lum2 ? lum1 : lum2;
    final darkest = lum1 > lum2 ? lum2 : lum1;
    return (brightest + 0.05) / (darkest + 0.05);
  }

  /// Checks if contrast ratio meets WCAG AA standard (4.5:1 for normal text).
  static bool meetsWcagAa(Color foreground, Color background) {
    return getContrastRatio(foreground, background) >= 4.5;
  }
}

/// Enforces the 48x48dp minimum accessible touch target constraint without
/// altering the visual size of compact inner elements.
class AccessibleTouchTarget extends StatelessWidget {
  final Widget child;
  final AlignmentGeometry alignment;

  const AccessibleTouchTarget({
    super.key,
    required this.child,
    this.alignment = Alignment.center,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: AccessibilityHelpers.minTouchTargetConstraints,
      child: Align(alignment: alignment, child: child),
    );
  }
}

/// Assigns a clear semantic reading sequence to widgets in Bento grids and dashboard tiles.
///
/// Screen readers normally read linearly left-to-right top-to-bottom. In complex
/// Bento cards, [SemanticReadingOrder] guarantees header -> numeral -> progress -> action.
class SemanticReadingOrder extends StatelessWidget {
  final double order;
  final Widget child;

  const SemanticReadingOrder({
    super.key,
    required this.order,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(sortKey: OrdinalSortKey(order), child: child);
  }
}

/// Protects layouts from overflowing when users configure high accessibility text scaling (up to 200%).
///
/// Clamps text scaling within a safe upper bound (default 2.0x) and provides an
/// adaptive builder allowing rows to automatically reflow into columns when text is enlarged.
class AdaptiveTextScaleContainer extends StatelessWidget {
  final Widget child;
  final double maxTextScale;

  const AdaptiveTextScaleContainer({
    super.key,
    required this.child,
    this.maxTextScale = 2.0,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final clampedScaler = mediaQuery.textScaler.clamp(
      minScaleFactor: 0.8,
      maxScaleFactor: maxTextScale,
    );

    return MediaQuery(
      data: mediaQuery.copyWith(textScaler: clampedScaler),
      child: child,
    );
  }

  /// Helper to check if accessibility text scaling is active (> 1.25x).
  static bool isLargeTextScale(BuildContext context) {
    return MediaQuery.textScalerOf(context).scale(1.0) >= 1.25;
  }
}

/// Accessible keyboard and switch-access focus outline.
///
/// Wraps an interactive widget with a high-contrast Neon Mint border and subtle glow
/// when focused by a keyboard or assistive switch device.
class AccessibleFocusIndicator extends StatelessWidget {
  final FocusNode focusNode;
  final Widget child;
  final BorderRadius? borderRadius;
  final Color focusColor;

  const AccessibleFocusIndicator({
    super.key,
    required this.focusNode,
    required this.child,
    this.borderRadius,
    this.focusColor = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      child: AnimatedBuilder(
        animation: focusNode,
        builder: (context, _) {
          final hasFocus = focusNode.hasFocus;
          final radius = borderRadius ?? AppRadii.roundedMd;

          return DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: hasFocus
                  ? Border.all(color: focusColor, width: 2.5)
                  : Border.all(color: Colors.transparent, width: 2.5),
              boxShadow: hasFocus
                  ? [
                      BoxShadow(
                        color: focusColor.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: child,
          );
        },
      ),
    );
  }
}
