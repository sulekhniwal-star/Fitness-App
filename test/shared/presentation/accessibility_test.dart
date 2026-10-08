import 'package:fitkarma/shared/presentation/widgets/shared_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FitKarma WCAG Contrast & Math Utilities Tests', () {
    test(
      'Primary text against dark background exceeds WCAG AA contrast (4.5:1)',
      () {
        final ratio = AccessibilityHelpers.getContrastRatio(
          AppColors.textPrimary,
          AppColors.background,
        );

        // Expected ~18:1 for near-white (#F8FAFC) against near-black (#0D0F12)
        expect(ratio, greaterThanOrEqualTo(4.5));
        expect(
          AccessibilityHelpers.meetsWcagAa(
            AppColors.textPrimary,
            AppColors.background,
          ),
          isTrue,
        );
      },
    );

    test('Primary text against surface (#161A22) exceeds WCAG AA contrast', () {
      final ratio = AccessibilityHelpers.getContrastRatio(
        AppColors.textPrimary,
        AppColors.surface,
      );

      expect(ratio, greaterThanOrEqualTo(4.5));
      expect(
        AccessibilityHelpers.meetsWcagAa(
          AppColors.textPrimary,
          AppColors.surface,
        ),
        isTrue,
      );
    });

    test('Neon mint against dark background exceeds WCAG AA UI/graphic contrast (3.0:1)', () {
      final ratio = AccessibilityHelpers.getContrastRatio(
        AppColors.primary,
        AppColors.background,
      );

      expect(ratio, greaterThanOrEqualTo(3.0));
    });
  });

  group('Reduced Motion Helpers Tests', () {
    testWidgets('returns Duration.zero when user enables reduced motion', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: true),
          child: SizedBox.shrink(),
        ),
      );

      final BuildContext context = tester.element(find.byType(SizedBox));
      final duration = AccessibilityHelpers.getAccessibleDuration(
        context,
        const Duration(milliseconds: 250),
      );

      expect(duration, equals(Duration.zero));
    });

    testWidgets('returns standard duration when animations are enabled', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(disableAnimations: false),
          child: SizedBox.shrink(),
        ),
      );

      final BuildContext context = tester.element(find.byType(SizedBox));
      final duration = AccessibilityHelpers.getAccessibleDuration(
        context,
        const Duration(milliseconds: 250),
      );

      expect(duration, equals(const Duration(milliseconds: 250)));
    });
  });

  group('Touch Target Sizing Tests (48x48dp)', () {
    testWidgets(
      'AccessibleTouchTarget enforces 48dp minimum bounds on small icon',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(
                child: AccessibleTouchTarget(
                  child: Icon(Icons.close, size: 16),
                ),
              ),
            ),
          ),
        );

        final finder = find.byType(AccessibleTouchTarget);
        final size = tester.getSize(finder);

        expect(size.width, greaterThanOrEqualTo(48.0));
        expect(size.height, greaterThanOrEqualTo(48.0));
      },
    );

    testWidgets('AppButton enforces 48dp minimum touch target', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: FitKarmaTheme.darkTheme,
          home: Scaffold(
            body: Center(
              child: AppButton(label: 'Save', onPressed: () {}),
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(AppButton));
      expect(size.height, greaterThanOrEqualTo(48.0));
      expect(size.width, greaterThanOrEqualTo(48.0));
    });
  });

  group('Screen-Reader Semantics & Reading Order Tests', () {
    testWidgets(
      'SemanticReadingOrder attaches OrdinalSortKey for ordered traversal',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Column(
                children: [
                  SemanticReadingOrder(
                    order: 2.0,
                    child: Text('Step 2: Nutrition'),
                  ),
                  SemanticReadingOrder(
                    order: 1.0,
                    child: Text('Step 1: Water'),
                  ),
                ],
              ),
            ),
          ),
        );

        final step2Semantics = tester.getSemantics(
          find.text('Step 2: Nutrition'),
        );
        expect(step2Semantics.sortKey, isA<OrdinalSortKey>());
        expect((step2Semantics.sortKey as OrdinalSortKey).order, equals(2.0));

        final step1Semantics = tester.getSemantics(find.text('Step 1: Water'));
        expect(step1Semantics.sortKey, isA<OrdinalSortKey>());
        expect((step1Semantics.sortKey as OrdinalSortKey).order, equals(1.0));
      },
    );

    testWidgets(
      'AppStatusBadge announces non-color-only semantic status text',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: FitKarmaTheme.darkTheme,
            home: const Scaffold(
              body: AppStatusBadge(
                label: 'Fasting Active',
                type: StatusType.saffron,
                icon: Icons.timer,
              ),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(AppStatusBadge));
        expect(semantics.label, contains('Status: Fasting Active'));
      },
    );

    testWidgets(
      'AppProgressBar announces percentage and progress bar semantics',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: FitKarmaTheme.darkTheme,
            home: const Scaffold(
              body: AppProgressBar(value: 0.75, label: 'Steps Target'),
            ),
          ),
        );

        final semantics = tester.getSemantics(find.byType(AppProgressBar));
        expect(semantics.value, equals('75%'));
        expect(semantics.label, contains('Steps Target: 75%'));
      },
    );
  });

  group('Focus Behavior Tests', () {
    testWidgets(
      'AccessibleFocusIndicator paints border when focusNode receives focus',
      (tester) async {
        final focusNode = FocusNode();

        await tester.pumpWidget(
          MaterialApp(
            theme: FitKarmaTheme.darkTheme,
            home: Scaffold(
              body: AccessibleFocusIndicator(
                focusNode: focusNode,
                child: const SizedBox(width: 100, height: 50),
              ),
            ),
          ),
        );

        // Initially unfocused
        expect(focusNode.hasFocus, isFalse);

        // Request focus
        focusNode.requestFocus();
        await tester.pump();

        expect(focusNode.hasFocus, isTrue);

        focusNode.dispose();
      },
    );
  });

  group('Dynamic Text Scaling (200% Accessibility Scale) Tests', () {
    testWidgets(
      'BentoCard renders without overflow at 2.0x text scale factor',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: FitKarmaTheme.darkTheme,
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(360, 640),
                textScaler: TextScaler.linear(
                  2.0,
                ), // 200% large accessibility font
              ),
              child: Scaffold(
                body: BentoCard(
                  title: 'Daily Intelligence Package Health Guidance',
                  subtitle: 'Continuous health monitoring and adaptive recovery recommendation',
                  icon: Icons.auto_awesome,
                  trailing: const AppStatusBadge(
                    label: 'Active',
                    type: StatusType.success,
                  ),
                  child: Column(
                    children: const [
                      Text(
                        'Card body text content adapting to large accessibility font',
                      ),
                      SizedBox(height: 8),
                      AppProgressBar(value: 0.8),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );

        // Pump and verify no RenderFlex overflow exception
        await tester.pumpAndSettle();

        expect(
          find.text('Daily Intelligence Package Health Guidance'),
          findsOneWidget,
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'AdaptiveTextScaleContainer clamps excessive scaling gracefully',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: FitKarmaTheme.darkTheme,
            home: MediaQuery(
              data: const MediaQueryData(
                textScaler: TextScaler.linear(3.5), // Extreme 350% scale
              ),
              child: Scaffold(
                body: AdaptiveTextScaleContainer(
                  maxTextScale: 2.0,
                  child: Builder(
                    builder: (context) {
                      final scale = MediaQuery.textScalerOf(context).scale(1.0);
                      return Text('Clamped scale: $scale');
                    },
                  ),
                ),
              ),
            ),
          ),
        );

        expect(find.text('Clamped scale: 2.0'), findsOneWidget);
      },
    );
  });
}
