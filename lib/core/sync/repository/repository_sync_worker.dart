import 'package:fitkarma/core/errors/failures.dart';
import 'package:fitkarma/core/sync/coordinator/sync_worker.dart';
import 'package:fitkarma/core/sync/outbox/models/outbox_models.dart';
import 'package:fitkarma/core/sync/repository/sync_entity.dart';
import 'package:fitkarma/core/sync/repository/sync_repository.dart';

/// Handler boundary for dispatching individual entity operations during outbox draining.
abstract interface class IEntitySyncHandler {
  Future<SyncDispatchResult> dispatch(OutboxOperation operation);
}

/// Adapter converting a [SyncRepository] into an [IEntitySyncHandler].
class RepositoryEntitySyncHandler<TEntity extends SyncEntity<TId>, TId>
    implements IEntitySyncHandler {
  final SyncRepository<TEntity, TId> repository;
  final TId Function(String idString) parseId;
  final TEntity Function(Map<String, dynamic> json) deserializePayload;

  RepositoryEntitySyncHandler({
    required this.repository,
    required this.parseId,
    required this.deserializePayload,
  });

  @override
  Future<SyncDispatchResult> dispatch(OutboxOperation operation) async {
    try {
      final id = parseId(operation.entityId);

      switch (operation.operationType) {
        case OutboxOperationType.delete:
          final delResult = await repository.remoteDataSource.pushDelete(
            id,
            idempotencyKey: operation.idempotencyKey,
          );

          return await delResult.when(
            success: (_) {
              return SyncDispatchResult.success(
                serverResponse: {'deleted': true, 'id': operation.entityId},
              );
            },
            failure: (failure) => _mapFailureToDispatchResult(failure),
          );

        case OutboxOperationType.create:
        case OutboxOperationType.update:
        case OutboxOperationType.upsert:
          final entity = deserializePayload(operation.payload);
          final pushResult = await repository.remoteDataSource.pushUpsert(
            entity,
            idempotencyKey: operation.idempotencyKey,
          );

          return await pushResult.when(
            success: (acknowledgedEntity) async {
              // Acknowledge locally on the repository
              await repository.acknowledgePush(
                id: id,
                serverEntity: acknowledgedEntity,
                operationId: operation.id,
              );

              return SyncDispatchResult.success(
                serverResponse: acknowledgedEntity.toRemoteJson(),
              );
            },
            failure: (failure) => _mapFailureToDispatchResult(failure),
          );
      }
    } catch (e) {
      return SyncDispatchResult.permanentFailure(
        errorMessage: 'Unhandled mutation error: $e',
        errorCode: 'FK-2001',
      );
    }
  }

  SyncDispatchResult _mapFailureToDispatchResult(AppFailure failure) {
    if (failure is ConflictFailure) {
      return SyncDispatchResult.conflict(
        errorMessage: failure.message,
        errorCode: failure.code,
        conflictDetails: failure.details,
      );
    }

    if (failure.retryable) {
      return SyncDispatchResult.transientFailure(
        errorMessage: failure.message,
        errorCode: failure.code,
      );
    }

    return SyncDispatchResult.permanentFailure(
      errorMessage: failure.message,
      errorCode: failure.code,
    );
  }
}

/// Composite [ISyncWorker] that routes outbox operations to registered [IEntitySyncHandler]s.
class RepositorySyncWorker implements ISyncWorker {
  final Map<String, IEntitySyncHandler> _handlers = {};
  final ISyncWorker fallbackWorker;

  RepositorySyncWorker({
    this.fallbackWorker = const DefaultSyncWorker(),
  });

  /// Registers a handler for a given [entityType] (e.g. 'profile', 'health_observation').
  void registerHandler(String entityType, IEntitySyncHandler handler) {
    _handlers[entityType.toLowerCase()] = handler;
  }

  /// Registers a [SyncRepository] directly with parsing and deserialization delegates.
  void registerRepository<TEntity extends SyncEntity<TId>, TId>({
    required SyncRepository<TEntity, TId> repository,
    required TId Function(String idString) parseId,
    required TEntity Function(Map<String, dynamic> json) deserializePayload,
  }) {
    registerHandler(
      repository.entityType,
      RepositoryEntitySyncHandler<TEntity, TId>(
        repository: repository,
        parseId: parseId,
        deserializePayload: deserializePayload,
      ),
    );
  }

  @override
  Future<SyncDispatchResult> processOperation(OutboxOperation operation) async {
    final handler = _handlers[operation.entityType.toLowerCase()];
    if (handler != null) {
      return handler.dispatch(operation);
    }

    // Delegate to fallback worker if no specific handler is registered
    return fallbackWorker.processOperation(operation);
  }
}
