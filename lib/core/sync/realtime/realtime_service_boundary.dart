import 'dart:async';
import 'package:fitkarma/core/sync/realtime/models/realtime_event.dart';

/// Connection states for Supabase Realtime websocket subscriptions.
enum RealtimeConnectionStatus {
  /// Websocket is closed/disconnected.
  disconnected,

  /// Websocket is attempting connection.
  connecting,

  /// Connected and subscribed to authenticated channels.
  connected,

  /// Temporarily dropped connection, executing exponential backoff reconnect.
  reconnecting,

  /// Permanent or unrecoverable error state, degraded to polling/manual sync.
  error;

  bool get isConnected => this == RealtimeConnectionStatus.connected;
}

/// Boundary contract for Supabase Realtime channel subscriptions and connection lifecycle.
abstract interface class ISupabaseRealtimeService {
  /// Current connection lifecycle state.
  RealtimeConnectionStatus get connectionStatus;

  /// Reactive stream of connection state transitions.
  Stream<RealtimeConnectionStatus> get connectionStatusStream;

  /// Whether the realtime websocket is actively connected.
  bool get isConnected;

  /// Establishes authenticated, RLS-scoped realtime subscriptions.
  ///
  /// Subscriptions are strictly isolated by [userId] and filtered by [consentScopes].
  /// If the user is unauthenticated or has not consented to a scope, channels in that
  /// domain are omitted.
  Future<void> connect({
    required String userId,
    Set<String>? consentScopes,
  });

  /// Closes active websocket connections and unsubscribes all channels cleanly.
  Future<void> disconnect();

  /// Subscribes to database change events for a specific [table] filtered by [userId].
  Stream<RealtimePayload> subscribeToTable({
    required String table,
    required String userId,
  });

  /// Releases resources and cleans up stream controllers.
  void dispose();
}
