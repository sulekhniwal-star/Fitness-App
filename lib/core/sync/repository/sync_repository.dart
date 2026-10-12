import 'dart:async';
import 'package:fitkarma/core/errors/failures.dart';
import 'package:fitkarma/core/errors/result.dart';
import 'package:fitkarma/core/sync/outbox/models/outbox_models.dart';
import 'package:fitkarma/core/sync/outbox/outbox_queue.dart';
import 'package:fitkarma/core/sync/repository/conflict_strategy.dart';
import 'package:fitkarma/core/sync/repository/local_data_source.dart';
import 'package:fitkarma/core/sync/repository/remote_data_source.dart';
import 'package:fitkarma/core/sync/repository/sync_entity.dart';

/// Abstract base implementation of the reusable offline-first repository synchronization pattern
/// coordinating Drift (local source of truth) and Supabase (remote backend).
abstract class SyncRepository<TEntity extends SyncEntity<TId>, TId> {
  /// The local persistence layer (Drift) acting as the single source of truth.
  final ILocalSyncDataSource<TEntity, TId> localDataSource;

  /// The remote backend data source (Supabase).
  final IRemoteSyncDataSource<TEntity, TId> remoteDataSource;

  /// The local offline outbox mutation queue.
  final IOutboxQueue outboxQueue;

  /// The active conflict resolution strategy.
  final ConflictResolutionStrategy<TEntity> conflictStrategy;

  /// The domain entity type key for outbox queuing (e.g. 'profile', 'health_observation').
  final String entityType;

  SyncRepository({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.outboxQueue,
    this.conflictStrategy = const TimestampLastWriteWinsStrategy(),
    required this.entityType,
  });

  // ===========================================================================
  // 1. LOCAL SOURCE OF TRUTH (Reads & Streams)
  // ===========================================================================

  /// Retrieves an entity by [id].
  ///
  /// Always checks the local Drift database first. If [forceRemote] is true or
  /// no local copy exists, attempts a remote fetch, performs local merge, and returns.
  Future<Result<TEntity?>> get(TId id, {bool forceRemote = false}) async {
    final localItem = await localDataSource.getById(id);

    if (localItem != null && !forceRemote) {
      return Success(localItem);
    }

    // Remote fetch & merge
    final fetchResult = await fetchAndMerge(id);
    if (fetchResult is Success) {
      return fetchResult;
    }

    // Fallback: If remote fetch fails due to offline/network, return local cached copy
    if (localItem != null) {
      return Success(localItem);
    }

    return fetchResult;
  }

  /// Observes an entity by [id] as a reactive stream directly from local Drift storage.
  Stream<TEntity?> watch(TId id) {
    return localDataSource.watchById(id);
  }

  /// Retrieves all cached entities from the local database.
  Future<Result<List<TEntity>>> getAll({bool forceRemote = false}) async {
    final localList = await localDataSource.getAll();
    if (localList.isNotEmpty && !forceRemote) {
      return Success(localList);
    }

    // Attempt remote synchronization
    final pullResult = await pullRemoteChanges();
    if (pullResult is FailureResult && localList.isNotEmpty) {
      return Success(localList);
    }

    final refreshedList = await localDataSource.getAll();
    return Success(refreshedList);
  }

  /// Observes all entities as a reactive stream from local Drift persistence.
  Stream<List<TEntity>> watchAll() {
    return localDataSource.watchAll();
  }

  // ===========================================================================
  // 2. LOCAL MUTATION & OUTBOX PUSH
  // ===========================================================================

  /// Saves an entity locally with optimistic state, then enqueues an outbox operation.
  ///
  /// Guarantees:
  /// - Immediate local persistence with `isSynced: false`
  /// - Outbox queuing with deduplication via [idempotencyKey]
  /// - Full offline resilience (user work is never lost)
  Future<Result<TEntity>> save(
    TEntity entity, {
    String? customIdempotencyKey,
  }) async {
    // 1. Optimistic local-first write
    final localCopy = entity.copyWithSyncMetadata(
      isSynced: false,
      syncUpdatedAt: DateTime.now(),
    ) as TEntity;

    await localDataSource.saveLocal(localCopy, isSynced: false);

    // 2. Outbox enqueue with idempotency key
    final idempotencyKey = customIdempotencyKey ??
        generateIdempotencyKey(
          entityId: entity.syncId.toString(),
          timestamp: localCopy.syncUpdatedAt,
        );

    final enqueueResult = await outboxQueue.enqueue(
      entityType: entityType,
      entityId: entity.syncId.toString(),
      operationType: OutboxOperationType.upsert,
      payload: localCopy.toRemoteJson(),
      idempotencyKey: idempotencyKey,
    );
    if (enqueueResult.isDuplicate) {
      // Duplicate operation safely recognized without double-insertion
    }

    return Success(localCopy);
  }

