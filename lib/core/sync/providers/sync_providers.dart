import 'package:fitkarma/core/sync/connectivity/connectivity_service.dart';
import 'package:fitkarma/core/sync/coordinator/sync_coordinator.dart';
import 'package:fitkarma/core/sync/coordinator/sync_worker.dart';
import 'package:fitkarma/core/sync/models/sync_state.dart';
import 'package:fitkarma/core/sync/outbox/outbox_providers.dart';
import 'package:fitkarma/core/sync/sync_boundary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for network connectivity monitoring.
final connectivityServiceProvider = Provider<IConnectivityService>((ref) {
  final service = ConnectivityServiceImpl();
  ref.onDispose(service.dispose);
  return service;
}, name: 'connectivityServiceProvider');

/// Provider for remote endpoint sync worker.
final syncWorkerProvider = Provider<ISyncWorker>((ref) {
  return const DefaultSyncWorker();
}, name: 'syncWorkerProvider');

/// Provider for the central [SyncCoordinator].
final syncCoordinatorProvider =
    StateNotifierProvider<SyncCoordinator, SyncState>((ref) {
  final outboxQueue = ref.watch(outboxQueueProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);
  final syncWorker = ref.watch(syncWorkerProvider);

  return SyncCoordinator(
    outboxQueue: outboxQueue,
    connectivityService: connectivityService,
    syncWorker: syncWorker,
  );
}, name: 'syncCoordinatorProvider');

/// Stream provider for reactive [SyncState] changes.
final syncStateStreamProvider = StreamProvider<SyncState>((ref) {
  final coordinator = ref.watch(syncCoordinatorProvider.notifier);
  return coordinator.stateStream;
}, name: 'syncStateStreamProvider');

/// Provider exposing the current [SyncStatus] directly.
final syncStatusProvider = Provider<SyncStatus>((ref) {
  return ref.watch(syncCoordinatorProvider).status;
}, name: 'syncStatusProvider');
