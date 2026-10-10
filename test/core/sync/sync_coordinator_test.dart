import 'package:fitkarma/core/database/app_database.dart';
import 'package:fitkarma/core/database/connection/database_connection.dart';
import 'package:fitkarma/core/database/daos/sync_outbox_dao.dart';
import 'package:fitkarma/core/sync/connectivity/connectivity_service.dart';
import 'package:fitkarma/core/sync/coordinator/sync_coordinator.dart';
import 'package:fitkarma/core/sync/coordinator/sync_worker.dart';
import 'package:fitkarma/core/sync/outbox/models/outbox_models.dart';
import 'package:fitkarma/core/sync/outbox/outbox_providers.dart';
import 'package:fitkarma/core/sync/outbox/outbox_queue.dart';
import 'package:fitkarma/core/sync/outbox/outbox_queue_impl.dart';
import 'package:fitkarma/core/sync/providers/sync_providers.dart';
import 'package:fitkarma/core/sync/sync_boundary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MockSyncWorker implements ISyncWorker {
  SyncDispatchResult Function(OutboxOperation op)? onProcess;

  MockSyncWorker({this.onProcess});

  @override
  Future<SyncDispatchResult> processOperation(OutboxOperation operation) async {
    if (onProcess != null) {
      return onProcess!(operation);
    }
    return SyncDispatchResult.success();
  }
}

