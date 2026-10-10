import 'dart:async';
import 'package:fitkarma/core/sync/outbox/models/outbox_models.dart';
import 'package:fitkarma/core/sync/outbox/outbox_queue.dart';
import 'package:fitkarma/core/sync/sync_boundary.dart';

/// Concrete implementation of [SyncEngine] backed by [IOutboxQueue].
class OutboxSyncEngine implements SyncEngine {
  final IOutboxQueue _queue;
  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();

  SyncStatus _currentStatus = SyncStatus.idle;

  OutboxSyncEngine({required IOutboxQueue outboxQueue})
      : _queue = outboxQueue;

  @override
  SyncStatus get currentStatus => _currentStatus;

  @override
  Stream<SyncStatus> get statusStream => _statusController.stream;

  @override
  Future<void> triggerSync() async {
    _setStatus(SyncStatus.syncing);
    try {
      final eligible = await _queue.getEligibleOperations();
      if (eligible.isEmpty) {
        _setStatus(SyncStatus.synced);
      } else {
        _setStatus(SyncStatus.idle);
      }
    } catch (_) {
      _setStatus(SyncStatus.error);
    }
  }

  @override
  Future<void> enqueueOperation({
    required String entityType,
    required String operationType,
    required Map<String, dynamic> payload,
    required String idempotencyKey,
    String? entityId,
    Map<String, dynamic>? metadata,
  }) async {
    await _queue.enqueue(
      entityType: entityType,
      entityId: entityId ?? payload['id']?.toString() ?? 'default_entity',
      operationType: OutboxOperationType.fromString(operationType),
      payload: payload,
      idempotencyKey: idempotencyKey,
      metadata: metadata,
    );
  }

  void _setStatus(SyncStatus status) {
    _currentStatus = status;
    _statusController.add(status);
  }

  void dispose() {
    _statusController.close();
  }
}
