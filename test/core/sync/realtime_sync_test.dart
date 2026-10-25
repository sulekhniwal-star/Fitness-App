import 'package:fitkarma/core/database/drift_local_database.dart';
import 'package:fitkarma/core/sync/connectivity/connectivity_service.dart';
import 'package:fitkarma/core/sync/coordinator/sync_coordinator.dart';
import 'package:fitkarma/core/sync/outbox/outbox_queue_impl.dart';
import 'package:fitkarma/core/sync/realtime/fake_realtime_service.dart';
import 'package:fitkarma/core/sync/realtime/models/realtime_event.dart';
import 'package:fitkarma/core/sync/realtime/realtime_service_boundary.dart';
import 'package:fitkarma/core/sync/realtime/realtime_sync_bridge.dart';
import 'package:fitkarma/core/sync/repository/conflict_strategy.dart';
import 'package:fitkarma/core/sync/repository/local_data_source.dart';
import 'package:fitkarma/core/sync/repository/remote_data_source.dart';
import 'package:fitkarma/core/sync/repository/repository_sync_worker.dart';
import 'package:fitkarma/core/sync/repository/sync_entity.dart';
import 'package:fitkarma/core/sync/repository/sync_repository.dart';
import 'package:fitkarma/core/sync/sync_boundary.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test entity implementing [SyncEntity].
class RealtimeTestEntity implements SyncEntity<String> {
  final String id;
  final String name;
  final int value;
  @override
  final bool isSynced;
  final DateTime updatedAt;
  @override
  final DateTime? lastSyncedAt;
  final int? version;

