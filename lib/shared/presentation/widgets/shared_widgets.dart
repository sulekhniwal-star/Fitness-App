import 'package:flutter/material.dart';

/// Placeholder / export index for shared presentation components.
///
/// Full design tokens and Bento primitives are implemented in Phase 1 (Tasks 009-012).
class FitKarmaSharedWidgets {
  const FitKarmaSharedWidgets._();

  /// Standard dark surface container for shared components.
  static Widget cardContainer({
    required Widget child,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161A22),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: child,
    );
  }
}
