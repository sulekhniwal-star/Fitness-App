import 'package:fitkarma/app/fitkarma_app.dart';
import 'package:fitkarma/core/config/app_config.dart';
import 'package:fitkarma/core/providers/core_providers.dart';
import 'package:fitkarma/core/routing/auth_nav_state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'FitKarma bootstrap launches into Onboarding when unauthenticated',
    (WidgetTester tester) async {
      final testConfig = AppConfig.fromMap({
        'APP_ENV': 'development',
        'SUPABASE_URL': 'https://test.supabase.co',
        'SUPABASE_ANON_KEY': 'test-anon-key',
      });

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(testConfig),
            authNavStatusProvider.overrideWith(
              (ref) => AuthNavStatus.unauthenticated,
            ),
          ],
          child: const FitKarmaApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('screen_onboarding')), findsOneWidget);
      expect(find.text("India's Private Health OS"), findsOneWidget);
    },
  );

  testWidgets('FitKarma routes to Dashboard when authenticated', (
    WidgetTester tester,
  ) async {
    final testConfig = AppConfig.fromMap({
      'APP_ENV': 'development',
      'SUPABASE_URL': 'https://test.supabase.co',
      'SUPABASE_ANON_KEY': 'test-anon-key',
    });

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(testConfig),
          authNavStatusProvider.overrideWith(
            (ref) => AuthNavStatus.authenticated,
          ),
        ],
        child: const FitKarmaApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('screen_dashboard')), findsOneWidget);
    expect(find.text('Daily Intelligence Package (DIP)'), findsOneWidget);
  });
}
