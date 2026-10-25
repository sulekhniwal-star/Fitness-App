import 'package:fitkarma/core/database/app_database.dart';
import 'package:fitkarma/core/database/connection/database_connection.dart';
import 'package:fitkarma/core/database/daos/sync_outbox_dao.dart';
import 'package:fitkarma/core/localization/localization.dart';
import 'package:fitkarma/core/sync/connectivity/connectivity_service.dart';
import 'package:fitkarma/core/sync/coordinator/sync_coordinator.dart';
import 'package:fitkarma/core/sync/outbox/outbox_queue_impl.dart';
import 'package:fitkarma/core/sync/providers/sync_providers.dart';
import 'package:fitkarma/core/sync/sync_boundary.dart';
import 'package:fitkarma/shared/presentation/widgets/shared_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildTestFrame(Widget child, {List<Override> overrides = const []}) {
    return ProviderScope(
      overrides: overrides,
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

  group('OfflineIndicatorBanner & Global Offline UX Tests', () {
    testWidgets('Displays current connectivity state when offline', (tester) async {
      await tester.pumpWidget(
        buildTestFrame(
          const OfflineIndicatorBanner(
            isOffline: true,
          ),
        ),
      );

      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
      expect(find.textContaining('safely preserved offline'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('Displays pending sync count when offline with queued items', (tester) async {
      await tester.pumpWidget(
        buildTestFrame(
          const OfflineIndicatorBanner(
            isOffline: true,
            pendingCount: 3,
          ),
        ),
      );

      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
      expect(find.text('Offline Mode · 3 changes pending sync'), findsOneWidget);
    });

    testWidgets('Hides unobtrusively when online and idle with 0 pending operations', (tester) async {
      await tester.pumpWidget(
        buildTestFrame(
          const OfflineIndicatorBanner(
            isOffline: false,
            status: SyncStatus.idle,
            pendingCount: 0,
          ),
        ),
      );

      expect(find.byIcon(Icons.cloud_off), findsNothing);
      expect(find.byIcon(Icons.sync), findsNothing);
      expect(find.text('Try Again'), findsNothing);
    });

    testWidgets('Displays syncing status and spinner when online and syncing', (tester) async {
      await tester.pumpWidget(
        buildTestFrame(
          const OfflineIndicatorBanner(
            isOffline: false,
            status: SyncStatus.syncing,
            pendingCount: 2,
          ),
        ),
      );

      expect(find.byIcon(Icons.sync), findsOneWidget);
      expect(find.text('Syncing changes...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Displays sync failure and error code when status is error', (tester) async {
      await tester.pumpWidget(
        buildTestFrame(
          const OfflineIndicatorBanner(
            isOffline: false,
            status: SyncStatus.error,
            errorCode: 'FK-3002',
            errorMessage: 'Temporary network failure. Retrying with backoff.',
          ),
        ),
      );

      expect(find.byIcon(Icons.sync_problem), findsOneWidget);
      expect(
        find.text('Temporary network failure. Retrying with backoff.'),
        findsOneWidget,
      );
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('Displays conflict status when status is conflict (FK-3003)', (tester) async {
      await tester.pumpWidget(
        buildTestFrame(
          const OfflineIndicatorBanner(
            isOffline: false,
            status: SyncStatus.conflict,
            errorCode: 'FK-3003',
          ),
        ),
      );

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.text('Conflict detected'), findsOneWidget);
    });

    testWidgets('Retry action button invokes callback and enforces min touch target', (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        buildTestFrame(
          OfflineIndicatorBanner(
            isOffline: true,
            onRetry: () => retried = true,
          ),
        ),
      );

      final retryFinder = find.widgetWithText(TextButton, 'Try Again');
      expect(retryFinder, findsOneWidget);

      final renderBox = tester.renderObject<RenderBox>(retryFinder);
      expect(renderBox.size.height, greaterThanOrEqualTo(48.0));
      expect(renderBox.size.width, greaterThanOrEqualTo(48.0));

      await tester.tap(retryFinder);
      await tester.pumpAndSettle();

      expect(retried, isTrue);
    });

    testWidgets('Tapping banner opens SyncFailureDetailsSheet with diagnostics & local data safety', (tester) async {
      bool retryTriggered = false;

      await tester.pumpWidget(
        buildTestFrame(
          OfflineIndicatorBanner(
            isOffline: true,
            pendingCount: 4,
            errorCode: 'FK-3001',
            onRetry: () => retryTriggered = true,
          ),
        ),
      );

      // Tap on banner message text
      await tester.tap(find.text('Offline Mode · 4 changes pending sync'));
      await tester.pumpAndSettle();

      // Verify bottom sheet opened
      expect(find.byType(SyncFailureDetailsSheet), findsOneWidget);
      expect(find.text('Sync & Connectivity Status'), findsOneWidget);
      expect(find.text('Offline'), findsAtLeastNWidgets(1));
      expect(find.text('4 changes pending sync'), findsOneWidget);
      expect(find.text('Error Code: FK-3001'), findsOneWidget);

      // Verify local data safety guarantee
      expect(
        find.textContaining('securely encrypted on this device and will sync automatically'),
        findsOneWidget,
      );

      // Close modal sheet
      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      expect(find.byType(SyncFailureDetailsSheet), findsNothing);
      expect(retryTriggered, isFalse);
    });

    testWidgets('SyncFailureDetailsSheet explains transient sync failure (FK-3002)', (tester) async {
      bool syncNowTapped = false;

      await tester.pumpWidget(
        buildTestFrame(
          SyncFailureDetailsSheet(
            isOnline: true,
            status: SyncStatus.error,
            errorCode: 'FK-3002',
            pendingCount: 1,
            onRetry: () => syncNowTapped = true,
          ),
        ),
      );

      expect(find.text('Sync & Connectivity Status'), findsOneWidget);
      expect(find.text('Online'), findsOneWidget);
      expect(find.text('Sync failed'), findsOneWidget);
      expect(
        find.textContaining('FitKarma is automatically retrying in the background'),
        findsOneWidget,
      );
      expect(
        find.textContaining('securely encrypted on this device and will sync automatically'),
        findsOneWidget,
      );
      expect(find.text('Sync Now'), findsOneWidget);

      await tester.tap(find.text('Sync Now'));
      await tester.pumpAndSettle();
      expect(syncNowTapped, isTrue);
    });

    testWidgets('Core app remains completely usable while offline (non-blocking)', (tester) async {
      String typedText = '';
      bool buttonClicked = false;

      await tester.pumpWidget(
        buildTestFrame(
          AppScaffold(
            isOffline: true,
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  AppTextField(
                    label: 'Workout Notes',
                    onChanged: (val) => typedText = val,
                  ),
                  const SizedBox(height: 16),
                  AppButton(
                    label: 'Save Offline Workout',
                    onPressed: () => buttonClicked = true,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Offline banner is visible at the top
      expect(find.byType(OfflineIndicatorBanner), findsOneWidget);
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);

      // Form underneath the banner is fully accessible and interactive
      await tester.enterText(find.byType(TextField), 'Completed 5km morning run');
      await tester.pump();
      expect(typedText, 'Completed 5km morning run');

      // Action button is clickable
      await tester.tap(find.text('Save Offline Workout'));
      await tester.pump();
      expect(buttonClicked, isTrue);
    });
  });

  group('Reactive Riverpod Integration Tests', () {
    testWidgets('OfflineIndicatorBanner.connected reactively reflects coordinator state transitions', (
      tester,
    ) async {
      final executor = DatabaseConnectionFactory.createInMemoryConnection();
      final db = AppDatabase(executor);
      final dao = SyncOutboxDao(db);
      final outboxQueue = OutboxQueueImpl(dao: dao);
      final fakeConnectivity = FakeConnectivityService(initialConnected: false);

      final coordinator = SyncCoordinator(
        outboxQueue: outboxQueue,
        connectivityService: fakeConnectivity,
      );

      // Enqueue 1 offline operation
      await coordinator.enqueueOperation(
        entityType: 'workout_log',
        operationType: 'create',
        payload: {'activity': 'running'},
        idempotencyKey: 'offline_op_001',
      );

      await tester.pumpWidget(
        buildTestFrame(
          OfflineIndicatorBanner.connected(),
          overrides: [
            syncCoordinatorProvider.overrideWith((ref) => coordinator),
          ],
        ),
      );

      await tester.pump();

      // Initially offline with 1 pending change
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
      expect(find.text('Offline Mode · 1 change pending sync'), findsOneWidget);

      // Switch to online and trigger sync
      fakeConnectivity.setConnected(true);
      await coordinator.triggerSync();
      await tester.pump();

      // State is now synced with 0 pending
      expect(coordinator.state.isSynced, isTrue);
      expect(coordinator.state.pendingCount, 0);

      // The indicator banner quietly and unobtrusively hides
      expect(find.byIcon(Icons.cloud_off), findsNothing);

      coordinator.dispose();
      fakeConnectivity.dispose();
      await db.close();
    });
  });
}
