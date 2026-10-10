import 'dart:math';
import 'package:fitkarma/core/database/daos/sync_outbox_dao.dart';
import 'package:fitkarma/core/sync/outbox/models/outbox_models.dart';
import 'package:fitkarma/core/sync/outbox/outbox_queue.dart';

/// Concrete implementation of [IOutboxQueue] backed by Drift SQLite persistence.
class OutboxQueueImpl implements IOutboxQueue {
  final SyncOutboxDao _outboxDao;
  final Random _random = Random();

  OutboxQueueImpl({required SyncOutboxDao dao}) : _outboxDao = dao;

  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomHex = _random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0');
    return 'op_${timestamp}_$randomHex';
  }

  @override
  Future<EnqueueResult> enqueue({
    required String entityType,
    required String entityId,
    required OutboxOperationType operationType,
    required Map<String, dynamic> payload,
    required String idempotencyKey,
    Map<String, dynamic>? metadata,
    int maxRetries = 5,
  }) async {
    final normalizedKey = idempotencyKey.trim();
    if (normalizedKey.isEmpty) {
      throw ArgumentError('idempotencyKey must not be empty');
    }

    // 1. Enforce idempotency: check if an operation with this key already exists
    final existing = await _outboxDao.getByIdempotencyKey(normalizedKey);
    if (existing != null) {
      final existingOp = OutboxOperation.fromDbRow(existing);
      switch (existingOp.status) {
        case OutboxStatus.completed:
          return EnqueueResult(
            status: EnqueueStatus.duplicateCompleted,
            operation: existingOp,
          );
        case OutboxStatus.pending:
        case OutboxStatus.processing:
          return EnqueueResult(
            status: EnqueueStatus.duplicatePending,
            operation: existingOp,
          );
        case OutboxStatus.failed:
        case OutboxStatus.permanentlyFailed:
          return EnqueueResult(
            status: EnqueueStatus.duplicateFailed,
            operation: existingOp,
          );
      }
    }

    // 2. Create fresh outbox operation
    final now = DateTime.now();
    final newOp = OutboxOperation(
      id: _generateId(),
      entityType: entityType,
      entityId: entityId,
      operationType: operationType,
      payload: payload,
      idempotencyKey: normalizedKey,
      createdAt: now,
      updatedAt: now,
      retryCount: 0,
      maxRetries: maxRetries,
      status: OutboxStatus.pending,
      metadata: metadata,
    );

    await _outboxDao.enqueue(newOp.toCompanion());
    return EnqueueResult(
      status: EnqueueStatus.enqueued,
      operation: newOp,
    );
  }

  @override
  Future<List<OutboxOperation>> getEligibleOperations({
    int limit = 50,
    DateTime? asOfTime,
  }) async {
    final rows = await _outboxDao.getEligibleEntries(
      limit: limit,
      asOfTime: asOfTime,
    );
    final operations = rows.map(OutboxOperation.fromDbRow).toList();

    // Respect dependency metadata ordering where an operation declares 'depends_on_op_id'
    operations.sort((a, b) {
      final aDependsOnB = a.metadata?['depends_on_op_id'] == b.id;
      final bDependsOnA = b.metadata?['depends_on_op_id'] == a.id;

      if (aDependsOnB) return 1;
      if (bDependsOnA) return -1;
      return a.createdAt.compareTo(b.createdAt);
    });

    return operations;
  }

  @override
  Future<OutboxOperation?> getById(String id) async {
    final row = await _outboxDao.getById(id);
    return row != null ? OutboxOperation.fromDbRow(row) : null;
  }

  @override
  Future<OutboxOperation?> getByIdempotencyKey(String idempotencyKey) async {
    final row = await _outboxDao.getByIdempotencyKey(idempotencyKey.trim());
    return row != null ? OutboxOperation.fromDbRow(row) : null;
  }

  @override
  Future<void> markProcessing(String id) async {
    await _outboxDao.markProcessing(id);
  }

  @override
  Future<void> markSuccess(String id) async {
    await _outboxDao.markCompleted(id);
  }

  @override
  Future<void> markRetryableFailure(
    String id, {
    required String error,
    String? errorCode,
    Duration? backoffDelay,
  }) async {
    final existing = await getById(id);
    if (existing == null) {
      return;
    }

    final delay = backoffDelay ?? existing.calculateExponentialBackoff();
    final nextRetryAt = DateTime.now().add(delay);

    await _outboxDao.markFailed(
      id,
      error,
      errorCode: errorCode,
      currentRetryCount: existing.retryCount,
      maxRetries: existing.maxRetries,
      nextRetryAt: nextRetryAt,
    );
  }

  @override
  Future<void> markPermanentFailure(
    String id, {
    required String error,
    String? errorCode,
  }) async {
    await _outboxDao.markPermanentFailure(
      id,
      error: error,
      errorCode: errorCode,
    );
  }

  @override
  Future<void> resetForRetry(String id) async {
    await _outboxDao.resetForRetry(id);
  }

  @override
  Future<void> deleteOperation(String id) async {
    await _outboxDao.deleteEntry(id);
  }

  @override
  Future<int> clearCompleted() async {
    return _outboxDao.deleteCompleted();
  }

  @override
  Stream<List<OutboxOperation>> watchEligibleOperations({int limit = 50}) {
    return _outboxDao.watchEligibleEntries(limit: limit).map(
          (rows) => rows.map(OutboxOperation.fromDbRow).toList(),
        );
  }
}
