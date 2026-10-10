import 'package:drift/drift.dart';
import 'package:fitkarma/core/database/app_database.dart';

/// Data Access Object for offline outbox entries (ADR-001).
class SyncOutboxDao {
  final AppDatabase _db;

  SyncOutboxDao(this._db);

  /// Enqueues a sync operation into the outbox.
  Future<int> enqueue(LocalSyncOutboxCompanion entry) {
    return _db.into(_db.localSyncOutbox).insertOnConflictUpdate(entry);
  }

  /// Returns all pending outbox entries ordered by creation time.
  Future<List<LocalSyncOutboxData>> getPendingEntries({int limit = 50}) {
    return (_db.select(_db.localSyncOutbox)
          ..where((t) => t.status.equals('pending'))
          ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  /// Marks an outbox entry as processing.
  Future<int> markProcessing(String id) {
    return (_db.update(_db.localSyncOutbox)..where((t) => t.id.equals(id)))
        .write(
      LocalSyncOutboxCompanion(
        status: const Value('processing'),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Removes an entry upon successful synchronization.
  Future<int> markCompleted(String id) {
    return (_db.delete(_db.localSyncOutbox)..where((t) => t.id.equals(id))).go();
  }

  /// Updates retry count and last error on sync failure.
  Future<int> markFailed(
    String id,
    String error, {
    required int currentRetryCount,
  }) {
    return (_db.update(_db.localSyncOutbox)..where((t) => t.id.equals(id)))
        .write(
      LocalSyncOutboxCompanion(
        status: const Value('failed'),
        lastError: Value(error),
        retryCount: Value(currentRetryCount + 1),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }
}
