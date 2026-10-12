import 'dart:async';
import 'package:drift/drift.dart';
import 'package:fitkarma/core/sync/repository/local_data_source.dart';
import 'package:fitkarma/core/sync/repository/sync_entity.dart';

/// Reusable adapter bridging any Drift Table and DAO to [ILocalSyncDataSource].
class DriftLocalSyncDataSource<TEntity extends SyncEntity<TId>, TId, TRow,
        TCompanion extends UpdateCompanion<TRow>>
    implements ILocalSyncDataSource<TEntity, TId> {
  final Future<TRow?> Function(TId id) fetchRow;
  final Stream<TRow?> Function(TId id) watchRow;
  final Future<List<TRow>> Function() fetchAllRows;
  final Stream<List<TRow>> Function() watchAllRows;
  final Future<void> Function(TCompanion companion) upsertCompanion;
  final Future<void> Function(TId id) deleteRow;
  final TEntity Function(TRow row) mapToEntity;
  final TCompanion Function(
    TEntity entity, {
    required bool isSynced,
    DateTime? lastSyncedAt,
  }) mapToCompanion;

  DriftLocalSyncDataSource({
    required this.fetchRow,
    required this.watchRow,
    required this.fetchAllRows,
    required this.watchAllRows,
    required this.upsertCompanion,
    required this.deleteRow,
    required this.mapToEntity,
    required this.mapToCompanion,
  });

  @override
  Future<TEntity?> getById(TId id) async {
    final row = await fetchRow(id);
    if (row == null) return null;
    return mapToEntity(row);
  }

  @override
  Stream<TEntity?> watchById(TId id) {
    return watchRow(id).map((row) => row != null ? mapToEntity(row) : null);
  }

  @override
  Future<List<TEntity>> getAll() async {
    final rows = await fetchAllRows();
    return rows.map(mapToEntity).toList();
  }

  @override
  Stream<List<TEntity>> watchAll() {
    return watchAllRows()
        .map((rows) => rows.map(mapToEntity).toList());
  }

  @override
  Future<void> saveLocal(
    TEntity entity, {
    required bool isSynced,
    DateTime? lastSyncedAt,
  }) async {
    final companion = mapToCompanion(
      entity,
      isSynced: isSynced,
      lastSyncedAt: lastSyncedAt,
    );
    await upsertCompanion(companion);
  }

  @override
  Future<void> deleteLocal(TId id) async {
    await deleteRow(id);
  }

  @override
  Future<bool> hasUnsyncedChanges(TId id) async {
    final entity = await getById(id);
    if (entity == null) return false;
    return !entity.isSynced;
  }
}
