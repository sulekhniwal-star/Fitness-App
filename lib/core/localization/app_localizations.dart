import 'package:fitkarma/core/localization/app_locale.dart';
import 'package:fitkarma/core/localization/app_strings.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Central localization entry point and delegate for FitKarma.
///
/// Implements deterministic fallback to English strings when a requested
/// translation or locale is missing or partially implemented.
class AppLocalizations {
  final Locale locale;
  final AppStrings strings;

  const AppLocalizations(this.locale, this.strings);

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// Retrieves the active [AppLocalizations] from the widget tree.
  ///
  /// Falls back safely to English defaults if no localization is found in scope.
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        const AppLocalizations(Locale('en'), EnglishStrings());
  }

  /// Resolves the string catalog for a given locale with fallback to English.
  static AppStrings resolveStrings(Locale locale) {
    switch (locale.languageCode.toLowerCase()) {
      case 'hi':
        return const HindiStrings();
      case 'en':
      default:
        // Safe deterministic fallback for missing or expansion locales (ta, te, gu, bn, mr, pa)
        return const EnglishStrings();
    }
  }

  /// Convenience shortcut to access strings directly.
  static AppStrings stringsOf(BuildContext context) => of(context).strings;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppSupportedLocale.values.any(
      (supported) => supported.languageCode == locale.languageCode,
    );
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    final strings = AppLocalizations.resolveStrings(locale);
    return SynchronousFuture<AppLocalizations>(
      AppLocalizations(locale, strings),
    );
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
