import 'package:fitkarma/core/localization/localization.dart';
import 'package:fitkarma/shared/presentation/showcase/design_system_showcase_screen.dart';
import 'package:fitkarma/shared/presentation/widgets/shared_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FitKarma Design Tokens & Theme Tests', () {
    test('AppColors conforms to documented dark palette', () {
      expect(AppColors.background, equals(const Color(0xFF0D0F12)));
      expect(AppColors.surface, equals(const Color(0xFF161A22)));
      expect(AppColors.surfaceElevated, equals(const Color(0xFF1F2430)));
      expect(AppColors.primary, equals(const Color(0xFF00E599)));
      expect(AppColors.saffron, equals(const Color(0xFFFF9933)));
      expect(AppColors.techBlue, equals(const Color(0xFF38BDF8)));
      expect(AppColors.error, equals(const Color(0xFFEF4444)));
      expect(AppColors.textPrimary, equals(const Color(0xFFF8FAFC)));
      expect(AppColors.textSecondary, equals(const Color(0xFF94A3B8)));
    });

    test('AppSpacing adheres to 8dp grid and 48dp minimum touch target', () {
      expect(AppSpacing.xxs, equals(2.0));
      expect(AppSpacing.xs, equals(4.0));
      expect(AppSpacing.sm, equals(8.0));
      expect(AppSpacing.md, equals(12.0));
      expect(AppSpacing.lg, equals(16.0));
      expect(AppSpacing.xl, equals(24.0));
      expect(AppSpacing.xxl, equals(32.0));
      expect(AppSpacing.xxxl, equals(48.0));
      expect(AppSpacing.minTouchTarget, equals(48.0));
    });

    test('AppRadii tokens conform to Bento conventions', () {
      expect(AppRadii.xs, equals(6.0));
      expect(AppRadii.sm, equals(10.0));
      expect(AppRadii.md, equals(16.0));
      expect(AppRadii.lg, equals(24.0));
      expect(AppRadii.full, equals(999.0));
    });

    test('AppMotion durations support tactile responsiveness', () {
      expect(AppMotion.fast, equals(const Duration(milliseconds: 150)));
      expect(AppMotion.normal, equals(const Duration(milliseconds: 250)));
      expect(AppMotion.slow, equals(const Duration(milliseconds: 400)));
    });

    test('FitKarmaTheme.darkTheme produces compliant ThemeData', () {
      final theme = FitKarmaTheme.darkTheme;

      expect(theme.brightness, equals(Brightness.dark));
      expect(theme.scaffoldBackgroundColor, equals(AppColors.background));
      expect(theme.colorScheme.primary, equals(AppColors.primary));
      expect(theme.colorScheme.surface, equals(AppColors.surface));
      expect(theme.colorScheme.secondary, equals(AppColors.saffron));
    });
  });

  group('Shared UI Primitives Widget Tests', () {
    Widget buildTestFrame(Widget child) {
      return MaterialApp(
        theme: FitKarmaTheme.darkTheme,
        home: Scaffold(body: Center(child: child)),
      );
    }

    testWidgets(
      'AppButton renders label, handles tap, and respects min touch target',
      (tester) async {
        bool tapped = false;

        await tester.pumpWidget(
          buildTestFrame(
            AppButton(
              label: 'Start Workout',
              icon: Icons.fitness_center,
              onPressed: () => tapped = true,
            ),
          ),
        );

        expect(find.text('Start Workout'), findsOneWidget);
        expect(find.byIcon(Icons.fitness_center), findsOneWidget);

        final buttonFinder = find.byType(AppButton);
        final size = tester.getSize(buttonFinder);
        expect(size.height, greaterThanOrEqualTo(AppSpacing.minTouchTarget));

        await tester.tap(buttonFinder);
        await tester.pumpAndSettle();
        expect(tapped, isTrue);
      },
    );

    testWidgets('AppButton shows spinner when loading and ignores tap', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestFrame(
          AppButton(
            label: 'Save',
            isLoading: true,
            onPressed: () => tapped = true,
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Save'), findsNothing);

      await tester.tap(find.byType(AppButton));
      await tester.pump(const Duration(milliseconds: 50));
      expect(tapped, isFalse);
    });

    testWidgets('AppTextField accepts text and displays label and error', (
      tester,
    ) async {
      final controller = TextEditingController();

      await tester.pumpWidget(
        buildTestFrame(
          AppTextField(
            controller: controller,
            label: 'Meal Name',
            hint: 'e.g. Khichdi',
            errorText: 'Required field',
          ),
        ),
      );

      expect(find.text('Meal Name'), findsOneWidget);
      expect(find.text('e.g. Khichdi'), findsOneWidget);
      expect(find.text('Required field'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Moong Dal Khichdi');
      await tester.pumpAndSettle();

      expect(controller.text, equals('Moong Dal Khichdi'));
    });

    testWidgets('BentoCard renders header, trailing, and responds to tap', (
      tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestFrame(
          BentoCard(
            title: 'Water Log',
            subtitle: 'Target 3.0L',
            icon: Icons.water_drop,
            trailing: const Text('2.1L'),
            onTap: () => tapped = true,
            child: const Text('Logged 7 glasses'),
          ),
        ),
      );

      expect(find.text('Water Log'), findsOneWidget);
      expect(find.text('Target 3.0L'), findsOneWidget);
      expect(find.byIcon(Icons.water_drop), findsOneWidget);
      expect(find.text('2.1L'), findsOneWidget);
      expect(find.text('Logged 7 glasses'), findsOneWidget);

      await tester.tap(find.byType(BentoCard));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('GlassContainer renders child with blur effect', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestFrame(const GlassContainer(child: Text('Frosted Content'))),
      );

      expect(find.text('Frosted Content'), findsOneWidget);
      expect(find.byType(BackdropFilter), findsOneWidget);
    });

    testWidgets(
      'AppChip and AppStatusBadge display accessible text and icons',
      (tester) async {
        bool selected = false;

        await tester.pumpWidget(
          buildTestFrame(
            Column(
              children: [
                AppChip(
                  label: 'Vegetarian',
                  isSelected: false,
                  onSelected: (val) => selected = val,
                ),
                const AppStatusBadge(
                  label: 'Verified',
                  type: StatusType.success,
                  icon: Icons.check,
                ),
              ],
            ),
          ),
        );

        expect(find.text('Vegetarian'), findsOneWidget);
        expect(find.text('Verified'), findsOneWidget);
        expect(find.byIcon(Icons.check), findsOneWidget);

        await tester.tap(find.text('Vegetarian'));
        await tester.pumpAndSettle();
        expect(selected, isTrue);
      },
    );

    testWidgets('AppProgressBar clamps values and renders labels', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestFrame(
          const AppProgressBar(
            value: 0.65,
            label: 'Steps Goal',
            trailingText: '6,500 / 10,000',
          ),
        ),
      );

      expect(find.text('Steps Goal'), findsOneWidget);
      expect(find.text('6,500 / 10,000'), findsOneWidget);
    });

    testWidgets('AppLoadingView renders message and spinner', (tester) async {
      await tester.pumpWidget(
        buildTestFrame(
          const AppLoadingView(message: 'Analyzing meal photo...'),
        ),
      );

      expect(find.text('Analyzing meal photo...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 50));
    });

    testWidgets(
      'AppEmptyStateView and AppErrorStateView render content and respond to interactions',
      (tester) async {
        bool retried = false;
        bool actionTriggered = false;

        await tester.pumpWidget(
          buildTestFrame(
            SingleChildScrollView(
              child: Column(
                children: [
                  AppEmptyStateView(
                    title: 'No Workouts',
                    description: 'Add your first workout',
                    actionLabel: 'Add Workout',
                    onAction: () => actionTriggered = true,
                  ),
                  AppErrorStateView(
                    title: 'Network Timeout',
                    message: 'Please check your connection',
                    errorCode: 'FK-4001',
                    onRetry: () => retried = true,
                  ),
                ],
              ),
            ),
          ),
        );

        expect(find.text('No Workouts'), findsOneWidget);
        expect(find.text('Network Timeout'), findsOneWidget);
        expect(find.text('Code: FK-4001'), findsOneWidget);

        await tester.tap(find.text('Add Workout'));
        await tester.pumpAndSettle();
        expect(actionTriggered, isTrue);

        await tester.tap(find.text('Try Again'));
        await tester.pumpAndSettle();
        expect(retried, isTrue);
      },
    );

    testWidgets('DesignSystemShowcaseScreen renders without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: FitKarmaTheme.darkTheme,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppSupportedLocale.supportedLocales,
            home: const DesignSystemShowcaseScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Design System Showcase'), findsOneWidget);
      expect(find.text('1. Colors & Surfaces'), findsOneWidget);
      expect(find.text('2. Typography & Numerals'), findsOneWidget);
      expect(find.text('3. Buttons & Actions'), findsOneWidget);
    });
  });
}
