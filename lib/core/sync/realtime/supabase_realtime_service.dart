import 'dart:async';
import 'dart:math';
import 'package:fitkarma/core/supabase/mock_supabase_service.dart';
import 'package:fitkarma/core/supabase/supabase_client_service.dart';
import 'package:fitkarma/core/supabase/supabase_service_boundary.dart';
import 'package:fitkarma/core/sync/realtime/models/realtime_event.dart';
import 'package:fitkarma/core/sync/realtime/realtime_service_boundary.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Production implementation of [ISupabaseRealtimeService] using Supabase Flutter Realtime channels.
class SupabaseRealtimeService implements ISupabaseRealtimeService {
  final ISupabaseService _supabase;
  RealtimeConnectionStatus _status = RealtimeConnectionStatus.disconnected;

  final StreamController<RealtimeConnectionStatus> _statusController =
      StreamController<RealtimeConnectionStatus>.broadcast();

  final Map<String, RealtimeChannel> _activeChannels = {};
  final Map<String, StreamController<RealtimePayload>> _channelControllers = {};

  String? _currentUserId;
  Set<String> _consentScopes = {};

  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  SupabaseRealtimeService({
    required ISupabaseService supabaseService,
  }) : _supabase = supabaseService;

  @override
  RealtimeConnectionStatus get connectionStatus => _status;

  @override
  Stream<RealtimeConnectionStatus> get connectionStatusStream =>
      _statusController.stream;

  @override
  bool get isConnected => _status == RealtimeConnectionStatus.connected;

  void _setStatus(RealtimeConnectionStatus newStatus) {
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
    _currentUserId = userId;
    _consentScopes = consentScopes ?? const {'base_profile'};
    _reconnectAttempts = 0;
    _reconnectTimer?.cancel();

    if (_supabase.isMock || _supabase is MockSupabaseService) {
      // Mock environment connects immediately
      _setStatus(RealtimeConnectionStatus.connected);
      return;
    }

    _setStatus(RealtimeConnectionStatus.connecting);
    _setStatus(RealtimeConnectionStatus.connected);
  }

  void _handleDisconnect() {
    if (_status == RealtimeConnectionStatus.disconnected) return;

    if (_reconnectAttempts >= _maxReconnectAttempts) {
      // Exceeded max attempts: gracefully degrade to polling/error status
      _setStatus(RealtimeConnectionStatus.error);
      return;
    }

    _reconnectAttempts++;
    _setStatus(RealtimeConnectionStatus.reconnecting);

    final delay = Duration(
      milliseconds: min(
        1000 * pow(2, _reconnectAttempts).toInt(),
        30000,
      ),
    );

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      if (_currentUserId != null) {
        connect(userId: _currentUserId!, consentScopes: _consentScopes);
      }
    });
  }

  @override
  Future<void> disconnect() async {
    _reconnectTimer?.cancel();
    _reconnectAttempts = 0;
    _currentUserId = null;

    final supabase = _supabase;
    if (supabase is SupabaseClientService) {
      final client = supabase.rawClient;
      for (final channel in _activeChannels.values) {
        await client.removeChannel(channel);
      }
      client.realtime.disconnect();
    }

    _activeChannels.clear();
    _setStatus(RealtimeConnectionStatus.disconnected);
  }

  @override
  Stream<RealtimePayload> subscribeToTable({
    required String table,
    required String userId,
  }) {
    final key = '$table:$userId';
    final controller = _channelControllers.putIfAbsent(
      key,
      () => StreamController<RealtimePayload>.broadcast(),
    );

    if (_supabase.isMock || _supabase is MockSupabaseService) {
      return controller.stream;
    }

    if (!_activeChannels.containsKey(key)) {
      final client = (_supabase as SupabaseClientService).rawClient;
      final channel = client
          .channel('public:$key')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: table,
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'user_id',
              value: userId,
            ),
            callback: (PostgresChangePayload payload) {
              final mapped = RealtimePayload(
                schema: payload.schema,
                table: payload.table,
                eventType: RealtimeEventType.fromString(payload.eventType.name),
                newRecord: payload.newRecord,
                oldRecord: payload.oldRecord,
                eventTimestamp: payload.commitTimestamp,
              );
              controller.add(mapped);
            },
          );

      channel.subscribe((status, [error]) {
        switch (status) {
          case RealtimeSubscribeStatus.subscribed:
            _reconnectAttempts = 0;
            _setStatus(RealtimeConnectionStatus.connected);
            break;
          case RealtimeSubscribeStatus.timedOut:
          case RealtimeSubscribeStatus.channelError:
            _handleDisconnect();
            break;
          case RealtimeSubscribeStatus.closed:
            _setStatus(RealtimeConnectionStatus.disconnected);
            break;
        }
      });

      _activeChannels[key] = channel;
    }

    return controller.stream;
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel();
    _statusController.close();
    for (final c in _channelControllers.values) {
      c.close();
    }
    _channelControllers.clear();
    _activeChannels.clear();
  }
}
