import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/hive_service.dart';

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(_initialLocale());

  static Locale _initialLocale() {
    final languageCode =
        HiveService.getSetting<String>('language_code', defaultValue: 'en');
    return Locale(languageCode!);
  }

  Future<void> setLocale(Locale locale) async {
    state = locale;
    await HiveService.saveSetting('language_code', locale.languageCode);
  }

  void toggleLocale() {
    if (state.languageCode == 'en') {
      setLocale(const Locale('hi'));
    } else {
      setLocale(const Locale('en'));
    }
  }
}

final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});
