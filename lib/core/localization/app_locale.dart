import 'package:flutter/material.dart';

/// Enumeration of supported and prepared Indian languages in FitKarma.
///
/// Phase 1 baseline active: English and Hindi.
/// Prepared for Phase 2/expansion: Tamil, Telugu, Gujarati, Bengali, Marathi, Punjabi.
enum AppSupportedLocale {
  english(
    languageCode: 'en',
    displayName: 'English',
    nativeName: 'English',
    isFullyLocalized: true,
  ),
  hindi(
    languageCode: 'hi',
    displayName: 'Hindi',
    nativeName: 'हिन्दी',
    isFullyLocalized: true,
  ),
  tamil(
    languageCode: 'ta',
    displayName: 'Tamil',
    nativeName: 'தமிழ்',
    isFullyLocalized: false,
  ),
  telugu(
    languageCode: 'te',
    displayName: 'Telugu',
    nativeName: 'తెలుగు',
    isFullyLocalized: false,
  ),
  gujarati(
    languageCode: 'gu',
    displayName: 'Gujarati',
    nativeName: 'ગુજરાતી',
    isFullyLocalized: false,
  ),
  bengali(
    languageCode: 'bn',
    displayName: 'Bengali',
    nativeName: 'বাংলা',
    isFullyLocalized: false,
  ),
  marathi(
    languageCode: 'mr',
    displayName: 'Marathi',
    nativeName: 'मराठी',
    isFullyLocalized: false,
  ),
  punjabi(
    languageCode: 'pa',
    displayName: 'Punjabi',
    nativeName: 'ਪੰਜਾਬੀ',
    isFullyLocalized: false,
  );

  final String languageCode;
  final String displayName;
  final String nativeName;
  final bool isFullyLocalized;

  const AppSupportedLocale({
    required this.languageCode,
    required this.displayName,
    required this.nativeName,
    required this.isFullyLocalized,
  });

  Locale get locale => Locale(languageCode);

  /// Resolves an [AppSupportedLocale] from a language code string.
  /// Defaults safely to English if unrecognized.
  static AppSupportedLocale fromCode(String? code) {
    if (code == null) return AppSupportedLocale.english;
    final normalized = code.toLowerCase().trim();
    for (final supported in AppSupportedLocale.values) {
      if (supported.languageCode == normalized) {
        return supported;
      }
    }
    return AppSupportedLocale.english;
  }

  /// List of Flutter [Locale] instances supported by the app.
  static List<Locale> get supportedLocales =>
      AppSupportedLocale.values.map((e) => e.locale).toList();
}
