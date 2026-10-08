import 'package:fitkarma/core/localization/localization.dart';
import 'package:fitkarma/shared/presentation/widgets/shared_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestFrame(Widget child) {
    return ProviderScope(
      child: MaterialApp(
        theme: FitKarmaTheme.darkTheme,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppSupportedLocale.supportedLocales,
        home: Scaffold(body: child),
      ),
    );
  }

  group('AppScaffold & OfflineIndicatorBanner Tests', () {
    testWidgets('AppScaffold displays offline banner when isOffline is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestFrame(
          AppScaffold(isOffline: true, body: const Text('Scaffold Content')),
        ),
      );

      expect(find.text('Scaffold Content'), findsOneWidget);
      expect(find.byType(OfflineIndicatorBanner), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
      expect(find.textContaining('safely preserved offline'), findsOneWidget);
    });

    testWidgets('OfflineIndicatorBanner triggers retry callback', (
      tester,
    ) async {
      bool retried = false;

      await tester.pumpWidget(
        buildTestFrame(
          OfflineIndicatorBanner(
            isOffline: true,
            onRetry: () => retried = true,
          ),
        ),
      );

      await tester.tap(find.text('Try Again'));
      await tester.pumpAndSettle();

      expect(retried, isTrue);
    });

    testWidgets('OfflineIndicatorBanner hides when isOffline is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestFrame(const OfflineIndicatorBanner(isOffline: false)),
      );

      expect(find.byIcon(Icons.cloud_off), findsNothing);
    });
  });

  group('AppTopBar Tests', () {
    testWidgets('AppTopBar renders title, subtitle, and actions', (
      tester,
    ) async {
      bool actionTapped = false;

      await tester.pumpWidget(
        buildTestFrame(
          AppTopBar(
            title: 'Daily Nutrition',
            subtitle: 'Logged 1,850 kcal today',
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_today),
                onPressed: () => actionTapped = true,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Daily Nutrition'), findsOneWidget);
      expect(find.text('Logged 1,850 kcal today'), findsOneWidget);
      expect(find.byIcon(Icons.calendar_today), findsOneWidget);

      await tester.tap(find.byIcon(Icons.calendar_today));
      await tester.pumpAndSettle();
      expect(actionTapped, isTrue);
    });
  });

  group('AppBottomNavBar Tests', () {
    testWidgets('renders all tabs and responds to selection', (tester) async {
      int selectedIndex = 0;

      await tester.pumpWidget(
        buildTestFrame(
          StatefulBuilder(
            builder: (context, setState) {
              return AppBottomNavBar(
                currentIndex: selectedIndex,
                onTabSelected: (idx) => setState(() => selectedIndex = idx),
                tabs: const [
                  BottomNavTab(label: 'Home', icon: Icons.home),
                  BottomNavTab(label: 'Nutrition', icon: Icons.restaurant),
                  BottomNavTab(label: 'Workouts', icon: Icons.fitness_center),
                  BottomNavTab(label: 'Profile', icon: Icons.person),
                ],
              );
            },
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Nutrition'), findsOneWidget);
      expect(find.text('Workouts'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Tap on Nutrition
      await tester.tap(find.text('Nutrition'));
      await tester.pumpAndSettle();

      expect(selectedIndex, equals(1));
    });
  });

  group('AppSectionHeader Tests', () {
    testWidgets('renders title, subtitle, and action link', (tester) async {
      bool actionClicked = false;

      await tester.pumpWidget(
        buildTestFrame(
          AppSectionHeader(
            title: "Today's Meals",
            subtitle: 'Macro distribution',
            actionLabel: 'See All',
            actionIcon: Icons.arrow_forward_ios,
            onAction: () => actionClicked = true,
          ),
        ),
      );

      expect(find.text("Today's Meals"), findsOneWidget);
      expect(find.text('Macro distribution'), findsOneWidget);
      expect(find.text('See All'), findsOneWidget);

      await tester.tap(find.text('See All'));
      await tester.pumpAndSettle();
      expect(actionClicked, isTrue);
    });
  });

  group('MetricCard Tests', () {
    testWidgets(
      'renders health signal with tabular numerals, progress, and badge',
      (tester) async {
        bool cardTapped = false;

        await tester.pumpWidget(
          buildTestFrame(
            MetricCard(
              title: 'Daily Steps',
              value: '8,450',
              unit: 'steps',
              icon: Icons.directions_walk,
              progress: 0.845,
              goalText: '8,450 / 10,000',
              trendText: '+15%',
              trendStatus: StatusType.success,
              onTap: () => cardTapped = true,
            ),
          ),
        );

        expect(find.text('Daily Steps'), findsOneWidget);
        expect(find.text('8,450'), findsOneWidget);
        expect(find.text('steps'), findsOneWidget);
        expect(find.text('+15%'), findsOneWidget);
        expect(find.byType(AppProgressBar), findsOneWidget);

        await tester.tap(find.byType(MetricCard));
        await tester.pumpAndSettle();
        expect(cardTapped, isTrue);
      },
    );
  });

  group('SkeletonLoader Tests', () {
    testWidgets('renders SkeletonLine and SkeletonCard without error', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestFrame(
          Column(
            children: const [
              SkeletonLine(width: 150),
              SizedBox(height: 16),
              SkeletonCard(),
            ],
          ),
        ),
      );

      expect(find.byType(SkeletonLine), findsWidgets);
      expect(find.byType(SkeletonCard), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 100));
    });
  });

  group('AppSnackBar Toast Tests', () {
    testWidgets('displays floating toast with action button', (tester) async {
      bool actionClicked = false;

      await tester.pumpWidget(
        buildTestFrame(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () {
                  AppSnackBar.show(
                    context,
                    message: 'Meal saved to outbox',
                    type: SnackBarType.success,
                    actionLabel: 'UNDO',
                    onAction: () => actionClicked = true,
                  );
                },
                child: const Text('Show Toast'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Show Toast'));
      await tester.pumpAndSettle();

      expect(find.text('Meal saved to outbox'), findsOneWidget);
      expect(find.text('UNDO'), findsOneWidget);

      await tester.tap(find.text('UNDO'));
      await tester.pumpAndSettle();

      expect(actionClicked, isTrue);
    });
  });

  group('AppConfirmationDialog & AppConsentDialog Tests', () {
    testWidgets('AppConfirmationDialog confirms action and returns true', (
      tester,
    ) async {
      bool? result;

      await tester.pumpWidget(
        buildTestFrame(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  result = await AppConfirmationDialog.show(
                    context,
                    title: 'Delete Meal Entry',
                    message: 'Are you sure you want to delete this meal log?',
                    isDestructive: true,
                  );
                },
                child: const Text('Open Confirm'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open Confirm'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Meal Entry'), findsOneWidget);
      expect(
        find.text('Are you sure you want to delete this meal log?'),
        findsOneWidget,
      );

      // Tap confirm button (delete in destructive mode)
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets('AppConsentDialog displays DPDP notice and handles grant', (
      tester,
    ) async {
      bool? consentGranted;

      await tester.pumpWidget(
        buildTestFrame(
          Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  consentGranted = await AppConsentDialog.show(
                    context,
                    title: 'Health Connect Sync',
                    purposeDescription: 'FitKarma accesses step and sleep data to optimize daily recovery recommendations.',
                    dataElements: [
                      'Daily steps count',
                      'Sleep stages and duration',
                    ],
                  );
                },
                child: const Text('Open Consent'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Open Consent'));
      await tester.pumpAndSettle();

      expect(find.text('Health Connect Sync'), findsOneWidget);
      expect(find.textContaining('DPDP Act 2023 Notice'), findsOneWidget);
      expect(find.text('Daily steps count'), findsOneWidget);

      // Grant consent
      await tester.tap(find.text('Grant Consent'));
      await tester.pumpAndSettle();

      expect(consentGranted, isTrue);
    });
  });

  group('AppErrorPanel Tests', () {
    testWidgets(
      'renders inline error with code and retry/dismiss affordances',
      (tester) async {
        bool retried = false;
        bool dismissed = false;

        await tester.pumpWidget(
          buildTestFrame(
            AppErrorPanel(
              message: 'Invalid barcode scanned for Indian food item.',
              errorCode: 'FK-3001',
              onRetry: () => retried = true,
              onDismiss: () => dismissed = true,
            ),
          ),
        );

        expect(
          find.text('Invalid barcode scanned for Indian food item.'),
          findsOneWidget,
        );
        expect(find.text('Code: FK-3001'), findsOneWidget);

        await tester.tap(find.byTooltip('Retry'));
        await tester.pumpAndSettle();
        expect(retried, isTrue);

        await tester.tap(find.byTooltip('Dismiss'));
        await tester.pumpAndSettle();
        expect(dismissed, isTrue);
      },
    );
  });
}
