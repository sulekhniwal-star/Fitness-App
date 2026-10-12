import 'package:fitkarma/core/errors/failures.dart';
import 'package:fitkarma/core/errors/result.dart';
import 'package:fitkarma/core/supabase/mock_supabase_service.dart';
import 'package:fitkarma/core/supabase/supabase_client_service.dart';
import 'package:fitkarma/core/supabase/supabase_failure_mapper.dart';
import 'package:fitkarma/core/supabase/supabase_service_boundary.dart';
import 'package:fitkarma/core/sync/repository/sync_entity.dart';

/// Contract interface for remote operations against the backend API (Supabase).
abstract interface class IRemoteSyncDataSource<TEntity extends SyncEntity<TId>, TId> {
  /// Fetches a single entity by [id] from the remote backend.
  Future<Result<TEntity?>> fetchById(TId id);

  /// Incrementally fetches entities modified on or after [sinceTimestamp].
  Future<Result<List<TEntity>>> fetchSince(
    DateTime sinceTimestamp, {
    int limit = 100,
    int offset = 0,
  });

  /// Pushes an upsert mutation with an [idempotencyKey] to guarantee at-most-once execution.
  Future<Result<TEntity>> pushUpsert(
    TEntity entity, {
    required String idempotencyKey,
  });

  /// Pushes a deletion of the record matching [id] with [idempotencyKey].
  Future<Result<void>> pushDelete(
    TId id, {
    required String idempotencyKey,
  });
}

/// Generic implementation of [IRemoteSyncDataSource] backed by Supabase tables.
class SupabaseTableRemoteDataSource<TEntity extends SyncEntity<TId>, TId>
    implements IRemoteSyncDataSource<TEntity, TId> {
  final ISupabaseService supabaseService;
  final String tableName;
  final String idColumn;
  final String updatedAtColumn;
  final Map<String, dynamic> Function(TEntity) toJson;
  final TEntity Function(Map<String, dynamic>) fromJson;

  SupabaseTableRemoteDataSource({
    required this.supabaseService,
    required this.tableName,
    this.idColumn = 'id',
    this.updatedAtColumn = 'updated_at',
    required this.toJson,
    required this.fromJson,
  });

  @override
  Future<Result<TEntity?>> fetchById(TId id) async {
    if (supabaseService.isMock || supabaseService is MockSupabaseService) {
      // Mock mode returns null or empty by default
      return const Success(null);
    }

    try {
      final client = (supabaseService as SupabaseClientService).rawClient;
      final response = await client
          .from(tableName)
          .select()
          .eq(idColumn, id.toString())
          .maybeSingle();

      if (response == null) {
        return const Success(null);
      }

      return Success(fromJson(response));
    } catch (e, st) {
      return FailureResult(SupabaseFailureMapper.map(e, st));
    }
  }

  @override
  Future<Result<List<TEntity>>> fetchSince(
    DateTime sinceTimestamp, {
    int limit = 100,
    int offset = 0,
  }) async {
    if (supabaseService.isMock || supabaseService is MockSupabaseService) {
      return const Success([]);
    }

    try {
      final client = (supabaseService as SupabaseClientService).rawClient;
      final response = await client
          .from(tableName)
          .select()
          .gte(updatedAtColumn, sinceTimestamp.toIso8601String())
          .order(updatedAtColumn, ascending: true)
          .range(offset, offset + limit - 1);

      final list = (response as List<dynamic>)
          .map((row) => fromJson(row as Map<String, dynamic>))
          .toList();

      return Success(list);
    } catch (e, st) {
      return FailureResult(SupabaseFailureMapper.map(e, st));
    }
  }

  @override
  Future<Result<TEntity>> pushUpsert(
    TEntity entity, {
    required String idempotencyKey,
  }) async {
    if (supabaseService.isMock || supabaseService is MockSupabaseService) {
      // Mock mode accepts mutation immediately
      final acknowledged = entity.copyWithSyncMetadata(
        isSynced: true,
        lastSyncedAt: DateTime.now(),
      ) as TEntity;
      return Success(acknowledged);
    }

    try {
      final client = (supabaseService as SupabaseClientService).rawClient;
      final payload = toJson(entity);

      // Include client idempotency token in mutation row or request
      payload['client_idempotency_key'] = idempotencyKey;

      final response = await client
          .from(tableName)
          .upsert(payload)
          .select()
          .single();

      final acknowledged = fromJson(response).copyWithSyncMetadata(
        isSynced: true,
        lastSyncedAt: DateTime.now(),
      ) as TEntity;

      return Success(acknowledged);
    } catch (e, st) {
      return FailureResult(SupabaseFailureMapper.map(e, st));
    }
  }

  @override
  Future<Result<void>> pushDelete(
    TId id, {
    required String idempotencyKey,
  }) async {
    if (supabaseService.isMock || supabaseService is MockSupabaseService) {
      return const Success(null);
    }

    try {
      final client = (supabaseService as SupabaseClientService).rawClient;
      await client.from(tableName).delete().eq(idColumn, id.toString());
      return const Success(null);
    } catch (e, st) {
      return FailureResult(SupabaseFailureMapper.map(e, st));
    }
  }
}

/// In-memory fake remote data source for testing edge cases, network failures, and conflict injection.
class FakeRemoteSyncDataSource<TEntity extends SyncEntity<TId>, TId>
    implements IRemoteSyncDataSource<TEntity, TId> {
  final Map<TId, TEntity> remoteStore = {};
  final Set<String> processedIdempotencyKeys = {};

  AppFailure? nextFailure;
  bool simulateNetworkDelay = false;

  FakeRemoteSyncDataSource([Map<TId, TEntity>? initial]) {
    if (initial != null) {
      remoteStore.addAll(initial);
    }
  }

  @override
  Future<Result<TEntity?>> fetchById(TId id) async {
    if (nextFailure != null) {
      final f = nextFailure!;
      nextFailure = null;
      return FailureResult(f);
    }
    return Success(remoteStore[id]);
  }

  @override
  Future<Result<List<TEntity>>> fetchSince(
    DateTime sinceTimestamp, {
    int limit = 100,
    int offset = 0,
  }) async {
    if (nextFailure != null) {
      final f = nextFailure!;
      nextFailure = null;
      return FailureResult(f);
    }

    final filtered = remoteStore.values
        .where((e) => !e.syncUpdatedAt.isBefore(sinceTimestamp))
        .skip(offset)
        .take(limit)
        .toList();

    return Success(filtered);
  }

  @override
  Future<Result<TEntity>> pushUpsert(
    TEntity entity, {
    required String idempotencyKey,
  }) async {
    if (nextFailure != null) {
      final f = nextFailure!;
      nextFailure = null;
      return FailureResult(f);
    }

    processedIdempotencyKeys.add(idempotencyKey);

    final acknowledged = entity.copyWithSyncMetadata(
      isSynced: true,
      lastSyncedAt: DateTime.now(),
    ) as TEntity;

    remoteStore[entity.syncId] = acknowledged;
    return Success(acknowledged);
  }

  @override
  Future<Result<void>> pushDelete(
    TId id, {
    required String idempotencyKey,
  }) async {
    if (nextFailure != null) {
      final f = nextFailure!;
      nextFailure = null;
      return FailureResult(f);
    }

    processedIdempotencyKeys.add(idempotencyKey);
    remoteStore.remove(id);
    return const Success(null);
  }
}
