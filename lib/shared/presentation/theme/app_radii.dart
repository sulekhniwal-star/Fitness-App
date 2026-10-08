import 'package:flutter/material.dart';

/// Centralized border radii tokens for FitKarma.
abstract final class AppRadii {
  /// 6.0 dp — Tooltips, small badges
  static const double xs = 6.0;

  /// 10.0 dp — Compact chips, inner nested widgets
  static const double sm = 10.0;

  /// 16.0 dp — Standard Bento cards, input fields, action buttons
  static const double md = 16.0;

  /// 24.0 dp — Hero containers, bottom sheets, prominent cards
  static const double lg = 24.0;

  /// 999.0 dp — Circular avatars, pill buttons, filter chips
  static const double full = 999.0;

  // --- BorderRadius Presets ---
  static const BorderRadius roundedXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius roundedSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius roundedMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius roundedLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius roundedFull = BorderRadius.all(
    Radius.circular(full),
  );
}
