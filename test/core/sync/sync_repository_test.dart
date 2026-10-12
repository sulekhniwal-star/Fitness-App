import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:fitkarma/core/database/app_database.dart';
import 'package:fitkarma/core/database/drift_local_database.dart';
import 'package:fitkarma/core/errors/failures.dart';
import 'package:fitkarma/core/sync/connectivity/connectivity_service.dart';
import 'package:fitkarma/core/sync/coordinator/sync_coordinator.dart';
import 'package:fitkarma/core/sync/outbox/models/outbox_models.dart';
import 'package:fitkarma/core/sync/outbox/outbox_queue_impl.dart';
import 'package:fitkarma/core/sync/repository/conflict_strategy.dart';
import 'package:fitkarma/core/sync/repository/drift_sync_adapter.dart';
import 'package:fitkarma/core/sync/repository/local_data_source.dart';
import 'package:fitkarma/core/sync/repository/remote_data_source.dart';
import 'package:fitkarma/core/sync/repository/repository_sync_worker.dart';
import 'package:fitkarma/core/sync/repository/sync_entity.dart';
import 'package:fitkarma/core/sync/repository/sync_repository.dart';
import 'package:fitkarma/core/sync/sync_boundary.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test entity implementing [SyncEntity].
class TestItem implements SyncEntity<String> {
  final String id;
  final String name;
  final int count;
  @override
  final bool isSynced;
  final DateTime updatedAt;
  @override
  final DateTime? lastSyncedAt;
  final int? version;

