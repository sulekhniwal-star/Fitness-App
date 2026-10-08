import 'package:fitkarma/core/config/app_config.dart';
import 'package:fitkarma/core/providers/core_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Extension on WidgetTester providing standardized FitKarma app scaffolding and Riverpod injection.
extension PumpApp on WidgetTester {
  /// Pumps [widget] wrapped in a [ProviderScope] with default or overridden providers.
  Future<void> pumpFitKarmaWidget(
    Widget widget, {
    List<Override> overrides = const [],
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
          theme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0D0F12),
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF00E599),
              surface: Color(0xFF161A22),
            ),
            useMaterial3: true,
          ),
          home: widget,
        ),
      ),
    );
  }
}
