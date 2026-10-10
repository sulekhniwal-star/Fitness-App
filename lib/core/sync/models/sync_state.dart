import 'package:fitkarma/core/sync/sync_boundary.dart';

/// Observable state representing the current synchronization status.
class SyncState {
  /// Primary state machine status: idle, syncing, synced, error, conflict.
  final SyncStatus status;

  /// Timestamp of the last successful full synchronization.
  final DateTime? lastSyncedAt;

  /// Count of eligible pending/failed operations waiting in outbox.
  final int pendingCount;

  /// Identifier of the specific outbox operation currently being synchronized.
  final String? activeOperationId;

  /// User-safe error description when in [SyncStatus.error].
  final String? errorMessage;

  /// Error code classification (e.g. 'FK-3001', 'FK-3002', 'FK-3003').
  final String? errorCode;

  /// Whether network connectivity is currently available.
  final bool isOnline;

  /// Contextual details when in [SyncStatus.conflict].
  final Map<String, dynamic>? conflictDetails;

  const SyncState({
    required this.status,
    this.lastSyncedAt,
    this.pendingCount = 0,
    this.activeOperationId,
    this.errorMessage,
    this.errorCode,
    this.isOnline = true,
    this.conflictDetails,
  });

  factory SyncState.initial({bool isOnline = true}) {
    return SyncState(
      status: SyncStatus.idle,
      isOnline: isOnline,
    );
  }

  bool get isIdle => status == SyncStatus.idle;
  bool get isSyncing => status == SyncStatus.syncing;
  bool get isSynced => status == SyncStatus.synced;
  bool get isError => status == SyncStatus.error;
  bool get isConflict => status == SyncStatus.conflict;

  SyncState copyWith({
    SyncStatus? status,
    DateTime? lastSyncedAt,
    int? pendingCount,
    String? activeOperationId,
    String? errorMessage,
    String? errorCode,
    bool? isOnline,
    Map<String, dynamic>? conflictDetails,
  }) {
    return SyncState(
      status: status ?? this.status,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      pendingCount: pendingCount ?? this.pendingCount,
      activeOperationId: activeOperationId,
      errorMessage: errorMessage,
      errorCode: errorCode,
      isOnline: isOnline ?? this.isOnline,
      conflictDetails: conflictDetails ?? this.conflictDetails,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SyncState &&
        other.status == status &&
        other.lastSyncedAt == lastSyncedAt &&
        other.pendingCount == pendingCount &&
        other.activeOperationId == activeOperationId &&
        other.errorMessage == errorMessage &&
        other.errorCode == errorCode &&
        other.isOnline == isOnline;
  }

  @override
  int get hashCode => Object.hash(
        status,
        lastSyncedAt,
        pendingCount,
        activeOperationId,
        errorMessage,
        errorCode,
        isOnline,
      );
}
