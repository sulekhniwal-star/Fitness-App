import 'dart:async';
import 'package:fitkarma/core/sync/coordinator/sync_coordinator.dart';
import 'package:fitkarma/core/sync/realtime/models/realtime_event.dart';
import 'package:fitkarma/core/sync/realtime/realtime_service_boundary.dart';
import 'package:fitkarma/core/sync/repository/sync_entity.dart';
import 'package:fitkarma/core/sync/repository/sync_repository.dart';

/// Handler callback for processing incoming table events.
typedef RealtimeTableHandler = Future<void> Function(RealtimePayload payload);

/// Catch-up callback invoked when connection recovers to reconcile dropped events.
typedef CatchUpPullCallback = Future<void> Function();

/// Bridge orchestrating Supabase Realtime channel subscriptions, RLS user scoping,
/// consent boundaries, outbox deduplication, and graceful degradation to manual/polling sync.
class RealtimeSyncBridge {
  final ISupabaseRealtimeService realtimeService;
  final SyncCoordinator? syncCoordinator;

  final Map<String, RealtimeTableHandler> _tableHandlers = {};
  final Map<String, CatchUpPullCallback> _catchUpCallbacks = {};
  final Map<String, String> _tableConsentRequirements = {};
  final Map<String, StreamSubscription<RealtimePayload>> _channelSubscriptions =
      {};

  StreamSubscription<RealtimeConnectionStatus>? _statusSubscription;
  RealtimeConnectionStatus _previousStatus =
      RealtimeConnectionStatus.disconnected;

  RealtimeSyncBridge({
    required this.realtimeService,
    this.syncCoordinator,
  }) {
    _init();
  }

  void _init() {
    // Monitor connection transitions to handle dropped event catch-up and degradation
    _statusSubscription =
        realtimeService.connectionStatusStream.listen((status) async {
      if (_previousStatus == RealtimeConnectionStatus.reconnecting &&
          status == RealtimeConnectionStatus.connected) {
        // Socket reconnected after an interruption: run catch-up sync for dropped events
        await triggerCatchUpSync();
      } else if (status == RealtimeConnectionStatus.error ||
          status == RealtimeConnectionStatus.disconnected) {
        // Degraded state: Realtime is an optimization; trigger sync engine as fallback
        syncCoordinator?.triggerSync();
      }
      _previousStatus = status;
    });
  }

  /// Registers a [SyncRepository] to receive real-time events for [table].
  ///
  /// Optionally specifies a [requiredConsentScope] (e.g. 'health_tracking')
  /// ensuring sensitive tables are never subscribed to without user consent.
  void registerRepository<TEntity extends SyncEntity<TId>, TId>({
    required String table,
    required SyncRepository<TEntity, TId> repository,
    required TId Function(String idString) parseId,
    required TEntity Function(Map<String, dynamic> json) deserializeEntity,
    String? requiredConsentScope,
  }) {
    final lowerTable = table.toLowerCase();
    if (requiredConsentScope != null) {
      _tableConsentRequirements[lowerTable] = requiredConsentScope;
    }

    _catchUpCallbacks[lowerTable] = () async {
      await repository.pullRemoteChanges();
    };

    _tableHandlers[lowerTable] = (payload) async {
      await repository.applyRealtimeEvent(
        payload: payload,
        parseId: parseId,
        deserializeEntity: deserializeEntity,
      );
    };
  }

  /// Subscribes to all registered table channels for [userId] adhering to [consentScopes].
  Future<void> start({
    required String userId,
    Set<String>? consentScopes,
  }) async {
    final activeScopes = consentScopes ?? const {'base_profile'};

    await realtimeService.connect(
      userId: userId,
      consentScopes: activeScopes,
    );

    // Cancel existing subscriptions if any
    for (final sub in _channelSubscriptions.values) {
      await sub.cancel();
    }
    _channelSubscriptions.clear();

    for (final entry in _tableHandlers.entries) {
      final table = entry.key;
      final handler = entry.value;

      // Consent check: verify if this table requires a specific consent scope
      final requiredScope = _tableConsentRequirements[table];
      if (requiredScope != null && !activeScopes.contains(requiredScope)) {
        // User has not consented to this domain; skip subscription
        continue;
      }

      final stream = realtimeService.subscribeToTable(
        table: table,
        userId: userId,
      );

      final subscription = stream.listen((payload) async {
        try {
          await handler(payload);
        } catch (_) {
          // Failure isolation: realtime handler exceptions do not crash websocket
        }
      });

      _channelSubscriptions[table] = subscription;
    }
  }

  /// Triggers a catch-up sync across all registered repositories to recover dropped events.
  Future<void> triggerCatchUpSync() async {
    for (final catchUp in _catchUpCallbacks.values) {
      try {
        await catchUp();
      } catch (_) {
        // Safe catch-up execution
      }
    }
    await syncCoordinator?.triggerSync();
  }

  /// Stops and unsubscribes all active channels cleanly.
  Future<void> stop() async {
    for (final sub in _channelSubscriptions.values) {
      await sub.cancel();
    }
    _channelSubscriptions.clear();
    await realtimeService.disconnect();
  }

  void dispose() {
    _statusSubscription?.cancel();
    for (final sub in _channelSubscriptions.values) {
      sub.cancel();
    }
    _channelSubscriptions.clear();
  }
}