  /// Deletes an entity locally and enqueues a remote deletion outbox operation.
  Future<Result<void>> delete(
    TId id, {
    String? customIdempotencyKey,
  }) async {
    // 1. Local delete
    await localDataSource.deleteLocal(id);

    // 2. Outbox enqueue
    final idempotencyKey = customIdempotencyKey ??
        generateIdempotencyKey(
          entityId: id.toString(),
          timestamp: DateTime.now(),
          prefix: 'del',
        );

    await outboxQueue.enqueue(
      entityType: entityType,
      entityId: id.toString(),
      operationType: OutboxOperationType.delete,
      payload: {'id': id.toString()},
      idempotencyKey: idempotencyKey,
    );
    return const Success(null);
  }

  // ===========================================================================
  // 3. REMOTE FETCH & LOCAL MERGE
  // ===========================================================================

  /// Fetches a single entity from the remote backend and merges it into local Drift.
  ///
  /// Resolves conflicts according to [conflictStrategy] if local has unpushed changes.
  Future<Result<TEntity?>> fetchAndMerge(TId id) async {
    final remoteResult = await remoteDataSource.fetchById(id);

    return remoteResult.when(
      success: (remoteEntity) async {
        if (remoteEntity == null) {
          // Record does not exist remotely
          return const Success(null);
        }

        final localEntity = await localDataSource.getById(id);
        final hasUnsynced = await localDataSource.hasUnsyncedChanges(id);

        if (localEntity == null || !hasUnsynced) {
          // Clean fast-path: No local unpushed changes. Remote overwrites local cleanly.
          await localDataSource.saveLocal(
            remoteEntity,
            isSynced: true,
            lastSyncedAt: DateTime.now(),
          );
          return Success(remoteEntity);
        }

        // Conflict path: Local entity exists and has pending unpushed changes
        final resolution = conflictStrategy.resolve(
          localEntity: localEntity,
          remoteEntity: remoteEntity,
        );

        switch (resolution.type) {
          case ConflictResolutionType.remoteWins:
            await localDataSource.saveLocal(
              resolution.resolvedEntity!,
              isSynced: true,
              lastSyncedAt: DateTime.now(),
            );
            return Success(resolution.resolvedEntity);

          case ConflictResolutionType.localWins:
            // Local state preserved; remains queued for outbox push
            return Success(localEntity);

          case ConflictResolutionType.merge:
            await localDataSource.saveLocal(
              resolution.resolvedEntity!,
              isSynced: false,
              lastSyncedAt: DateTime.now(),
            );
            // Re-enqueue merged entity to outbox
            await outboxQueue.enqueue(
              entityType: entityType,
              entityId: id.toString(),
              operationType: OutboxOperationType.upsert,
              payload: resolution.resolvedEntity!.toRemoteJson(),
              idempotencyKey: generateIdempotencyKey(
                entityId: id.toString(),
                timestamp: DateTime.now(),
                prefix: 'merge',
              ),
            );
            return Success(resolution.resolvedEntity);

          case ConflictResolutionType.conflictReported:
            // Preserve local data without silent loss, return structured conflict failure
            return FailureResult(
              ConflictFailure(
                message: resolution.reason,
                details: resolution.conflictDetails,
              ),
            );
        }
      },
      failure: (failure) => FailureResult(failure),
    );
  }

  /// Incrementally pulls remote changes and merges them into the local store.
  Future<Result<int>> pullRemoteChanges({DateTime? since}) async {
    final sinceTimestamp = since ?? DateTime.fromMillisecondsSinceEpoch(0);
    final remoteListResult = await remoteDataSource.fetchSince(sinceTimestamp);

    return remoteListResult.when(
      success: (remoteItems) async {
        var mergedCount = 0;
        for (final item in remoteItems) {
          final mergeResult = await fetchAndMerge(item.syncId);
          if (mergeResult is Success) {
            mergedCount++;
          }
        }
        return Success(mergedCount);
      },
      failure: (failure) => FailureResult(failure),
    );
  }

  // ===========================================================================
  // 4. SERVER ACKNOWLEDGEMENT & OUTBOX COMPLETION
  // ===========================================================================

  /// Acknowledges successful remote synchronization.
  ///
  /// Updates local Drift persistence to `isSynced: true`, stores server timestamp/version,
  /// and marks the outbox operation as successfully completed.
  Future<void> acknowledgePush({
    required TId id,
    required TEntity serverEntity,
    required String operationId,
  }) async {
    await localDataSource.saveLocal(
      serverEntity,
      isSynced: true,
      lastSyncedAt: DateTime.now(),
    );
    await outboxQueue.markSuccess(operationId);
  }

  // ===========================================================================
  // 5. HELPER UTILITIES
  // ===========================================================================

  /// Generates a deterministic idempotency key for deduplicating mutations.
  String generateIdempotencyKey({
    required String entityId,
    required DateTime timestamp,
    String prefix = 'mut',
  }) {
    return '${prefix}_${entityType}_${entityId}_${timestamp.millisecondsSinceEpoch}';
  }
}
