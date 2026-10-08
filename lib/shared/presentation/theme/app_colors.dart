import 'package:flutter/material.dart';

/// FitKarma centralized color palette.
///
/// Implements the high-contrast dark aesthetic (#0D0F12 primary dark)
/// specified in Brain/ui_spec.md and FitKarma Master Documentation v1.0.
abstract final class AppColors {
  // --- Background & Scaffold Surfaces ---
  /// Deep primary dark background: #0D0F12
  static const Color background = Color(0xFF0D0F12);

  /// Surface level 1 (Bento cards, containers): #161A22
  static const Color surface = Color(0xFF161A22);

  /// Surface level 2 (Modals, popups, elevated cards): #1F2430
  static const Color surfaceElevated = Color(0xFF1F2430);

  /// Surface level 3 (High-emphasis borders, active items): #2A3142
  static const Color surfaceBorder = Color(0xFF2A3142);

  // --- Glassmorphic Overlays & Highlights ---
  /// Translucent white overlay for glassmorphism
  static const Color glassFill = Color(0x14FFFFFF); // ~8% opacity white

  /// Translucent glass border highlight
  static const Color glassBorder = Color(0x24FFFFFF); // ~14% opacity white

  // --- Brand Accents & India-First Signals ---
  /// Core brand primary / Neon Mint (Vitality, steps, positive health signals): #00E599
  static const Color primary = Color(0xFF00E599);

  /// Primary teal accent (Hydration, recovery, secondary actions): #00BFA5
  static const Color primaryAccent = Color(0xFF00BFA5);

  /// Saffron Gold / Ayurveda / Metabolic / Fasting accent: #FF9933
  static const Color saffron = Color(0xFFFF9933);

  /// Saffron light glow
  static const Color saffronSubtle = Color(0x26FF9933);

  /// Electric Blue (AI diagnostics, deep sleep, tech insights): #38BDF8
  static const Color techBlue = Color(0xFF38BDF8);

  // --- Semantic Feedback States ---
  /// Positive success state
  static const Color success = Color(0xFF10B981);

  /// Warning / Notice state
  static const Color warning = Color(0xFFF59E0B);

  /// Error / Alert state: Crimson
  static const Color error = Color(0xFFEF4444);

  /// Subtle error background fill
  static const Color errorSubtle = Color(0x26EF4444);

  // --- High-Legibility Typography Colors ---
  /// Primary text: High-contrast white/slate (98% luminance)
  static const Color textPrimary = Color(0xFFF8FAFC);

  /// Secondary text: High-legibility slate 400
  static const Color textSecondary = Color(0xFF94A3B8);

  /// Muted / Disabled text: Slate 600
  static const Color textMuted = Color(0xFF64748B);

  /// Inverted text (for buttons on neon mint / bright surfaces)
  static const Color textInverted = Color(0xFF090B0E);

  // --- Gradients ---
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient saffronGradient = LinearGradient(
    colors: [Color(0xFFFF9F1C), saffron],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0x1FFFFFFF), Color(0x08FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
