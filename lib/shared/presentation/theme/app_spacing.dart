import 'package:flutter/material.dart';

/// Centralized spacing scale and layout metrics for FitKarma.
abstract final class AppSpacing {
  /// 2.0 dp
  static const double xxs = 2.0;

  /// 4.0 dp
  static const double xs = 4.0;

  /// 8.0 dp
  static const double sm = 8.0;

  /// 12.0 dp
  static const double md = 12.0;

  /// 16.0 dp
  static const double lg = 16.0;

  /// 24.0 dp
  static const double xl = 24.0;

  /// 32.0 dp
  static const double xxl = 32.0;

  /// 48.0 dp
  static const double xxxl = 48.0;

  /// Minimum accessible touch target size (48x48 dp) adhering to WCAG 2.1 / Material 3
  static const double minTouchTarget = 48.0;

  // --- Common Insets Presets ---
  static const EdgeInsets insetsXxs = EdgeInsets.all(xxs);
  static const EdgeInsets insetsXs = EdgeInsets.all(xs);
  static const EdgeInsets insetsSm = EdgeInsets.all(sm);
  static const EdgeInsets insetsMd = EdgeInsets.all(md);
  static const EdgeInsets insetsLg = EdgeInsets.all(lg);
  static const EdgeInsets insetsXl = EdgeInsets.all(xl);

  /// Standard horizontal screen gutter padding (16.0 dp)
  static const EdgeInsets screenPadding = EdgeInsets.symmetric(horizontal: lg);

  /// Card internal padding (16.0 dp)
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);

  /// Bento compact tile padding (12.0 dp)
  static const EdgeInsets bentoCompactPadding = EdgeInsets.all(md);
}
