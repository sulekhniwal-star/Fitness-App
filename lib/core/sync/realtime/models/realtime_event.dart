/// Types of database mutation events broadcast over Supabase Realtime.
enum RealtimeEventType {
  insert,
  update,
  delete;

  static RealtimeEventType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'INSERT':
        return RealtimeEventType.insert;
      case 'UPDATE':
        return RealtimeEventType.update;
      case 'DELETE':
        return RealtimeEventType.delete;
      default:
        return RealtimeEventType.update;
    }
  }
}

/// Normalized payload from a Supabase Postgres change broadcast.
class RealtimePayload {
  final String schema;
  final String table;
  final RealtimeEventType eventType;
  final Map<String, dynamic> newRecord;
  final Map<String, dynamic> oldRecord;
  final DateTime eventTimestamp;
  final String? clientIdempotencyKey;

  RealtimePayload({
    this.schema = 'public',
    required this.table,
    required this.eventType,
    this.newRecord = const {},
    this.oldRecord = const {},
    DateTime? eventTimestamp,
    String? clientIdempotencyKey,
  })  : eventTimestamp = eventTimestamp ?? DateTime.now(),
        clientIdempotencyKey = clientIdempotencyKey ??
            _extractIdempotencyKey(newRecord, oldRecord);

  static String? _extractIdempotencyKey(
    Map<String, dynamic> newRecord,
    Map<String, dynamic> oldRecord,
  ) {
    if (newRecord.containsKey('client_idempotency_key')) {
      return newRecord['client_idempotency_key'] as String?;
    }
    if (newRecord.containsKey('idempotency_key')) {
      return newRecord['idempotency_key'] as String?;
    }
    final meta = newRecord['metadata'];
    if (meta is Map<String, dynamic> && meta.containsKey('client_idempotency_key')) {
      return meta['client_idempotency_key'] as String?;
    }
    return null;
  }

  /// Primary entity ID extracted from record data.
  String? get entityId {
    if (eventType == RealtimeEventType.delete) {
      return (oldRecord['id'] ?? oldRecord['user_id'])?.toString();
    }
    return (newRecord['id'] ?? newRecord['user_id'])?.toString();
  }

  /// Timestamp of the modification extracted from record data.
  DateTime get recordUpdatedAt {
    final raw = newRecord['updated_at'] ??
        newRecord['created_at'] ??
        oldRecord['updated_at'];
    if (raw is String) {
      return DateTime.tryParse(raw) ?? eventTimestamp;
    }
    return eventTimestamp;
  }

  /// Version or revision number if present in record data.
  int? get recordVersion {
    final ver = newRecord['version'] ?? newRecord['sync_version'];
    if (ver is int) return ver;
    if (ver is num) return ver.toInt();
    return null;
  }

  @override
  String toString() =>
      'RealtimePayload(table: $table, type: $eventType, id: $entityId, at: $eventTimestamp)';
}