  TestItem({
    required this.id,
    required this.name,
    this.count = 0,
    this.isSynced = true,
    required this.updatedAt,
    this.lastSyncedAt,
    this.version,
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
        'name': name,
        'count': count,
        'updated_at': updatedAt.toIso8601String(),
        if (version != null) 'version': version,
      };

  factory TestItem.fromJson(Map<String, dynamic> json) => TestItem(
        id: json['id'] as String,
        name: json['name'] as String,
        count: json['count'] as int? ?? 0,
        isSynced: true,
        updatedAt: DateTime.parse(json['updated_at'] as String),
        lastSyncedAt: json['last_synced_at'] != null
            ? DateTime.parse(json['last_synced_at'] as String)
            : null,
        version: json['version'] as int?,
      );

  @override
  TestItem copyWithSyncMetadata({
    bool? isSynced,
    DateTime? lastSyncedAt,
    int? syncVersion,
    DateTime? syncUpdatedAt,
  }) {
    return TestItem(
      id: id,
      name: name,
      count: count,
      isSynced: isSynced ?? this.isSynced,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      version: syncVersion ?? version,
      updatedAt: syncUpdatedAt ?? updatedAt,
    );
  }
}

/// Concrete test repository inheriting from [SyncRepository].
class TestItemSyncRepository extends SyncRepository<TestItem, String> {
  TestItemSyncRepository({
    required super.localDataSource,
    required super.remoteDataSource,
    required super.outboxQueue,
    super.conflictStrategy = const TimestampLastWriteWinsStrategy(),
    super.entityType = 'test_item',
  });
}

void main() {
  group('SyncRepository Drift + Supabase Reusable Synchronization Tests', () {
    late DriftLocalDatabase localDb;
    late OutboxQueueImpl outboxQueue;
    late InMemoryLocalSyncDataSource<TestItem, String> localDataSource;
    late FakeRemoteSyncDataSource<TestItem, String> remoteDataSource;
    late TestItemSyncRepository repository;

    final t0 = DateTime(2026, 10, 12, 10, 0, 0);
    final t1 = DateTime(2026, 10, 12, 10, 5, 0);
    final t2 = DateTime(2026, 10, 12, 10, 10, 0);

    setUp(() async {
      localDb = DriftLocalDatabase.inMemory();
      await localDb.initialize(encryptionKey: 'test_passphrase_sync_repo');
      outboxQueue = OutboxQueueImpl(dao: localDb.syncOutboxDao);

      localDataSource = InMemoryLocalSyncDataSource<TestItem, String>();
      remoteDataSource = FakeRemoteSyncDataSource<TestItem, String>();

      repository = TestItemSyncRepository(
        localDataSource: localDataSource,
        remoteDataSource: remoteDataSource,
        outboxQueue: outboxQueue,
      );
    });

    tearDown(() async {
      await localDb.close();
    });

    test('1. Local Source of Truth: reads and reactive stream return local data without remote fetch',
        () async {
      final initialItem = TestItem(
        id: 'item_1',
        name: 'Local Banana',
        count: 5,
        updatedAt: t0,
        isSynced: true,
      );
      await localDataSource.saveLocal(initialItem, isSynced: true);

      // Verify read returns from local source of truth
      final getResult = await repository.get('item_1');
      expect(getResult.isSuccess, isTrue);
      expect(getResult.dataOrNull?.name, equals('Local Banana'));

      // Verify watch stream observes local updates
      final streamFuture = expectLater(
        repository.watch('item_1'),
        emitsInOrder([
          predicate<TestItem?>((item) => item?.name == 'Local Banana'),
          predicate<TestItem?>((item) => item?.name == 'Updated Local Banana'),
        ]),
      );

      // Mutate locally
      final updatedItem = TestItem(
        id: 'item_1',
        name: 'Updated Local Banana',
        count: 8,
        updatedAt: t1,
        isSynced: true,
      );
      await localDataSource.saveLocal(updatedItem, isSynced: true);

      await streamFuture;
    });

    test('2. Outbox Push: save performs optimistic local write and enqueues outbox operation',
        () async {
      final newItem = TestItem(
        id: 'item_2',
        name: 'Masala Chai',
        count: 2,
        updatedAt: t1,
        isSynced: true,
      );

      final saveResult = await repository.save(newItem);
      expect(saveResult.isSuccess, isTrue);

      // 1. Local state updated optimistically with isSynced: false
      final localCopy = await localDataSource.getById('item_2');
      expect(localCopy, isNotNull);
      expect(localCopy!.isSynced, isFalse);
      expect(localCopy.name, equals('Masala Chai'));

      // 2. Outbox operation enqueued
      final pendingOps = await outboxQueue.getEligibleOperations();
      expect(pendingOps.length, equals(1));
      expect(pendingOps.first.entityType, equals('test_item'));
      expect(pendingOps.first.entityId, equals('item_2'));
      expect(pendingOps.first.operationType, equals(OutboxOperationType.upsert));
      expect(pendingOps.first.payload['name'], equals('Masala Chai'));
    });

    test('3. Remote Fetch & Clean Local Merge: remote overwrites local when no unsynced changes exist',
        () async {
      final remoteItem = TestItem(
        id: 'item_3',
        name: 'Idli Sambar',
        count: 4,
        updatedAt: t1,
        isSynced: true,
      );
      remoteDataSource.remoteStore['item_3'] = remoteItem;

      // Local store initially empty
      final mergeResult = await repository.fetchAndMerge('item_3');
      expect(mergeResult.isSuccess, isTrue);
      expect(mergeResult.dataOrNull?.name, equals('Idli Sambar'));

      // Verified merged into local source of truth with isSynced: true and lastSyncedAt
      final localStored = await localDataSource.getById('item_3');
      expect(localStored, isNotNull);
      expect(localStored!.name, equals('Idli Sambar'));
      expect(localStored.isSynced, isTrue);
      expect(localStored.lastSyncedAt, isNotNull);
    });

    test('4. Duplicate Handling: duplicate idempotency keys do not produce duplicate outbox queue records',
        () async {
      final item = TestItem(
        id: 'item_4',
        name: 'Moong Dal Khichdi',
        count: 1,
        updatedAt: t0,
        isSynced: true,
      );

      const fixedKey = 'idemp_key_khichdi_fixed';

      // First save
      final res1 = await repository.save(item, customIdempotencyKey: fixedKey);
      expect(res1.isSuccess, isTrue);

      // Duplicate save with identical idempotency key
      final res2 = await repository.save(item, customIdempotencyKey: fixedKey);
      expect(res2.isSuccess, isTrue);

      // Queue contains exactly 1 operation
      final pendingOps = await outboxQueue.getEligibleOperations();
      expect(pendingOps.length, equals(1));
    });

    test('5. Timestamp LWW Conflict: remote wins when remote timestamp is newer',
        () async {
      // Local modified at t1 (10:05)
      final localItem = TestItem(
        id: 'item_5',
        name: 'Local Oatmeal (T1)',
        updatedAt: t1,
        isSynced: false,
      );
      await localDataSource.saveLocal(localItem, isSynced: false);

      // Remote modified at t2 (10:10)
      final remoteItem = TestItem(
        id: 'item_5',
        name: 'Remote Oatmeal (T2)',
        updatedAt: t2,
        isSynced: true,
      );
      remoteDataSource.remoteStore['item_5'] = remoteItem;

      // Fetch and merge
      final mergeResult = await repository.fetchAndMerge('item_5');
      expect(mergeResult.isSuccess, isTrue);
      expect(mergeResult.dataOrNull?.name, equals('Remote Oatmeal (T2)'));

      // Local store has remote data with isSynced: true
      final localNow = await localDataSource.getById('item_5');
      expect(localNow?.name, equals('Remote Oatmeal (T2)'));
      expect(localNow?.isSynced, isTrue);
    });

    test('6. Timestamp LWW Conflict: local wins when local timestamp is newer',
        () async {
      // Remote modified at t1 (10:05)
      final remoteItem = TestItem(
        id: 'item_6',
        name: 'Remote Paneer (T1)',
        updatedAt: t1,
        isSynced: true,
      );
      remoteDataSource.remoteStore['item_6'] = remoteItem;

      // Local modified at t2 (10:10)
      final localItem = TestItem(
        id: 'item_6',
        name: 'Local Paneer (T2)',
        updatedAt: t2,
        isSynced: false,
      );
      await localDataSource.saveLocal(localItem, isSynced: false);

      // Fetch and merge
      final mergeResult = await repository.fetchAndMerge('item_6');
      expect(mergeResult.isSuccess, isTrue);
      expect(mergeResult.dataOrNull?.name, equals('Local Paneer (T2)'));

      // Local store preserves local changes with isSynced: false
      final localNow = await localDataSource.getById('item_6');
      expect(localNow?.name, equals('Local Paneer (T2)'));
      expect(localNow?.isSynced, isFalse);
    });

    test('7. Manual Conflict Strategy: reports FK-3003 conflict failure without discarding local changes',
        () async {
      final manualRepo = TestItemSyncRepository(
        localDataSource: localDataSource,
        remoteDataSource: remoteDataSource,
        outboxQueue: outboxQueue,
        conflictStrategy: const ManualConflictStrategy(),
      );

      final localItem = TestItem(
        id: 'item_7',
        name: 'Local Roti',
        updatedAt: t1,
        isSynced: false,
      );
      await localDataSource.saveLocal(localItem, isSynced: false);

      final remoteItem = TestItem(
        id: 'item_7',
        name: 'Remote Roti',
        updatedAt: t2,
        isSynced: true,
      );
      remoteDataSource.remoteStore['item_7'] = remoteItem;

      final mergeResult = await manualRepo.fetchAndMerge('item_7');
      expect(mergeResult.isFailure, isTrue);

      final failure = mergeResult.failureOrNull;
      expect(failure, isA<ConflictFailure>());
      expect(failure?.code, equals('FK-3003'));
      expect(failure?.details?['local_entity']?['name'], equals('Local Roti'));
      expect(failure?.details?['remote_entity']?['name'], equals('Remote Roti'));

      // Local data is preserved (zero data loss)
      final localAfter = await localDataSource.getById('item_7');
      expect(localAfter?.name, equals('Local Roti'));
      expect(localAfter?.isSynced, isFalse);
    });

    test('8. Version Conflict Strategy: higher version number wins',
        () async {
      final versionRepo = TestItemSyncRepository(
        localDataSource: localDataSource,
        remoteDataSource: remoteDataSource,
        outboxQueue: outboxQueue,
        conflictStrategy: const VersionConflictStrategy(),
      );

      // Local version 2
      final localItem = TestItem(
        id: 'item_8',
        name: 'Local Item v2',
        version: 2,
        updatedAt: t1,
        isSynced: false,
      );
      await localDataSource.saveLocal(localItem, isSynced: false);

      // Remote version 3
      final remoteItem = TestItem(
        id: 'item_8',
        name: 'Remote Item v3',
        version: 3,
        updatedAt: t1,
        isSynced: true,
      );
      remoteDataSource.remoteStore['item_8'] = remoteItem;

      final mergeResult = await versionRepo.fetchAndMerge('item_8');
      expect(mergeResult.isSuccess, isTrue);
      expect(mergeResult.dataOrNull?.version, equals(3));
      expect(mergeResult.dataOrNull?.name, equals('Remote Item v3'));
    });

    test('9. Server Acknowledgement: acknowledgePush marks local store synced and completes outbox op',
        () async {
      // 1. Enqueue op
      final item = TestItem(
        id: 'item_9',
        name: 'Palak Paneer',
        count: 1,
        updatedAt: t0,
        isSynced: false,
      );
      await repository.save(item);

      final pending = await outboxQueue.getEligibleOperations();
      expect(pending.length, equals(1));
      final op = pending.first;

      // 2. Server acknowledges
      final acknowledgedRemote = item.copyWithSyncMetadata(
        isSynced: true,
        lastSyncedAt: DateTime.now(),
      );
      await repository.acknowledgePush(
        id: 'item_9',
        serverEntity: acknowledgedRemote,
        operationId: op.id,
      );

      // Local store is marked synced
      final localItem = await localDataSource.getById('item_9');
      expect(localItem?.isSynced, isTrue);
      expect(localItem?.lastSyncedAt, isNotNull);

      // Outbox operation is completed
      final eligibleNow = await outboxQueue.getEligibleOperations();
      expect(eligibleNow.isEmpty, isTrue);
    });

    test('10. End-to-End Coordination: RepositorySyncWorker drains outbox through SyncCoordinator',
        () async {
      final connectivity = FakeConnectivityService(initialConnected: true);
      final syncWorker = RepositorySyncWorker();

      syncWorker.registerRepository<TestItem, String>(
        repository: repository,
        parseId: (s) => s,
        deserializePayload: (json) => TestItem.fromJson(json),
      );

      final coordinator = SyncCoordinator(
        outboxQueue: outboxQueue,
        connectivityService: connectivity,
        syncWorker: syncWorker,
      );

      // Save an item locally (enqueues outbox operation)
      final item = TestItem(
        id: 'item_10',
        name: 'Biryani',
        count: 3,
        updatedAt: t1,
        isSynced: false,
      );
      await repository.save(item);

      expect(coordinator.currentStatus, equals(SyncStatus.idle));
      expect(remoteDataSource.remoteStore.containsKey('item_10'), isFalse);

      // Trigger sync
      await coordinator.triggerSync();

      // State machine should transition to synced
      expect(coordinator.currentStatus, equals(SyncStatus.synced));

      // Remote store received the upsert
      expect(remoteDataSource.remoteStore.containsKey('item_10'), isTrue);
      expect(remoteDataSource.remoteStore['item_10']?.name, equals('Biryani'));

      // Local entity is marked as synced
      final localItem = await localDataSource.getById('item_10');
      expect(localItem?.isSynced, isTrue);

      // Outbox has 0 remaining operations
      final remaining = await outboxQueue.getEligibleOperations();
      expect(remaining.isEmpty, isTrue);

      coordinator.dispose();
      connectivity.dispose();
    });

    test('11. DriftLocalSyncDataSource Adapter: translates Drift profiles table queries and companions correctly',
        () async {
      final profileDao = localDb.profileDao;
      final now = DateTime.now();

      final driftAdapter = DriftLocalSyncDataSource<TestItem, String, LocalProfile, LocalProfilesCompanion>(
        fetchRow: (id) => profileDao.getProfileByUserId(id),
        watchRow: (id) => profileDao.watchProfileByUserId(id),
        fetchAllRows: () async => (await localDb.database.select(localDb.database.localProfiles).get()),
        watchAllRows: () => localDb.database.select(localDb.database.localProfiles).watch(),
        upsertCompanion: (c) => profileDao.upsertProfile(c),
        deleteRow: (id) => profileDao.deleteProfileByUserId(id),
        mapToEntity: (row) => TestItem(
          id: row.userId,
          name: row.displayName,
          count: row.age ?? 0,
          updatedAt: row.updatedAt,
          isSynced: row.isSynced,
          lastSyncedAt: row.lastSyncedAt,
        ),
        mapToCompanion: (entity, {required bool isSynced, DateTime? lastSyncedAt}) =>
            LocalProfilesCompanion.insert(
          id: 'prof_${entity.id}',
          userId: entity.id,
          displayName: entity.name,
          age: Value(entity.count),
          createdAt: entity.updatedAt,
          updatedAt: entity.updatedAt,
          isSynced: Value(isSynced),
          lastSyncedAt: Value(lastSyncedAt),
        ),
      );

      final item = TestItem(
        id: 'user_42',
        name: 'Drift Synchronized User',
        count: 32,
        updatedAt: now,
        isSynced: false,
      );

      // Save through adapter
      await driftAdapter.saveLocal(item, isSynced: false);

      // Check hasUnsyncedChanges
      expect(await driftAdapter.hasUnsyncedChanges('user_42'), isTrue);

      // Retrieve through adapter
      final retrieved = await driftAdapter.getById('user_42');
      expect(retrieved, isNotNull);
      expect(retrieved!.name, equals('Drift Synchronized User'));
      expect(retrieved.isSynced, isFalse);

      // Acknowledge sync
      await driftAdapter.saveLocal(item, isSynced: true, lastSyncedAt: DateTime.now());
      expect(await driftAdapter.hasUnsyncedChanges('user_42'), isFalse);
    });
  });
}
