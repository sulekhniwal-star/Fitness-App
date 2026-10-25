import 'dart:async';
import 'package:fitkarma/core/sync/realtime/models/realtime_event.dart';
import 'package:fitkarma/core/sync/realtime/realtime_service_boundary.dart';

/// Test double simulating Supabase Realtime channel broadcasts and lifecycle transitions.
class FakeRealtimeService implements ISupabaseRealtimeService {
  RealtimeConnectionStatus _status = RealtimeConnectionStatus.disconnected;
  final StreamController<RealtimeConnectionStatus> _statusController =
      StreamController<RealtimeConnectionStatus>.broadcast();

  final Map<String, StreamController<RealtimePayload>> _tableControllers = {};
  final Set<String> activeSubscriptions = {};
  String? connectedUserId;
  Set<String> activeConsentScopes = {};

  int reconnectAttempts = 0;
  bool autoReconnectOnDisconnect = true;

  @override
  RealtimeConnectionStatus get connectionStatus => _status;

  @override
  Stream<RealtimeConnectionStatus> get connectionStatusStream =>
      _statusController.stream;

  @override
  bool get isConnected => _status == RealtimeConnectionStatus.connected;

  void setConnectionStatus(RealtimeConnectionStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _statusController.add(_status);
    }
  }

  @override
  Future<void> connect({
    required String userId,
    Set<String>? consentScopes,
  }) async {
    connectedUserId = userId;
    activeConsentScopes = consentScopes ?? {'base_profile', 'health_tracking'};
    setConnectionStatus(RealtimeConnectionStatus.connecting);

    // Transition to connected
    setConnectionStatus(RealtimeConnectionStatus.connected);
  }

  @override
  Future<void> disconnect() async {
    setConnectionStatus(RealtimeConnectionStatus.disconnected);
    connectedUserId = null;
    activeSubscriptions.clear();
  }

  /// Simulates an unexpected socket drop to test reconnect and fallback behavior.
  void simulateDrop({bool willReconnect = true}) {
    setConnectionStatus(RealtimeConnectionStatus.disconnected);
    if (willReconnect && autoReconnectOnDisconnect) {
      reconnectAttempts++;
      setConnectionStatus(RealtimeConnectionStatus.reconnecting);
      Timer(const Duration(milliseconds: 50), () {
        setConnectionStatus(RealtimeConnectionStatus.connected);
      });
    }
  }

  @override
  Stream<RealtimePayload> subscribeToTable({
    required String table,
    required String userId,
  }) {
    final channelKey = '$table:$userId';
    activeSubscriptions.add(channelKey);

    final controller = _tableControllers.putIfAbsent(
      channelKey,
      () => StreamController<RealtimePayload>.broadcast(),
    );

    return controller.stream;
  }

  /// Injects a realtime change event into the given [table] for [userId].
  void emitPayload({
    required String table,
    required String userId,
    required RealtimePayload payload,
  }) {
    final channelKey = '$table:$userId';
    final controller = _tableControllers[channelKey];
    if (controller != null && !controller.isClosed) {
      controller.add(payload);
    }
  }

  @override
  void dispose() {
    _statusController.close();
    for (final c in _tableControllers.values) {
      c.close();
    }
    _tableControllers.clear();
  }
}
