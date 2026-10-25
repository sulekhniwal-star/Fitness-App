import 'package:fitkarma/core/database/app_database.dart';
import 'package:fitkarma/core/database/connection/database_connection.dart';
import 'package:fitkarma/core/database/daos/sync_outbox_dao.dart';
import 'package:fitkarma/core/errors/failures.dart';
import 'package:fitkarma/core/errors/result.dart';
import 'package:fitkarma/core/sync/connectivity/connectivity_service.dart';
import 'package:fitkarma/core/sync/coordinator/sync_coordinator.dart';
import 'package:fitkarma/core/sync/outbox/outbox_queue_impl.dart';
import 'package:fitkarma/core/sync/repository/conflict_strategy.dart';
import 'package:fitkarma/core/sync/repository/local_data_source.dart';
import 'package:fitkarma/core/sync/repository/remote_data_source.dart';
import 'package:fitkarma/core/sync/repository/repository_sync_worker.dart';
import 'package:fitkarma/core/sync/repository/sync_entity.dart';
import 'package:fitkarma/core/sync/repository/sync_repository.dart';
import 'package:fitkarma/core/sync/sync_boundary.dart';
import 'package:flutter_test/flutter_test.dart';

class ConflictTestRecipe implements SyncEntity<String> {
  final String id;
  final String title;
  final String instructions;
  final int calories;
  @override
  final bool isSynced;
  final DateTime updatedAt;
  @override
  final DateTime? lastSyncedAt;
  final int? version;

  ConflictTestRecipe({
    required this.id,
    required this.title,
    required this.instructions,
    this.calories = 350,
    this.isSynced = true,
    required this.updatedAt,
    this.lastSyncedAt,
    this.version = 1,
  });

  @override
  String get syncId => id;

  @override
  DateTime get syncUpdatedAt => updatedAt;

  @override
  int? get syncVersion => version;

  @override
  Map<String, dynamic> toRemoteJson() => {
        'id': id,
        'title': title,
        'instructions': instructions,
        'calories': calories,
        'updated_at': updatedAt.toIso8601String(),
        if (version != null) 'version': version,
      };

  factory ConflictTestRecipe.fromJson(Map<String, dynamic> json) => ConflictTestRecipe(
        id: json['id'] as String,
        title: json['title'] as String,
        instructions: json['instructions'] as String? ?? '',
        calories: json['calories'] as int? ?? 350,
        isSynced: true,
        updatedAt: DateTime.parse(json['updated_at'] as String),
        lastSyncedAt: json['last_synced_at'] != null
            ? DateTime.parse(json['last_synced_at'] as String)
            : null,
        version: json['version'] as int? ?? 1,
      );

  @override
  ConflictTestRecipe copyWithSyncMetadata({
    bool? isSynced,
    DateTime? lastSyncedAt,
    int? syncVersion,
    DateTime? syncUpdatedAt,
  }) {
    return ConflictTestRecipe(
      id: id,
      title: title,
      instructions: instructions,
      calories: calories,
      isSynced: isSynced ?? this.isSynced,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      version: syncVersion ?? version,
      updatedAt: syncUpdatedAt ?? updatedAt,
    );
  }
}

class RecipeTestRepository extends SyncRepository<ConflictTestRecipe, String> {
  RecipeTestRepository({
    required super.localDataSource,
    required super.remoteDataSource,
    required super.outboxQueue,
    super.conflictStrategy = const ManualConflictStrategy(),
  }) : super(entityType: 'custom_recipe');
}

