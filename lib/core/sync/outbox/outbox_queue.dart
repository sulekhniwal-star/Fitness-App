import 'package:fitkarma/core/sync/outbox/models/outbox_models.dart';

/// Contract interface for the generic offline outbox/sync queue foundation.
abstract interface class IOutboxQueue {
  /// Enqueues an operation into the outbox.
  ///
  /// Enforces idempotency by checking if an entry with [idempotencyKey]
  /// already exists, avoiding duplicate queue entries.
  Future<EnqueueResult> enqueue({
    required String entityType,
    required String entityId,
    required OutboxOperationType operationType,
    required Map<String, dynamic> payload,
    required String idempotencyKey,
    Map<String, dynamic>? metadata,
    int maxRetries = 5,
  });

  /// Retrieves operations currently eligible for synchronization.
  ///
  /// Returns pending entries and failed entries whose exponential backoff
  /// [nextRetryAt] has elapsed, ordered by dependency metadata and createdAt.
  Future<List<OutboxOperation>> getEligibleOperations({
    int limit = 50,
    DateTime? asOfTime,
  });

  /// Retrieves an outbox operation by its unique [id].
  Future<OutboxOperation?> getById(String id);

  /// Retrieves an outbox operation by its [idempotencyKey].
  Future<OutboxOperation?> getByIdempotencyKey(String idempotencyKey);

  /// Marks an operation as currently processing.
  Future<void> markProcessing(String id);

  /// Marks an operation as successfully synced.
  Future<void> markSuccess(String id);

  /// Marks an operation as failed with retry eligibility and calculates exponential backoff.
  ///
  /// If the retry count reaches [maxRetries], automatically marks the operation as permanently failed.
  Future<void> markRetryableFailure(
    String id, {
    required String error,
    String? errorCode,
    Duration? backoffDelay,
  });

  /// Marks an operation as permanently failed immediately (e.g. non-retryable validation or auth error).
  Future<void> markPermanentFailure(
    String id, {
    required String error,
    String? errorCode,
  });

  /// Resets a failed or permanently failed operation back to pending for manual retry.
  Future<void> resetForRetry(String id);

  /// Deletes a specific operation by [id].
  Future<void> deleteOperation(String id);

  /// Clears all successfully completed operations from the outbox.
  Future<int> clearCompleted();

  /// Watches all pending and retry-eligible operations as a reactive stream.
  Stream<List<OutboxOperation>> watchEligibleOperations({int limit = 50});
}
