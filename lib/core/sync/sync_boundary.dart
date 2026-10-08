/// Synchronization engine state representation.
enum SyncStatus { idle, syncing, synced, error, conflict }

/// Contract interface for outbox synchronization engine.
abstract interface class SyncEngine {
  SyncStatus get currentStatus;
  Stream<SyncStatus> get statusStream;
  Future<void> triggerSync();
  Future<void> enqueueOperation({
    required String entityType,
    required String operationType,
    required Map<String, dynamic> payload,
    required String idempotencyKey,
  });
}