void main() {
  group('SyncCoordinator State Machine Tests', () {
    late AppDatabase db;
    late SyncOutboxDao dao;
    late IOutboxQueue outboxQueue;
    late FakeConnectivityService fakeConnectivity;
    late MockSyncWorker mockWorker;
    late SyncCoordinator coordinator;

    setUp(() {
      final executor = DatabaseConnectionFactory.createInMemoryConnection();
      db = AppDatabase(executor);
      dao = SyncOutboxDao(db);
      outboxQueue = OutboxQueueImpl(dao: dao);
      fakeConnectivity = FakeConnectivityService(initialConnected: true);
      mockWorker = MockSyncWorker();

      coordinator = SyncCoordinator(
        outboxQueue: outboxQueue,
        connectivityService: fakeConnectivity,
        syncWorker: mockWorker,
      );
    });

    tearDown(() async {
      coordinator.dispose();
      fakeConnectivity.dispose();
      await db.close();
    });

    test('idle -> syncing -> synced happy path when outbox drains cleanly',
        () async {
      expect(coordinator.currentStatus, equals(SyncStatus.idle));
      expect(coordinator.state.isIdle, isTrue);

      final statusHistory = <SyncStatus>[];
      coordinator.statusStream.listen(statusHistory.add);

      // Enqueue 2 operations
      await outboxQueue.enqueue(
        entityType: 'profile',
        entityId: 'user_1',
        operationType: OutboxOperationType.update,
        payload: {'name': 'Amit'},
        idempotencyKey: 'idemp_amit_1',
      );
      await outboxQueue.enqueue(
        entityType: 'wellness',
        entityId: 'user_1',
        operationType: OutboxOperationType.upsert,
        payload: {'dosha': 'Pitta'},
        idempotencyKey: 'idemp_amit_2',
      );

      // Trigger sync
      await coordinator.triggerSync();
      await pumpEventQueue();

      expect(coordinator.currentStatus, equals(SyncStatus.synced));
      expect(coordinator.state.isSynced, isTrue);
      expect(coordinator.state.pendingCount, equals(0));
      expect(coordinator.state.lastSyncedAt, isNotNull);
      expect(coordinator.state.errorMessage, isNull);

      // Verify sequence of state transitions: syncing -> synced
      expect(statusHistory, equals([SyncStatus.syncing, SyncStatus.synced]));

      // Verify operations were marked completed in outbox
      final eligible = await outboxQueue.getEligibleOperations();
      expect(eligible, isEmpty);
    });

    test('idle -> syncing -> error on transient failure with exponential backoff scheduled',
        () async {
      mockWorker.onProcess = (op) => SyncDispatchResult.transientFailure(
            errorMessage: '503 Service Unavailable',
            errorCode: 'FK-3002',
          );

      final statusHistory = <SyncStatus>[];
      coordinator.statusStream.listen(statusHistory.add);

      await outboxQueue.enqueue(
        entityType: 'profile',
        entityId: 'user_err_1',
        operationType: OutboxOperationType.update,
        payload: {'weight': 75},
        idempotencyKey: 'idemp_transient_01',
      );

      await coordinator.triggerSync();
      await pumpEventQueue();

      expect(coordinator.currentStatus, equals(SyncStatus.error));
      expect(coordinator.state.isError, isTrue);
      expect(coordinator.state.errorMessage, equals('503 Service Unavailable'));
      expect(coordinator.state.errorCode, equals('FK-3002'));
      expect(statusHistory, equals([SyncStatus.syncing, SyncStatus.error]));

      // Verify operation has retry count incremented and is scheduled for backoff
      final op = await outboxQueue.getByIdempotencyKey('idemp_transient_01');
      expect(op!.retryCount, equals(1));
      expect(op.status, equals(OutboxStatus.failed));
      expect(op.nextRetryAt, isNotNull);
    });

    test('idle -> syncing -> error on permanent failure halts automatic retry',
        () async {
      mockWorker.onProcess = (op) => SyncDispatchResult.permanentFailure(
            errorMessage: 'Payload failed schema validation',
            errorCode: 'FK-2001',
          );

      await outboxQueue.enqueue(
        entityType: 'profile',
        entityId: 'user_perm_1',
        operationType: OutboxOperationType.create,
        payload: {'invalid': true},
        idempotencyKey: 'idemp_perm_01',
      );

      await coordinator.triggerSync();

      expect(coordinator.currentStatus, equals(SyncStatus.error));
      expect(coordinator.state.errorCode, equals('FK-2001'));

      final op = await outboxQueue.getByIdempotencyKey('idemp_perm_01');
      expect(op!.status, equals(OutboxStatus.permanentlyFailed));
      expect(op.isPermanentFailure, isTrue);
    });

    test('idle -> syncing -> conflict transitions and captures conflictDetails',
        () async {
      mockWorker.onProcess = (op) => SyncDispatchResult.conflict(
            errorMessage: 'Concurrent edit detected on user profile',
            errorCode: 'FK-3003',
            conflictDetails: {
              'server_version': 5,
              'client_version': 4,
              'conflict_field': 'updated_at',
            },
          );

      final statusHistory = <SyncStatus>[];
      coordinator.statusStream.listen(statusHistory.add);

      await outboxQueue.enqueue(
        entityType: 'profile',
        entityId: 'user_conflict_1',
        operationType: OutboxOperationType.update,
        payload: {'height': 180},
        idempotencyKey: 'idemp_conflict_01',
      );

      await coordinator.triggerSync();
      await pumpEventQueue();

      expect(coordinator.currentStatus, equals(SyncStatus.conflict));
      expect(coordinator.state.isConflict, isTrue);
      expect(coordinator.state.errorCode, equals('FK-3003'));
      expect(
        coordinator.state.conflictDetails?['server_version'],
        equals(5),
      );
      expect(statusHistory, equals([SyncStatus.syncing, SyncStatus.conflict]));
    });

    test('connectivity awareness: guards offline sync and resumes automatically on reconnect',
        () async {
      // 1. Simulate offline state
      fakeConnectivity.setConnected(false);

      await outboxQueue.enqueue(
        entityType: 'profile',
        entityId: 'user_offline_1',
        operationType: OutboxOperationType.update,
        payload: {'name': 'Rohan'},
        idempotencyKey: 'idemp_offline_01',
      );

      // Attempt manual sync while offline
      await coordinator.triggerSync();

      // Does NOT transition to syncing; remains idle with offline error code
      expect(coordinator.currentStatus, equals(SyncStatus.idle));
      expect(coordinator.state.isOnline, isFalse);
      expect(coordinator.state.errorCode, equals('FK-3001'));

      // 2. Connectivity restored: automatically triggers sync
      fakeConnectivity.setConnected(true);
      await pumpEventQueue();

      expect(coordinator.state.isOnline, isTrue);
      expect(coordinator.currentStatus, equals(SyncStatus.synced));
    });

    test('cancellation support: stops in-flight sync loop cleanly and returns to idle',
        () async {
      int processedCount = 0;

      mockWorker.onProcess = (op) {
        processedCount++;
        if (processedCount == 1) {
          // Cancel sync in middle of batch
          coordinator.cancelSync();
        }
        return SyncDispatchResult.success();
      };

      // Enqueue 3 operations
      await outboxQueue.enqueue(
        entityType: 'profile',
        entityId: 'op_1',
        operationType: OutboxOperationType.update,
        payload: {},
        idempotencyKey: 'idemp_cancel_1',
      );
      await outboxQueue.enqueue(
        entityType: 'profile',
        entityId: 'op_2',
        operationType: OutboxOperationType.update,
        payload: {},
        idempotencyKey: 'idemp_cancel_2',
      );
      await outboxQueue.enqueue(
        entityType: 'profile',
        entityId: 'op_3',
        operationType: OutboxOperationType.update,
        payload: {},
        idempotencyKey: 'idemp_cancel_3',
      );

      await coordinator.triggerSync();

      // After cancellation, state is idle
      expect(coordinator.currentStatus, equals(SyncStatus.idle));
      // Only 1 was processed before cancel took effect
      expect(processedCount, equals(1));

      // Remaining operations are still pending
      final remaining = await outboxQueue.getEligibleOperations();
      expect(remaining.length, equals(2));
    });

    test('safe restart after interruption: recovers stuck processing records cleanly',
        () async {
      // Seed an operation directly marked as 'processing' simulating sudden crash during sync
      await outboxQueue.enqueue(
        entityType: 'profile',
        entityId: 'interrupted_entity',
        operationType: OutboxOperationType.create,
        payload: {'data': 'pre_crash'},
        idempotencyKey: 'idemp_interrupted_01',
      );
      final op =
          await outboxQueue.getByIdempotencyKey('idemp_interrupted_01');
      await dao.markProcessing(op!.id);

      // Verify row is processing
      final rawRow = await dao.getById(op.id);
      expect(rawRow!.status, equals('processing'));

      // Create new coordinator instance simulating app restart
      final recoveredCoordinator = SyncCoordinator(
        outboxQueue: outboxQueue,
        connectivityService: fakeConnectivity,
        syncWorker: mockWorker,
      );

      // Trigger sync on recovered instance
      await recoveredCoordinator.triggerSync();
      expect(recoveredCoordinator.currentStatus, equals(SyncStatus.synced));

      recoveredCoordinator.dispose();
    });
  });

  group('Sync Providers Riverpod Exposure Tests', () {
    test('Riverpod container exposes SyncCoordinator, SyncStatus, and reactive state',
        () async {
      final executor = DatabaseConnectionFactory.createInMemoryConnection();
      final db = AppDatabase(executor);
      final dao = SyncOutboxDao(db);
      final outboxQueue = OutboxQueueImpl(dao: dao);
      final fakeConnectivity = FakeConnectivityService(initialConnected: true);

      final container = ProviderContainer(
        overrides: [
          outboxQueueProvider.overrideWithValue(outboxQueue),
          connectivityServiceProvider.overrideWithValue(fakeConnectivity),
        ],
      );

      addTearDown(() async {
        container.dispose();
        fakeConnectivity.dispose();
        await db.close();
      });

      // Read initial status
      final initialStatus = container.read(syncStatusProvider);
      expect(initialStatus, equals(SyncStatus.idle));

      final coordinator = container.read(syncCoordinatorProvider.notifier);
      expect(coordinator, isNotNull);

      // Enqueue and sync
      await coordinator.enqueueOperation(
        entityType: 'test',
        operationType: 'create',
        payload: {'k': 'v'},
        idempotencyKey: 'idemp_prov_01',
      );

      await coordinator.triggerSync();
      await pumpEventQueue();

      expect(container.read(syncStatusProvider), equals(SyncStatus.synced));
    });
  });
}
