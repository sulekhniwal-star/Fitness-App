/// Base interface for domain entities participating in offline-first synchronization.
abstract interface class SyncEntity<TId> {
  /// Unique identifier of this entity (e.g. UUID String or int).
  TId get syncId;

  /// Timestamp of the last local or remote mutation.
  DateTime get syncUpdatedAt;

  /// Optional optimistic version or revision number for version-based conflict checking.
  int? get syncVersion;

  /// Whether this entity is acknowledged and synchronized with the remote server.
  bool get isSynced;

  /// Timestamp when the remote server last acknowledged this entity.
  DateTime? get lastSyncedAt;

  /// Serializes the entity into a JSON map compatible with the remote Supabase table schema.
  Map<String, dynamic> toRemoteJson();

  /// Creates a copy of this entity with updated synchronization metadata.
  SyncEntity<TId> copyWithSyncMetadata({
    bool? isSynced,
    DateTime? lastSyncedAt,
    int? syncVersion,
    DateTime? syncUpdatedAt,
  });
}
