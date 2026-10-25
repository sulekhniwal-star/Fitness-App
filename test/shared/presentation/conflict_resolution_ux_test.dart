import 'package:fitkarma/core/localization/localization.dart';
import 'package:fitkarma/core/sync/repository/sync_repository.dart';
import 'package:fitkarma/core/sync/sync_boundary.dart';
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
        home: Scaffold(body: Center(child: child)),
      ),
    );
  }

  group('EntitySyncBadge Tests', () {
    testWidgets('renders Synced state with cloud done icon', (tester) async {
      await tester.pumpWidget(
        buildTestFrame(
          const EntitySyncBadge(
            isSynced: true,
            isPending: false,
            hasConflict: false,
          ),
        ),
      );

      expect(find.byIcon(Icons.cloud_done_rounded), findsOneWidget);
      expect(find.text('All changes synced'), findsOneWidget);
    });

    testWidgets('renders Pending state with cloud queue icon', (tester) async {
      await tester.pumpWidget(
        buildTestFrame(
          const EntitySyncBadge(
            isSynced: false,
            isPending: true,
            hasConflict: false,
          ),
        ),
      );

      expect(find.byIcon(Icons.cloud_queue_rounded), findsOneWidget);
      expect(find.text('Sync Pending'), findsOneWidget);
    });

    testWidgets('renders Conflict state and responds to tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        buildTestFrame(
          EntitySyncBadge(
            isSynced: false,
            isPending: false,
            hasConflict: true,
            onTapConflict: () => tapped = true,
          ),
        ),
      );

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.text('Conflict detected'), findsOneWidget);

      await tester.tap(find.text('Conflict detected'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });
  });

  group('ConflictResolutionSheet Tests', () {
    testWidgets('renders non-blaming explanation and side-by-side versions', (tester) async {
      ConflictUserChoice? selectedChoice;

      await tester.pumpWidget(
        buildTestFrame(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () async {
                selectedChoice = await ConflictResolutionSheet.show(
                  ctx,
                  entityTitle: 'Recipe: Moong Dal Khichdi',
                  localData: {
                    'title': 'Moong Dal Khichdi (Low Ghee)',
                    'calories': 280,
                    'notes': 'Prepared with jeera tadka',
                  },
                  serverData: {
                    'title': 'Moong Dal Khichdi (Standard)',
                    'calories': 340,
                    'notes': 'Added turmeric and ghee',
                  },
                );
              },
              child: const Text('Open Conflict Sheet'),
            ),
          ),
        ),
      );

      // Open sheet
      await tester.tap(find.text('Open Conflict Sheet'));
      await tester.pumpAndSettle();

      // Check non-blaming title and subtitle
      expect(find.text('Review Conflicting Changes'), findsOneWidget);
      expect(find.text('Recipe: Moong Dal Khichdi'), findsOneWidget);
      expect(
        find.textContaining('updated on another device while offline'),
        findsOneWidget,
      );

      // Verify both version cards are rendered
      expect(find.text('This Device (Local)'), findsOneWidget);
      expect(find.text('Cloud (Other Device)'), findsOneWidget);
      expect(find.text('Moong Dal Khichdi (Low Ghee)'), findsOneWidget);
      expect(find.text('Moong Dal Khichdi (Standard)'), findsOneWidget);

      // Verify action buttons
      expect(find.text('Keep My Version'), findsOneWidget);
      expect(find.text('Keep Cloud Version'), findsOneWidget);
      expect(find.text('Merge Changes'), findsOneWidget);

      // Tap "Keep My Version"
      await tester.tap(find.text('Keep My Version'));
      await tester.pumpAndSettle();

      expect(selectedChoice, equals(ConflictUserChoice.keepMine));
    });

    testWidgets('Keep Cloud Version action returns keepServer', (tester) async {
      ConflictUserChoice? selectedChoice;

      await tester.pumpWidget(
        buildTestFrame(
          Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () async {
                selectedChoice = await ConflictResolutionSheet.show(
                  ctx,
                  entityTitle: 'Profile Settings',
                  localData: {'target_weight': '72 kg'},
                  serverData: {'target_weight': '70 kg'},
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Keep Cloud Version'));
      await tester.pumpAndSettle();

      expect(selectedChoice, equals(ConflictUserChoice.keepServer));
    });

    testWidgets('Merge Changes action returns merge and respects touch targets', (tester) async {
      ConflictUserChoice? selectedChoice;

      await tester.pumpWidget(
        buildTestFrame(
          ConflictResolutionSheet(
            entityTitle: 'Custom Food: Ragi Roti',
            localData: {'carbs': 28},
            serverData: {'carbs': 30},
            onResolve: (choice) => selectedChoice = choice,
          ),
        ),
      );

      final mergeFinder = find.widgetWithText(AppButton, 'Merge Changes');
      expect(mergeFinder, findsOneWidget);

      // Verify touch target sizing
      final renderBox = tester.renderObject<RenderBox>(mergeFinder);
      expect(renderBox.size.height, greaterThanOrEqualTo(48.0));

      await tester.tap(mergeFinder);
      await tester.pumpAndSettle();

      expect(selectedChoice, equals(ConflictUserChoice.merge));
    });
  });

  group('OfflineIndicatorBanner & Details Conflict Integration', () {
    testWidgets('Banner surfaces conflict and opens details sheet with review conflict button', (
      tester,
    ) async {
      bool reviewTapped = false;

      await tester.pumpWidget(
        buildTestFrame(
          OfflineIndicatorBanner(
            isOffline: false,
            status: SyncStatus.conflict,
            errorCode: 'FK-3003',
            conflictDetails: {
              'entity_type': 'custom_recipe',
              'local_entity': {'name': 'Local Recipe'},
              'remote_entity': {'name': 'Cloud Recipe'},
            },
            onReviewConflict: () => reviewTapped = true,
          ),
        ),
      );

      // Conflict state banner
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.text('Conflict detected'), findsOneWidget);

      // Tap banner to open details
      await tester.tap(find.text('Conflict detected'));
      await tester.pumpAndSettle();

      expect(find.byType(SyncFailureDetailsSheet), findsOneWidget);
      expect(find.text('Review Conflict'), findsOneWidget);

      await tester.tap(find.text('Review Conflict'));
      await tester.pumpAndSettle();

      expect(reviewTapped, isTrue);
    });
  });
}
