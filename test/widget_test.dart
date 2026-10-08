import 'package:fitkarma/app/fitkarma_app.dart';
import 'package:fitkarma/core/config/app_config.dart';
import 'package:fitkarma/core/providers/core_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('FitKarma application bootstrap smoke test via Riverpod', (
    WidgetTester tester,
  ) async {
    final testConfig = AppConfig.fromMap({
      'APP_ENV': 'development',
      'SUPABASE_URL': 'https://test.supabase.co',
      'SUPABASE_ANON_KEY': 'test-anon-key',
    });

    // Build our app wrapped in ProviderScope and trigger a frame.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appConfigProvider.overrideWithValue(testConfig)],
        child: const FitKarmaApp(),
      ),
    );

    // Verify that the title and core tagline are rendered.
    expect(find.text('FitKarma'), findsOneWidget);
    expect(
      find.text("India's Intelligent Health Operating System"),
      findsOneWidget,
    );
  });
}