void main() {
  group('Conflict Creation & Invariant Tests (FK-3003)', () {
    late InMemoryLocalSyncDataSource<ConflictTestRecipe, String> localDataSource;
    late FakeRemoteSyncDataSource<ConflictTestRecipe, String> remoteDataSource;
    late AppDatabase db;
    late SyncOutboxDao outboxDao;
    late OutboxQueueImpl outboxQueue;
    late RecipeTestRepository repository;

    setUp(() {
      localDataSource = InMemoryLocalSyncDataSource();
      remoteDataSource = FakeRemoteSyncDataSource();
      final executor = DatabaseConnectionFactory.createInMemoryConnection();
      db = AppDatabase(executor);
      outboxDao = SyncOutboxDao(db);
      outboxQueue = OutboxQueueImpl(dao: outboxDao);

      repository = RecipeTestRepository(
        localDataSource: localDataSource,
        remoteDataSource: remoteDataSource,
        outboxQueue: outboxQueue,
        conflictStrategy: const ManualConflictStrategy(),
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('Conflict creation preserves local entity without silent overwrite', () async {
      final baseTime = DateTime.parse('2026-10-25T08:00:00Z');

      // 1. Initial synced state in both local and remote
      final initialRecipe = ConflictTestRecipe(
        id: 'rec_101',
        title: 'Moong Dal Khichdi',
        instructions: 'Cook with 1 tsp ghee and cumin.',
        calories: 320,
        isSynced: true,
        updatedAt: baseTime,
        version: 1,
      );
      await localDataSource.saveLocal(initialRecipe, isSynced: true);
      await remoteDataSource.pushUpsert(initialRecipe, idempotencyKey: 'init_push_101');

      // 2. User edits locally while offline (optimistic write, isSynced: false)
      final localEdit = ConflictTestRecipe(
        id: 'rec_101',
        title: 'Moong Dal Khichdi (Low Ghee)',
        instructions: 'Cook with tadka of jeera and hing, no ghee.',
        calories: 280,
        isSynced: false,
        updatedAt: baseTime.add(const Duration(minutes: 15)),
        version: 2,
      );
      await repository.save(localEdit);

      // 3. Concurrent edit occurred on remote from another device
      final remoteConcurrentEdit = ConflictTestRecipe(
        id: 'rec_101',
        title: 'Moong Dal Khichdi (Ayurvedic Pitta-Pacifying)',
        instructions: 'Cook with fresh coriander, ghee, and turmeric.',
        calories: 340,
        isSynced: true,
        updatedAt: baseTime.add(const Duration(minutes: 20)),
        version: 2,
      );
      await remoteDataSource.pushUpsert(remoteConcurrentEdit, idempotencyKey: 'remote_push_101');

      // 4. Remote fetch and merge detects conflict
      final mergeResult = await repository.fetchAndMerge('rec_101');

      // Must result in FailureResult containing ConflictFailure (FK-3003)
      expect(mergeResult, isA<FailureResult>());
      final failure = (mergeResult as FailureResult).failure;
      expect(failure, isA<ConflictFailure>());
      expect((failure as ConflictFailure).code, equals('FK-3003'));

      // CRITICAL INVARIANT: Local changes MUST NOT be silently overwritten!
      final preservedLocal = await localDataSource.getById('rec_101');
      expect(preservedLocal, isNotNull);
      expect(preservedLocal!.title, equals('Moong Dal Khichdi (Low Ghee)'));
      expect(preservedLocal.calories, equals(280));
      expect(preservedLocal.isSynced, isFalse);
    });

    test('Conflict reports to SyncCoordinator and surfaces SyncStatus.conflict', () async {
      final baseTime = DateTime.parse('2026-10-25T08:00:00Z');

      final localRecipe = ConflictTestRecipe(
        id: 'rec_202',
        title: 'Palak Paneer (High Protein)',
        instructions: '200g paneer in spinach puree',
        isSynced: false,
        updatedAt: baseTime.add(const Duration(minutes: 5)),
        version: 2,
      );
      await repository.save(localRecipe);

      // Inject ConflictFailure on next remote push
      remoteDataSource.nextFailure = ConflictFailure(
        message: 'Concurrent version conflict on cloud',
        details: {
          'entity_type': 'custom_recipe',
          'local_entity': localRecipe.toRemoteJson(),
          'remote_entity': {
            'id': localRecipe.syncId,
            'title': 'Palak Paneer (Restaurant Style)',
            'version': 3,
          },
        },
      );

      final syncWorker = RepositorySyncWorker();
      syncWorker.registerHandler(
        'custom_recipe',
        RepositoryEntitySyncHandler<ConflictTestRecipe, String>(
          repository: repository,
          parseId: (id) => id,
          deserializePayload: (json) => ConflictTestRecipe.fromJson(json),
        ),
      );

      final fakeConnectivity = FakeConnectivityService(initialConnected: true);
      final coordinator = SyncCoordinator(
        outboxQueue: outboxQueue,
        connectivityService: fakeConnectivity,
        syncWorker: syncWorker,
      );

      // Trigger sync
      await coordinator.triggerSync();

      // Coordinator transitions to SyncStatus.conflict with FK-3003
      expect(coordinator.currentStatus, equals(SyncStatus.conflict));
      expect(coordinator.state.errorCode, equals('FK-3003'));
      expect(coordinator.state.conflictDetails, isNotNull);

      coordinator.dispose();
      fakeConnectivity.dispose();
    });
  });

  group('Conflict Resolution Paths (Keep Mine, Keep Server, Merge)', () {
    late InMemoryLocalSyncDataSource<ConflictTestRecipe, String> localDataSource;
    late FakeRemoteSyncDataSource<ConflictTestRecipe, String> remoteDataSource;
    late AppDatabase db;
    late SyncOutboxDao outboxDao;
    late OutboxQueueImpl outboxQueue;
    late RecipeTestRepository repository;

    setUp(() {
      localDataSource = InMemoryLocalSyncDataSource();
      remoteDataSource = FakeRemoteSyncDataSource();
      final executor = DatabaseConnectionFactory.createInMemoryConnection();
      db = AppDatabase(executor);
      outboxDao = SyncOutboxDao(db);
      outboxQueue = OutboxQueueImpl(dao: outboxDao);

      repository = RecipeTestRepository(
        localDataSource: localDataSource,
        remoteDataSource: remoteDataSource,
        outboxQueue: outboxQueue,
      );
    });

    tearDown(() async {
      await db.close();
    });

    test('Keep Mine path preserves local state, increments version, and enqueues push', () async {
      final localRecipe = ConflictTestRecipe(
        id: 'rec_301',
        title: 'Oats Idli (My Recipe)',
        instructions: 'Steamed with veggies and mustard seeds',
        calories: 180,
        isSynced: false,
        updatedAt: DateTime.now(),
        version: 1,
      );
      await localDataSource.saveLocal(localRecipe, isSynced: false);

      final serverRecipe = ConflictTestRecipe(
        id: 'rec_301',
        title: 'Oats Idli (Cloud Version)',
        instructions: 'Plain oats and curd',
        calories: 160,
        isSynced: true,
        updatedAt: DateTime.now(),
        version: 2,
      );

      // Resolve with keepMine
      final result = await repository.resolveConflict(
        id: 'rec_301',
        choice: ConflictUserChoice.keepMine,
        serverEntity: serverRecipe,
      );

      expect(result, isA<Success<ConflictTestRecipe>>());
      final resolved = (result as Success<ConflictTestRecipe>).data;
      expect(resolved.title, equals('Oats Idli (My Recipe)'));
      expect(resolved.version, equals(2));
      expect(resolved.isSynced, isFalse);

      // Verify outbox queue has a new mutation
      final pendingOps = await outboxQueue.getEligibleOperations();
      expect(pendingOps.any((op) => op.entityId == 'rec_301'), isTrue);
    });

    test('Keep Server path accepts cloud version, sets isSynced: true, and clears outbox', () async {
      final localRecipe = ConflictTestRecipe(
        id: 'rec_302',
        title: 'Quinoa Upma (Old Local)',
        instructions: 'Needs revision',
        calories: 220,
        isSynced: false,
        updatedAt: DateTime.now(),
        version: 1,
      );
      await repository.save(localRecipe);

      // Outbox has 1 pending mutation
      var pendingOps = await outboxQueue.getEligibleOperations();
      expect(pendingOps.length, equals(1));

      final serverRecipe = ConflictTestRecipe(
        id: 'rec_302',
        title: 'Quinoa Upma (Updated from iPad)',
        instructions: 'Perfected recipe with ginger and green chillies',
        calories: 210,
        isSynced: true,
        updatedAt: DateTime.now(),
        version: 3,
      );

      // Resolve with keepServer
      final result = await repository.resolveConflict(
        id: 'rec_302',
        choice: ConflictUserChoice.keepServer,
        serverEntity: serverRecipe,
      );

      expect(result, isA<Success<ConflictTestRecipe>>());
      final resolved = (result as Success<ConflictTestRecipe>).data;
      expect(resolved.title, equals('Quinoa Upma (Updated from iPad)'));
      expect(resolved.isSynced, isTrue);

      // Outbox pending mutation must be cleared/marked success
      pendingOps = await outboxQueue.getEligibleOperations();
      expect(pendingOps.isEmpty, isTrue);
    });

    test('Merge path blends changes, saves locally, and enqueues merged mutation', () async {
      final localRecipe = ConflictTestRecipe(
        id: 'rec_303',
        title: 'Methi Thepla (Family Recipe)',
        instructions: 'Local instruction note: Add sesame seeds',
        calories: 120,
        isSynced: false,
        updatedAt: DateTime.now(),
        version: 1,
      );
      await localDataSource.saveLocal(localRecipe, isSynced: false);

      final serverRecipe = ConflictTestRecipe(
        id: 'rec_303',
        title: 'Methi Thepla (Adjusted Macros)',
        instructions: 'Cloud note: Low oil',
        calories: 95,
        isSynced: true,
        updatedAt: DateTime.now(),
        version: 2,
      );

      // Blended entity taking title from local and calibrated calories from server
      final mergedRecipe = ConflictTestRecipe(
        id: 'rec_303',
        title: 'Methi Thepla (Family Recipe - Low Oil)',
        instructions: 'Add sesame seeds; Cook with minimal oil',
        calories: 95,
        isSynced: false,
        updatedAt: DateTime.now(),
        version: 2,
      );

      // Resolve with merge
      final result = await repository.resolveConflict(
        id: 'rec_303',
        choice: ConflictUserChoice.merge,
        serverEntity: serverRecipe,
        mergedEntity: mergedRecipe,
      );

      expect(result, isA<Success<ConflictTestRecipe>>());
      final resolved = (result as Success<ConflictTestRecipe>).data;
      expect(resolved.title, equals('Methi Thepla (Family Recipe - Low Oil)'));
      expect(resolved.calories, equals(95));
      expect(resolved.version, equals(3));
      expect(resolved.isSynced, isFalse);

      final pendingOps = await outboxQueue.getEligibleOperations();
      expect(pendingOps.any((op) => op.entityId == 'rec_303'), isTrue);
    });
  });
}
