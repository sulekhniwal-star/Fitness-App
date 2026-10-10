import 'package:drift/drift.dart';
import 'package:fitkarma/core/database/app_database.dart';

/// Data Access Object for offline outbox entries (ADR-001).
class SyncOutboxDao {
  final AppDatabase _db;

  SyncOutboxDao(this._db);

  /// Retrieves an outbox entry by its unique [id].
  Future<LocalSyncOutboxData?> getById(String id) {
    return (_db.select(_db.localSyncOutbox)..where((t) => t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Retrieves an outbox entry by its [idempotencyKey].
  Future<LocalSyncOutboxData?> getByIdempotencyKey(String idempotencyKey) {
    return (_db.select(_db.localSyncOutbox)
          ..where((t) => t.idempotencyKey.equals(idempotencyKey)))
        .getSingleOrNull();
  }

  /// Inserts or updates a sync operation into the outbox.
  Future<int> enqueue(LocalSyncOutboxCompanion entry) {
    return _db.into(_db.localSyncOutbox).insertOnConflictUpdate(entry);
  }

  /// Returns pending and retry-eligible outbox entries.
  ///
  /// Considers entries that are in 'pending' status OR 'failed' status
  /// where [nextRetryAt] is before or equal to [asOfTime] (defaulting to DateTime.now())
  /// and [retryCount] is below [maxRetries].
  Future<List<LocalSyncOutboxData>> getEligibleEntries({
    int limit = 50,
    DateTime? asOfTime,
  }) {
    final now = asOfTime ?? DateTime.now();
    return (_db.select(_db.localSyncOutbox)
          ..where(
            (t) =>
                t.status.equals('pending') |
                (t.status.equals('failed') &
                    (t.nextRetryAt.isNull() | t.nextRetryAt.isSmallerOrEqualValue(now)) &
                    t.retryCount.isSmallerThan(t.maxRetries)),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  /// Legacy helper for strictly pending entries.
  Future<List<LocalSyncOutboxData>> getPendingEntries({int limit = 50}) {
    return (_db.select(_db.localSyncOutbox)
          ..where((t) => t.status.equals('pending'))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  /// Watches all pending/eligible entries as a reactive stream.
  Stream<List<LocalSyncOutboxData>> watchEligibleEntries({int limit = 50}) {
    return (_db.select(_db.localSyncOutbox)
          ..where(
            (t) =>
                t.status.equals('pending') |
                (t.status.equals('failed') &
                    t.retryCount.isSmallerThan(t.maxRetries)),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(limit))
        .watch();
  }

  /// Marks an outbox entry as currently processing.
  Future<int> markProcessing(String id) {
    return (_db.update(_db.localSyncOutbox)..where((t) => t.id.equals(id)))
        .write(
      LocalSyncOutboxCompanion(
        status: const Value('processing'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Marks an entry as successfully completed.
  Future<int> markCompleted(String id) {
    return (_db.update(_db.localSyncOutbox)..where((t) => t.id.equals(id)))
        .write(
      LocalSyncOutboxCompanion(
        status: const Value('completed'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Deletes an entry upon successful synchronization.
  Future<int> deleteEntry(String id) {
    return (_db.delete(_db.localSyncOutbox)..where((t) => t.id.equals(id))).go();
  }

  /// Clears all completed outbox records.
  Future<int> deleteCompleted() {
    return (_db.delete(_db.localSyncOutbox)
          ..where((t) => t.status.equals('completed')))
        .go();
  }

  /// Marks an entry as failed with retryable status and scheduled backoff time.
  ///
  /// If the new retry count reaches or exceeds [maxRetries], automatically marks
  /// the entry as 'permanentlyFailed'.
  Future<int> markFailed(
    String id,
    String error, {
    String? errorCode,
    required int currentRetryCount,
    int maxRetries = 5,
    DateTime? nextRetryAt,
  }) {
    final nextCount = currentRetryCount + 1;
    final isPermanent = nextCount >= maxRetries;
    final targetStatus = isPermanent ? 'permanentlyFailed' : 'failed';

    return (_db.update(_db.localSyncOutbox)..where((t) => t.id.equals(id)))
        .write(
      LocalSyncOutboxCompanion(
        status: Value(targetStatus),
        lastError: Value(error),
        lastErrorCode: Value(errorCode),
        retryCount: Value(nextCount),
        nextRetryAt: Value(isPermanent ? null : nextRetryAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Marks an entry as permanently failed immediately (e.g. invalid payload or unrecoverable error).
  Future<int> markPermanentFailure(
    String id, {
    required String error,
    String? errorCode,
  }) {
    return (_db.update(_db.localSyncOutbox)..where((t) => t.id.equals(id)))
        .write(
      LocalSyncOutboxCompanion(
        status: const Value('permanentlyFailed'),
        lastError: Value(error),
        lastErrorCode: Value(errorCode),
        nextRetryAt: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Resets a failed or permanently failed entry back to pending for manual retry.
  Future<int> resetForRetry(String id) {
    return (_db.update(_db.localSyncOutbox)..where((t) => t.id.equals(id)))
        .write(
      LocalSyncOutboxCompanion(
        status: const Value('pending'),
        nextRetryAt: const Value(null),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