  RealtimeTestEntity({
    required this.id,
    required this.name,
    this.value = 0,
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
        'value': value,
        'updated_at': updatedAt.toIso8601String(),
        if (version != null) 'version': version,
      };

  factory RealtimeTestEntity.fromJson(Map<String, dynamic> json) =>
      RealtimeTestEntity(
        id: json['id'] as String,
        name: json['name'] as String,
        value: json['value'] as int? ?? 0,
        isSynced: true,
        updatedAt: DateTime.parse(json['updated_at'] as String),
        lastSyncedAt: json['last_synced_at'] != null
            ? DateTime.parse(json['last_synced_at'] as String)
            : null,
        version: json['version'] as int?,
      );

  @override
  RealtimeTestEntity copyWithSyncMetadata({
    bool? isSynced,
    DateTime? lastSyncedAt,
    int? syncVersion,
    DateTime? syncUpdatedAt,
  }) {
    return RealtimeTestEntity(
      id: id,
      name: name,
      value: value,
      isSynced: isSynced ?? this.isSynced,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      version: syncVersion ?? version,
      updatedAt: syncUpdatedAt ?? updatedAt,
    );
  }
}

class TestRealtimeRepository extends SyncRepository<RealtimeTestEntity, String> {
  TestRealtimeRepository({
    required super.localDataSource,
    required super.remoteDataSource,
    required super.outboxQueue,
    super.conflictStrategy = const TimestampLastWriteWinsStrategy(),
    super.entityType = 'realtime_entity',
  });
}

void main() {
  group('Supabase Realtime Sync Engine Integration Tests', () {
    late DriftLocalDatabase localDb;
    late OutboxQueueImpl outboxQueue;
    late InMemoryLocalSyncDataSource<RealtimeTestEntity, String> localDataSource;
    late FakeRemoteSyncDataSource<RealtimeTestEntity, String> remoteDataSource;
    late TestRealtimeRepository repository;
    late FakeRealtimeService realtimeService;
    late FakeConnectivityService connectivityService;
    late SyncCoordinator syncCoordinator;
    late RealtimeSyncBridge bridge;

    final t1 = DateTime(2026, 10, 12, 10, 5, 0);
    final t2 = DateTime(2026, 10, 12, 10, 10, 0);

    setUp(() async {
      localDb = DriftLocalDatabase.inMemory();
      await localDb.initialize(encryptionKey: 'realtime_test_passphrase');
      outboxQueue = OutboxQueueImpl(dao: localDb.syncOutboxDao);

      localDataSource = InMemoryLocalSyncDataSource<RealtimeTestEntity, String>();
      remoteDataSource = FakeRemoteSyncDataSource<RealtimeTestEntity, String>();

      repository = TestRealtimeRepository(
        localDataSource: localDataSource,
        remoteDataSource: remoteDataSource,
        outboxQueue: outboxQueue,
      );

      realtimeService = FakeRealtimeService();
      connectivityService = FakeConnectivityService(initialConnected: true);

      final worker = RepositorySyncWorker();
      worker.registerRepository<RealtimeTestEntity, String>(
        repository: repository,
        parseId: (id) => id,
        deserializePayload: (json) => RealtimeTestEntity.fromJson(json),
      );

      syncCoordinator = SyncCoordinator(
        outboxQueue: outboxQueue,
        connectivityService: connectivityService,
        syncWorker: worker,
      );

      bridge = RealtimeSyncBridge(
        realtimeService: realtimeService,
        syncCoordinator: syncCoordinator,
      );

      bridge.registerRepository<RealtimeTestEntity, String>(
        table: 'realtime_entities',
        repository: repository,
        parseId: (id) => id,
        deserializeEntity: (json) => RealtimeTestEntity.fromJson(json),
        requiredConsentScope: 'health_tracking',
      );
    });

    tearDown(() async {
      bridge.dispose();
      syncCoordinator.dispose();
      connectivityService.dispose();
      realtimeService.dispose();
      await localDb.close();
    });

    test('1. RLS and Consent Scope: channel subscriptions strictly respect user ID and consent boundary',
        () async {
      // User without health_tracking consent should NOT subscribe to health table
      await bridge.start(
        userId: 'usr_alice',
        consentScopes: {'base_profile'},
      );

      expect(realtimeService.connectedUserId, equals('usr_alice'));
      expect(
        realtimeService.activeSubscriptions.contains('realtime_entities:usr_alice'),
        isFalse,
      );

      // User with affirmative health_tracking consent subscribes successfully
      await bridge.start(
        userId: 'usr_alice',
        consentScopes: {'base_profile', 'health_tracking'},
      );

      expect(
        realtimeService.activeSubscriptions.contains('realtime_entities:usr_alice'),
        isTrue,
      );
    });

    test('2. Clean Merge: Realtime insert/update merges cleanly into local Drift store',
        () async {
      await bridge.start(
        userId: 'usr_bob',
        consentScopes: {'base_profile', 'health_tracking'},
      );

      final payload = RealtimePayload(
        table: 'realtime_entities',
        eventType: RealtimeEventType.insert,
        newRecord: {
          'id': 'ent_1',
          'name': 'Live Water Intake',
          'value': 250,
          'updated_at': t1.toIso8601String(),
        },
      );

      realtimeService.emitPayload(
        table: 'realtime_entities',
        userId: 'usr_bob',
        payload: payload,
      );

      // Pump event loop
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final stored = await localDataSource.getById('ent_1');
      expect(stored, isNotNull);
      expect(stored!.name, equals('Live Water Intake'));
      expect(stored.value, equals(250));
      expect(stored.isSynced, isTrue);
    });

    test('3. Outbox Self-Echo Deduplication: broadcasts echoing our own outbox mutations are acknowledged without false conflict',
        () async {
      await bridge.start(
        userId: 'usr_carol',
        consentScopes: {'base_profile', 'health_tracking'},
      );

      const idempotencyKey = 'idemp_unique_mutation_999';

      // 1. User performs local mutation (saved locally with isSynced: false, outbox queued)
      final localMutation = RealtimeTestEntity(
        id: 'ent_2',
        name: 'Local Steps',
        value: 5000,
        updatedAt: t1,
        isSynced: false,
      );
      await repository.save(localMutation, customIdempotencyKey: idempotencyKey);

      final pendingBefore = await outboxQueue.getEligibleOperations();
      expect(pendingBefore.length, equals(1));
      expect(pendingBefore.first.idempotencyKey, equals(idempotencyKey));

      // 2. Server processes and broadcasts the mutation back with our client_idempotency_key
      final selfEchoPayload = RealtimePayload(
        table: 'realtime_entities',
        eventType: RealtimeEventType.update,
        clientIdempotencyKey: idempotencyKey,
        newRecord: {
          'id': 'ent_2',
          'name': 'Local Steps',
          'value': 5000,
          'updated_at': t1.toIso8601String(),
          'client_idempotency_key': idempotencyKey,
        },
      );

      realtimeService.emitPayload(
        table: 'realtime_entities',
        userId: 'usr_carol',
        payload: selfEchoPayload,
      );

      await Future<void>.delayed(const Duration(milliseconds: 20));

      // 3. Local entity is now marked isSynced: true without conflict
      final localAfter = await localDataSource.getById('ent_2');
      expect(localAfter?.isSynced, isTrue);

      // 4. Outbox operation was marked completed (no double-processing)
      final pendingAfter = await outboxQueue.getEligibleOperations();
      expect(pendingAfter.isEmpty, isTrue);
    });

    test('4. Duplicate Events: receiving identical Realtime events twice does not corrupt state or re-enqueue',
        () async {
      await bridge.start(
        userId: 'usr_dan',
        consentScopes: {'base_profile', 'health_tracking'},
      );

      final duplicatePayload = RealtimePayload(
        table: 'realtime_entities',
        eventType: RealtimeEventType.insert,
        newRecord: {
          'id': 'ent_3',
          'name': 'Heart Rate Sample',
          'value': 72,
          'updated_at': t1.toIso8601String(),
        },
      );

      // Emit first time
      realtimeService.emitPayload(
        table: 'realtime_entities',
        userId: 'usr_dan',
        payload: duplicatePayload,
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      // Emit exact duplicate a second time
      realtimeService.emitPayload(
        table: 'realtime_entities',
        userId: 'usr_dan',
        payload: duplicatePayload,
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final stored = await localDataSource.getById('ent_3');
      expect(stored, isNotNull);
      expect(stored!.name, equals('Heart Rate Sample'));
      expect(stored.value, equals(72));

      // Outbox remains clean
      final pending = await outboxQueue.getEligibleOperations();
      expect(pending.isEmpty, isTrue);
    });

    test('5. Reordered Events: stale older event arriving after newer state is safely discarded',
        () async {
      await bridge.start(
        userId: 'usr_eva',
        consentScopes: {'base_profile', 'health_tracking'},
      );

      // 1. Newer event at t2 (10:10) arrives first
      final newerPayload = RealtimePayload(
        table: 'realtime_entities',
        eventType: RealtimeEventType.update,
        newRecord: {
          'id': 'ent_4',
          'name': 'Newer State (T2)',
          'value': 100,
          'updated_at': t2.toIso8601String(),
        },
      );

      realtimeService.emitPayload(
        table: 'realtime_entities',
        userId: 'usr_eva',
        payload: newerPayload,
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final stateAtT2 = await localDataSource.getById('ent_4');
      expect(stateAtT2?.name, equals('Newer State (T2)'));

      // 2. Out-of-order older event at t1 (10:05) arrives later
      final staleOlderPayload = RealtimePayload(
        table: 'realtime_entities',
        eventType: RealtimeEventType.update,
        newRecord: {
          'id': 'ent_4',
          'name': 'Stale Older State (T1)',
          'value': 50,
          'updated_at': t1.toIso8601String(),
        },
      );

      realtimeService.emitPayload(
        table: 'realtime_entities',
        userId: 'usr_eva',
        payload: staleOlderPayload,
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));

      // 3. Stale event discarded: local store retains Newer State (T2)
      final stateAfterStale = await localDataSource.getById('ent_4');
      expect(stateAfterStale?.name, equals('Newer State (T2)'));
      expect(stateAfterStale?.value, equals(100));
    });

    test('6. Dropped Events & Reconnect Recovery: reconnection triggers catch-up pull recovering missed events',
        () async {
      await bridge.start(
        userId: 'usr_frank',
        consentScopes: {'base_profile', 'health_tracking'},
      );

      // Populate remote store with an update that occurred while disconnected
      final remoteMissedItem = RealtimeTestEntity(
        id: 'ent_5',
        name: 'Remote Dropped Event Item',
        value: 999,
        updatedAt: t2,
        isSynced: true,
      );
      remoteDataSource.remoteStore['ent_5'] = remoteMissedItem;

      // 1. Simulate websocket drop and reconnect
      realtimeService.simulateDrop(willReconnect: true);

      // Wait for reconnect and catch-up execution
      await Future<void>.delayed(const Duration(milliseconds: 150));

      // 2. Catch-up pull should have recovered missed entity from remote store
      final recoveredItem = await localDataSource.getById('ent_5');
      expect(recoveredItem, isNotNull);
      expect(recoveredItem!.name, equals('Remote Dropped Event Item'));
      expect(recoveredItem.value, equals(999));
    });

    test('7. Graceful Degradation: permanent Realtime error degrades to sync engine without app disruption',
        () async {
      await bridge.start(
        userId: 'usr_grace',
        consentScopes: {'base_profile', 'health_tracking'},
      );

      // Realtime enters error state (e.g. websocket blocked by corporate firewall or disabled)
      realtimeService.setConnectionStatus(RealtimeConnectionStatus.error);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      // The app remains 100% correct: local mutations and standard sync engine still work
      final localItem = RealtimeTestEntity(
        id: 'ent_6',
        name: 'Offline Item Degraded',
        value: 12,
        updatedAt: t1,
        isSynced: false,
      );
      await repository.save(localItem);

      await syncCoordinator.triggerSync();
      expect(syncCoordinator.currentStatus, equals(SyncStatus.synced));

      final remoteItem = remoteDataSource.remoteStore['ent_6'];
      expect(remoteItem, isNotNull);
      expect(remoteItem!.name, equals('Offline Item Degraded'));
    });
  });
}
