import 'package:fitkarma/app/fitkarma_app.dart';
import 'package:fitkarma/core/config/app_config.dart';
import 'package:fitkarma/core/providers/core_providers.dart';
import 'package:fitkarma/core/routing/app_router.dart';
import 'package:fitkarma/core/routing/app_routes.dart';
import 'package:fitkarma/core/routing/auth_nav_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppRouter Navigation & Auth Boundary Tests', () {
    final testConfig = AppConfig.fromMap({
      'APP_ENV': 'development',
      'SUPABASE_URL': 'https://test.supabase.co',
      'SUPABASE_ANON_KEY': 'test-anon-key',
    });

    Widget createTestApp({
      required AuthNavStatus authStatus,
      String? initialLocation,
    }) {
      return ProviderScope(
        overrides: [
          appConfigProvider.overrideWithValue(testConfig),
          authNavStatusProvider.overrideWith((ref) => authStatus),
        ],
        child: const FitKarmaApp(),
      );
    }

    testWidgets(
      'unauthenticated user is guarded and redirected to onboarding',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestApp(authStatus: AuthNavStatus.unauthenticated),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('screen_onboarding')), findsOneWidget);
      },
    );

    testWidgets(
      'authenticated user is redirected from onboarding to dashboard',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          createTestApp(authStatus: AuthNavStatus.authenticated),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const Key('screen_dashboard')), findsOneWidget);
      },
    );

    testWidgets(
      'authenticated user can navigate to each major top-level product area',
      (WidgetTester tester) async {
        late ProviderContainer container;

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appConfigProvider.overrideWithValue(testConfig),
              authNavStatusProvider.overrideWith(
                (ref) => AuthNavStatus.authenticated,
              ),
            ],
            child: Consumer(
              builder: (context, ref, child) {
                container = ProviderScope.containerOf(context);
                return const FitKarmaApp();
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        final router = container.read(appRouterProvider);

        // Verify Dashboard
        expect(find.byKey(const Key('screen_dashboard')), findsOneWidget);

        // Verify Nutrition
        router.go(AppRoutes.nutrition);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('screen_nutrition')), findsOneWidget);

        // Verify Nutrition Log sub-route
        router.go(AppRoutes.nutritionLog);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('screen_nutrition_log')), findsOneWidget);

        // Verify Workouts
        router.go(AppRoutes.workouts);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('screen_workouts')), findsOneWidget);

        // Verify Sleep
        router.go(AppRoutes.sleep);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('screen_sleep')), findsOneWidget);

        // Verify Recovery
        router.go(AppRoutes.recovery);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('screen_recovery')), findsOneWidget);

        // Verify AI
        router.go(AppRoutes.aiMealAnalyze);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('screen_ai')), findsOneWidget);

        // Verify Family
        router.go(AppRoutes.family);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('screen_family')), findsOneWidget);

        // Verify Subscriptions
        router.go(AppRoutes.subscriptions);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('screen_subscriptions')), findsOneWidget);

        // Verify Settings
        router.go(AppRoutes.settings);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('screen_settings')), findsOneWidget);

        // Verify Data Vault
        router.go(AppRoutes.dataVault);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('screen_data_vault')), findsOneWidget);
      },
    );
  });
}
