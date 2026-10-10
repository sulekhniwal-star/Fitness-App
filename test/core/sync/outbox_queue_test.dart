import 'package:fitkarma/core/database/app_database.dart';
import 'package:fitkarma/core/database/connection/database_connection.dart';
import 'package:fitkarma/core/database/daos/sync_outbox_dao.dart';
import 'package:fitkarma/core/sync/outbox/models/outbox_models.dart';
import 'package:fitkarma/core/sync/outbox/outbox_queue.dart';
import 'package:fitkarma/core/sync/outbox/outbox_queue_impl.dart';
import 'package:fitkarma/core/sync/outbox_sync_engine.dart';
import 'package:fitkarma/core/sync/sync_boundary.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('OutboxQueue Unit Tests (Offline Sync Foundation)', () {
    late AppDatabase db;
    late SyncOutboxDao dao;
    late IOutboxQueue outboxQueue;

    setUp(() {
      final executor = DatabaseConnectionFactory.createInMemoryConnection();
      db = AppDatabase(executor);
      dao = SyncOutboxDao(db);
      outboxQueue = OutboxQueueImpl(dao: dao);
    });

    tearDown(() async {
      await db.close();
    });

    test('enqueue creates a new pending operation with all fields and metadata',
        () async {
      final payload = {
        'displayName': 'Diya Patel',
        'age': 27,
        'city': 'Ahmedabad',
      };
      final metadata = {
        'source': 'onboarding_flow',
        'schema_version': 1,
      };

      final result = await outboxQueue.enqueue(
        entityType: 'profile',
        entityId: 'usr_patel_1',
        operationType: OutboxOperationType.upsert,
        payload: payload,
        idempotencyKey: 'idemp_patel_profile_001',
        metadata: metadata,
        maxRetries: 4,
      );

      expect(result.isNew, isTrue);
      expect(result.isDuplicate, isFalse);
      expect(result.status, equals(EnqueueStatus.enqueued));

      final op = result.operation;
      expect(op.id, startsWith('op_'));
      expect(op.entityType, equals('profile'));
      expect(op.entityId, equals('usr_patel_1'));
      expect(op.operationType, equals(OutboxOperationType.upsert));
      expect(op.payload['displayName'], equals('Diya Patel'));
      expect(op.metadata?['source'], equals('onboarding_flow'));
      expect(op.retryCount, equals(0));
      expect(op.maxRetries, equals(4));
      expect(op.status, equals(OutboxStatus.pending));
      expect(op.lastError, isNull);

      // Verify retrieval by ID and by Idempotency Key
      final retrievedById = await outboxQueue.getById(op.id);
      expect(retrievedById, isNotNull);
      expect(retrievedById!.idempotencyKey, equals('idemp_patel_profile_001'));

      final retrievedByKey = await outboxQueue.getByIdempotencyKey(
        'idemp_patel_profile_001',
      );
      expect(retrievedByKey, isNotNull);
      expect(retrievedByKey!.id, equals(op.id));
    });

    test('duplicate idempotency key is safely deduplicated without creating duplicate entries',
        () async {
      const idempotencyKey = 'idemp_unique_tx_888';

      // 1. Initial enqueue
      final initialResult = await outboxQueue.enqueue(
        entityType: 'food_log',
        entityId: 'food_1',
        operationType: OutboxOperationType.create,
        payload: {'foodName': 'Dal Tadka', 'calories': 240},
        idempotencyKey: idempotencyKey,
      );
      expect(initialResult.status, equals(EnqueueStatus.enqueued));

      // 2. Duplicate enqueue while initial is still pending
      final dupPendingResult = await outboxQueue.enqueue(
        entityType: 'food_log',
        entityId: 'food_1',
        operationType: OutboxOperationType.create,
        payload: {'foodName': 'Dal Tadka Modified', 'calories': 300},
        idempotencyKey: idempotencyKey,
      );
      expect(dupPendingResult.isDuplicate, isTrue);
      expect(
        dupPendingResult.status,
        equals(EnqueueStatus.duplicatePending),
      );
      expect(dupPendingResult.operation.id, equals(initialResult.operation.id));

      // Assert queue has exactly 1 item
      final pendingList = await outboxQueue.getEligibleOperations();
      expect(pendingList.length, equals(1));

      // 3. Mark operation as completed
      await outboxQueue.markSuccess(initialResult.operation.id);

      // 4. Duplicate enqueue after completion
      final dupCompletedResult = await outboxQueue.enqueue(
        entityType: 'food_log',
        entityId: 'food_1',
        operationType: OutboxOperationType.create,
        payload: {'foodName': 'Dal Tadka', 'calories': 240},
        idempotencyKey: idempotencyKey,
      );
      expect(dupCompletedResult.isDuplicate, isTrue);
      expect(
        dupCompletedResult.status,
        equals(EnqueueStatus.duplicateCompleted),
      );
      expect(
        dupCompletedResult.operation.status,
        equals(OutboxStatus.completed),
      );
    });

    test('rejects empty or whitespace idempotency keys', () async {
      expect(
        () => outboxQueue.enqueue(
          entityType: 'profile',
          entityId: 'prof_1',
          operationType: OutboxOperationType.update,
          payload: {},
          idempotencyKey: '   ',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('success lifecycle transitions from processing to completed and clearCompleted removes it',
        () async {
      final res = await outboxQueue.enqueue(
        entityType: 'workout',
        entityId: 'workout_10',
        operationType: OutboxOperationType.create,
        payload: {'title': 'Morning Yoga', 'durationMinutes': 30},
        idempotencyKey: 'idemp_workout_10',
      );
      final opId = res.operation.id;

      // Mark processing
      await outboxQueue.markProcessing(opId);
      final processingOp = await outboxQueue.getById(opId);
      expect(processingOp!.status, equals(OutboxStatus.processing));

      // Mark success
      await outboxQueue.markSuccess(opId);
      final completedOp = await outboxQueue.getById(opId);
      expect(completedOp!.status, equals(OutboxStatus.completed));

      // Eligible list excludes completed operations
      final eligible = await outboxQueue.getEligibleOperations();
      expect(eligible, isEmpty);

      // clearCompleted purges row
      final clearedCount = await outboxQueue.clearCompleted();
      expect(clearedCount, equals(1));
      expect(await outboxQueue.getById(opId), isNull);
    });

    test('retryable failure increments retryCount, computes exponential backoff, and respects schedule',
        () async {
      final res = await outboxQueue.enqueue(
        entityType: 'profile',
        entityId: 'prof_retry',
        operationType: OutboxOperationType.update,
        payload: {'weightKg': 72.5},
        idempotencyKey: 'idemp_retry_backoff_01',
      );
      final opId = res.operation.id;

      final beforeFailure = DateTime.now();

      // Trigger 1st retryable failure (simulating HTTP 503)
      await outboxQueue.markRetryableFailure(
        opId,
        error: '503 Service Unavailable',
        errorCode: 'FK-3002',
        backoffDelay: const Duration(seconds: 4),
      );

      final opAfterFail1 = await outboxQueue.getById(opId);
      expect(opAfterFail1!.retryCount, equals(1));
      expect(opAfterFail1.status, equals(OutboxStatus.failed));
      expect(opAfterFail1.lastError, equals('503 Service Unavailable'));
      expect(opAfterFail1.lastErrorCode, equals('FK-3002'));
      expect(opAfterFail1.isRetryable, isTrue);
      expect(opAfterFail1.isPermanentFailure, isFalse);
      expect(opAfterFail1.nextRetryAt, isNotNull);
      expect(
        opAfterFail1.nextRetryAt!.isAfter(beforeFailure),
        isTrue,
      );

      // Not eligible immediately (before nextRetryAt)
      final immediateEligible = await outboxQueue.getEligibleOperations(
        asOfTime: beforeFailure,
      );
      expect(immediateEligible, isEmpty);

      // Eligible after scheduled nextRetryAt has elapsed
      final futureEligible = await outboxQueue.getEligibleOperations(
        asOfTime: beforeFailure.add(const Duration(seconds: 5)),
      );
      expect(futureEligible.length, equals(1));
      expect(futureEligible.first.id, equals(opId));

      // Trigger 2nd retryable failure using automated exponential backoff
      await outboxQueue.markRetryableFailure(
        opId,
        error: 'SocketException: Network unreachable',
        errorCode: 'FK-3002',
      );

      final opAfterFail2 = await outboxQueue.getById(opId);
      expect(opAfterFail2!.retryCount, equals(2));
      expect(opAfterFail2.lastError, contains('Network unreachable'));
    });

    test('permanent failure marks operation permanentlyFailed and halts automatic retries',
        () async {
      final res = await outboxQueue.enqueue(
        entityType: 'profile',
        entityId: 'prof_perm_fail',
        operationType: OutboxOperationType.create,
        payload: {'invalidField': 'bad_value'},
        idempotencyKey: 'idemp_perm_fail_01',
      );
      final opId = res.operation.id;

      // Mark explicit permanent failure (e.g. FK-2001 validation failure)
      await outboxQueue.markPermanentFailure(
        opId,
        error: 'Schema validation rejected payload',
        errorCode: 'FK-2001',
      );

      final failedOp = await outboxQueue.getById(opId);
      expect(failedOp!.status, equals(OutboxStatus.permanentlyFailed));
      expect(failedOp.isPermanentFailure, isTrue);
      expect(failedOp.isRetryable, isFalse);
      expect(failedOp.lastErrorCode, equals('FK-2001'));
      expect(failedOp.nextRetryAt, isNull);

      // Ensure never eligible for automatic sync
      final eligible = await outboxQueue.getEligibleOperations(
        asOfTime: DateTime.now().add(const Duration(days: 365)),
      );
      expect(eligible, isEmpty);

      // Manual reset restores operation to pending
      await outboxQueue.resetForRetry(opId);
      final resetOp = await outboxQueue.getById(opId);
      expect(resetOp!.status, equals(OutboxStatus.pending));
    });

    test('max retries exhaustion transitions automatically to permanentlyFailed',
        () async {
      final res = await outboxQueue.enqueue(
        entityType: 'wellness',
        entityId: 'wellness_exhaust',
        operationType: OutboxOperationType.upsert,
        payload: {'dominantDosha': 'Kapha'},
        idempotencyKey: 'idemp_exhaust_01',
        maxRetries: 2, // Maximum 2 retries allowed
      );
      final opId = res.operation.id;

      // 1st failure -> retryCount = 1 (< 2)
      await outboxQueue.markRetryableFailure(
        opId,
        error: 'Gateway Timeout 504',
      );
      expect((await outboxQueue.getById(opId))!.status, equals(OutboxStatus.failed));

      // 2nd failure -> retryCount = 2 (>= maxRetries) -> automatically permanentlyFailed
      await outboxQueue.markRetryableFailure(
        opId,
        error: 'Gateway Timeout 504 (final attempt)',
      );
      final exhaustedOp = await outboxQueue.getById(opId);
      expect(exhaustedOp!.status, equals(OutboxStatus.permanentlyFailed));
      expect(exhaustedOp.retryCount, equals(2));
      expect(exhaustedOp.isPermanentFailure, isTrue);
    });

    test('dependency metadata orders dependent operations after prerequisite operations',
        () async {
      // Create independent parent operation
      final op1 = await outboxQueue.enqueue(
        entityType: 'profile',
        entityId: 'parent_entity',
        operationType: OutboxOperationType.create,
        payload: {'name': 'Parent'},
        idempotencyKey: 'idemp_parent_01',
      );

      // Create dependent child operation that declares depends_on_op_id
      final op2 = await outboxQueue.enqueue(
        entityType: 'wellness',
        entityId: 'child_entity',
        operationType: OutboxOperationType.create,
        payload: {'profileId': 'parent_entity'},
        idempotencyKey: 'idemp_child_01',
        metadata: {'depends_on_op_id': op1.operation.id},
      );

      final eligible = await outboxQueue.getEligibleOperations();
      expect(eligible.length, equals(2));
      // op1 must come before op2
      expect(eligible.first.id, equals(op1.operation.id));
      expect(eligible.last.id, equals(op2.operation.id));
    });
  });

  group('OutboxSyncEngine Integration Tests', () {
    test('OutboxSyncEngine delegates enqueuing and reflects idle/synced/syncing status',
        () async {
      final executor = DatabaseConnectionFactory.createInMemoryConnection();
      final db = AppDatabase(executor);
      final dao = SyncOutboxDao(db);
      final outboxQueue = OutboxQueueImpl(dao: dao);
      final syncEngine = OutboxSyncEngine(outboxQueue: outboxQueue);

      expect(syncEngine.currentStatus, equals(SyncStatus.idle));

      // Enqueue through SyncEngine interface
      await syncEngine.enqueueOperation(
        entityType: 'profile',
        operationType: 'update',
        payload: {'id': 'user_sync_1', 'locale': 'hi'},
        idempotencyKey: 'idemp_sync_engine_001',
      );

      final op = await outboxQueue.getByIdempotencyKey('idemp_sync_engine_001');
      expect(op, isNotNull);
      expect(op!.entityType, equals('profile'));
      expect(op.entityId, equals('user_sync_1'));

      // Trigger sync
      await syncEngine.triggerSync();
      // Since items are pending and worker is not actively draining them here, status returns to idle
      expect(syncEngine.currentStatus, equals(SyncStatus.idle));

      // Once queue is empty, triggerSync marks synced
      await outboxQueue.clearCompleted();
      await dao.deleteEntry(op.id);
      await syncEngine.triggerSync();
      expect(syncEngine.currentStatus, equals(SyncStatus.synced));

      syncEngine.dispose();
      await db.close();
    });
  });
}
