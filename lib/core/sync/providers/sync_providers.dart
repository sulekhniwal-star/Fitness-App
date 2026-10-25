import 'package:fitkarma/core/supabase/supabase_providers.dart';
import 'package:fitkarma/core/sync/connectivity/connectivity_service.dart';
import 'package:fitkarma/core/sync/coordinator/sync_coordinator.dart';
import 'package:fitkarma/core/sync/coordinator/sync_worker.dart';
import 'package:fitkarma/core/sync/models/sync_state.dart';
import 'package:fitkarma/core/sync/outbox/outbox_providers.dart';
import 'package:fitkarma/core/sync/realtime/realtime_service_boundary.dart';
import 'package:fitkarma/core/sync/realtime/realtime_sync_bridge.dart';
import 'package:fitkarma/core/sync/realtime/supabase_realtime_service.dart';
import 'package:fitkarma/core/sync/repository/repository_sync_worker.dart';
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
  return ref.watch(repositorySyncWorkerProvider);
}, name: 'syncWorkerProvider');

/// Provider for [RepositorySyncWorker] allowing dynamic entity repository registration.
final repositorySyncWorkerProvider = Provider<RepositorySyncWorker>((ref) {
  return RepositorySyncWorker();
}, name: 'repositorySyncWorkerProvider');

/// Provider for Supabase Realtime channel service.
final realtimeServiceProvider = Provider<ISupabaseRealtimeService>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  final service = SupabaseRealtimeService(supabaseService: supabase);
  ref.onDispose(service.dispose);
  return service;
}, name: 'realtimeServiceProvider');

/// Provider for [RealtimeSyncBridge] coordinating realtime feeds to repositories.
final realtimeSyncBridgeProvider = Provider<RealtimeSyncBridge>((ref) {
  final realtime = ref.watch(realtimeServiceProvider);
  final coordinator = ref.watch(syncCoordinatorProvider.notifier);
  final bridge = RealtimeSyncBridge(
    realtimeService: realtime,
    syncCoordinator: coordinator,
  );
  ref.onDispose(bridge.dispose);
  return bridge;
}, name: 'realtimeSyncBridgeProvider');



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
