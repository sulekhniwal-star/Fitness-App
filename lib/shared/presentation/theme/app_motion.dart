import 'package:flutter/material.dart';

/// Centralized animation durations and spring-physics curves for FitKarma.
///
/// Implements responsive tactile feedback without excessive visual latency.
abstract final class AppMotion {
  /// 150 ms — Micro-animations, button press scale feedback, chip toggles
  static const Duration fast = Duration(milliseconds: 150);

  /// 250 ms — Standard UI transitions, card expansions, progress fills
  static const Duration normal = Duration(milliseconds: 250);

  /// 400 ms — Modal entries, bottom sheet reveals, screen transitions
  static const Duration slow = Duration(milliseconds: 400);

  // --- Animation Curves ---
  /// Smooth natural deceleration
  static const Curve easeOut = Curves.easeOutCubic;

  /// Smooth bidirectional transition
  static const Curve easeInOut = Curves.easeInOutCubic;

  /// Subtle elastic bounce for interactive taps
  static const Curve springBounce = Curves.easeOutBack;
}
