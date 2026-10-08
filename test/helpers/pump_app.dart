import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Extension on WidgetTester providing standardized FitKarma app scaffolding.
extension PumpApp on WidgetTester {
  /// Pumps [widget] wrapped in a MaterialApp with dark theme baseline.
  Future<void> pumpFitKarmaWidget(Widget widget) async {
    await pumpWidget(
      MaterialApp(
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
    );
  }
}
