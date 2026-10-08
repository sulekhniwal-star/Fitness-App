import 'package:fitkarma/core/config/app_config.dart';
import 'package:fitkarma/core/localization/localization.dart';
import 'package:fitkarma/core/providers/core_providers.dart';
import 'package:fitkarma/shared/presentation/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Extension on WidgetTester providing standardized FitKarma app scaffolding and Riverpod injection.
extension PumpApp on WidgetTester {
  /// Pumps [widget] wrapped in a [ProviderScope] with default or overridden providers.
  Future<void> pumpFitKarmaWidget(
    Widget widget, {
    List<Override> overrides = const [],
    Locale locale = const Locale('en'),
  }) async {
    final defaultConfig = AppConfig.fromMap({
      'APP_ENV': 'development',
      'SUPABASE_URL': 'https://test.supabase.co',
      'SUPABASE_ANON_KEY': 'test-anon-key',
    });

    await pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(defaultConfig),
          ...overrides,
        ],
        child: MaterialApp(
          theme: FitKarmaTheme.darkTheme,
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppSupportedLocale.supportedLocales,
          home: widget,
        ),
      ),
    );
  }
}
