import 'dart:async';
import 'package:fitkarma/core/sync/repository/sync_entity.dart';

/// Contract interface for the local persistence layer (Drift) acting as the single source of truth.
abstract interface class ILocalSyncDataSource<TEntity extends SyncEntity<TId>, TId> {
  /// Retrieves a local entity by [id] if present.
  Future<TEntity?> getById(TId id);

  /// Watches a single entity by [id] as a reactive stream from local Drift persistence.
  Stream<TEntity?> watchById(TId id);

  /// Retrieves all cached entities.
  Future<List<TEntity>> getAll();

  /// Watches all entities as a reactive stream.
  Stream<List<TEntity>> watchAll();

  /// Persists the entity into the local database with synchronization metadata.
  Future<void> saveLocal(
    TEntity entity, {
    required bool isSynced,
    DateTime? lastSyncedAt,
  });

  /// Deletes the local record matching [id].
  Future<void> deleteLocal(TId id);

  /// Checks whether the entity at [id] has unacknowledged local mutations (`isSynced == false`).
  Future<bool> hasUnsyncedChanges(TId id);
}

/// In-memory implementation of [ILocalSyncDataSource] for fast, deterministic unit testing.
class InMemoryLocalSyncDataSource<TEntity extends SyncEntity<TId>, TId>
    implements ILocalSyncDataSource<TEntity, TId> {
  final Map<TId, TEntity> _store = {};
  final StreamController<List<TEntity>> _allController =
      StreamController<List<TEntity>>.broadcast();
  final Map<TId, StreamController<TEntity?>> _individualControllers = {};

  InMemoryLocalSyncDataSource([Map<TId, TEntity>? initialData]) {
    if (initialData != null) {
      _store.addAll(initialData);
    }
  }

  @override
  Future<TEntity?> getById(TId id) async => _store[id];

  @override
  Stream<TEntity?> watchById(TId id) {
    final controller = _individualControllers.putIfAbsent(
      id,
      () => StreamController<TEntity?>.broadcast(
        onListen: () {
          _individualControllers[id]?.add(_store[id]);
        },
      ),
    );
    return controller.stream;
  }

  @override
  Future<List<TEntity>> getAll() async => _store.values.toList();

  @override
  Stream<List<TEntity>> watchAll() {
    return _allController.stream;
  }

  @override
  Future<void> saveLocal(
    TEntity entity, {
    required bool isSynced,
    DateTime? lastSyncedAt,
  }) async {
    final updated = entity.copyWithSyncMetadata(
      isSynced: isSynced,
      lastSyncedAt: lastSyncedAt,
    ) as TEntity;
    _store[entity.syncId] = updated;

    _notify(entity.syncId);
  }

  @override
  Future<void> deleteLocal(TId id) async {
    _store.remove(id);
    _notify(id);
  }

  @override
  Future<bool> hasUnsyncedChanges(TId id) async {
    final entity = _store[id];
    if (entity == null) return false;
    return !entity.isSynced;
  }

  void _notify(TId id) {
    if (_individualControllers.containsKey(id)) {
      _individualControllers[id]?.add(_store[id]);
    }
    _allController.add(_store.values.toList());
  }

  void dispose() {
    _allController.close();
    for (final c in _individualControllers.values) {
      c.close();
    }
    _individualControllers.clear();
  }
}
