import 'package:fitkarma/shared/presentation/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Centralized typographic scale for FitKarma.
///
/// Designed with high font weights and deliberate contrast to ensure
/// strong legibility for older demographics and low-end mobile screens.
abstract final class AppTypography {
  static const TextTheme textTheme = TextTheme(
    displayLarge: display,
    headlineMedium: headline,
    titleLarge: titleLarge,
    titleMedium: titleMedium,
    bodyLarge: bodyLarge,
    bodyMedium: bodyMedium,
    bodySmall: bodySmall,
    labelLarge: labelLarge,
    labelSmall: labelSmall,
  );

  /// 32pt bold / 40 line height — Screen hero banners & milestone achievements
  static const TextStyle display = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
  );

  /// 24pt bold / 32 line height — Section headers, module titles
  static const TextStyle headline = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.33,
    letterSpacing: -0.25,
    color: AppColors.textPrimary,
  );

  /// 20pt semi-bold / 28 line height — Bento card primary titles
  static const TextStyle titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.4,
    color: AppColors.textPrimary,
  );

  /// 16pt semi-bold / 24 line height — Subheadings, list item titles
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  /// 16pt regular / 24 line height — Primary body copy
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  /// 14pt regular / 20 line height — Secondary body, explanatory notes
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    color: AppColors.textSecondary,
  );

  /// 12pt regular / 16 line height — Metadata, footnotes, helper text
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    color: AppColors.textMuted,
  );

  /// 14pt semi-bold / 20 line height — Buttons, interactive labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
  );

  /// 11pt medium / 14 line height — Chips, tags, badges
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.27,
    letterSpacing: 0.2,
    color: AppColors.textSecondary,
  );

  /// 28pt bold — Tabular figures for steps, calories, water, glucose
  static const TextStyle metricNumeral = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    letterSpacing: -0.5,
    color: AppColors.textPrimary,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// 14pt bold — Unit suffix beside metric numerals (e.g. "kcal", "steps")
  static const TextStyle metricUnit = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );
}
