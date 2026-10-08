import 'package:fitkarma/core/localization/app_locale.dart';
import 'package:fitkarma/core/localization/app_localizations.dart';
import 'package:fitkarma/core/localization/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State notifier managing the active user locale.
///
/// Updating this notifier dynamically updates the application UI
/// immediately without requiring an app restart.
class AppLocaleNotifier extends StateNotifier<Locale> {
  AppLocaleNotifier([super.initialLocale = const Locale('en')]);

  /// Changes the active locale to a specific [Locale].
  void setLocale(Locale newLocale) {
    if (state != newLocale) {
      state = newLocale;
    }
  }

  /// Sets the active locale using [AppSupportedLocale].
  void setSupportedLocale(AppSupportedLocale supported) {
    setLocale(supported.locale);
  }

  /// Toggles between primary languages (English <-> Hindi).
  void toggleEnglishHindi() {
    if (state.languageCode == 'en') {
      state = const Locale('hi');
    } else {
      state = const Locale('en');
    }
  }
}

/// Riverpod provider for the active application [Locale].
final appLocaleProvider = StateNotifierProvider<AppLocaleNotifier, Locale>((
  ref,
) {
  return AppLocaleNotifier();
}, name: 'appLocaleProvider');

/// Riverpod provider for active [AppStrings] resolving reactively with locale.
final appStringsProvider = Provider<AppStrings>((ref) {
  final locale = ref.watch(appLocaleProvider);
  return AppLocalizations.resolveStrings(locale);
}, name: 'appStringsProvider');
