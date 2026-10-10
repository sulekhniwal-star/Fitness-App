import 'dart:convert';
import 'dart:math';
import 'package:drift/drift.dart' as drift;
import 'package:fitkarma/core/database/app_database.dart';

/// Supported outbox mutation operation types.
enum OutboxOperationType {
  create,
  update,
  delete,
  upsert;

  static OutboxOperationType fromString(String value) {
    return OutboxOperationType.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => OutboxOperationType.upsert,
    );
  }
}

/// Lifecycle statuses for an offline outbox record.
enum OutboxStatus {
  /// Enqueued, awaiting remote synchronization.
  pending,

  /// Currently being processed by sync worker.
  processing,

  /// Acknowledged by remote server and successfully synced.
  completed,

  /// Encountered transient failure, scheduled for exponential retry.
  failed,

  /// Terminal failure (e.g. permanent validation error or retry exhaustion).
  permanentlyFailed;

  static OutboxStatus fromString(String value) {
    return OutboxStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => OutboxStatus.pending,
    );
  }
}

/// Result status when enqueuing an outbox operation.
enum EnqueueStatus {
  /// Operation was freshly enqueued.
  enqueued,

  /// Duplicate idempotency key detected on a pending/processing item.
  duplicatePending,

  /// Duplicate idempotency key detected on an already completed item.
  duplicateCompleted,

  /// Duplicate idempotency key detected on a failed item.
  duplicateFailed,
}

/// Structured outcome of an enqueue operation.
class EnqueueResult {
  final EnqueueStatus status;
  final OutboxOperation operation;

  const EnqueueResult({
    required this.status,
    required this.operation,
  });

  bool get isNew => status == EnqueueStatus.enqueued;
  bool get isDuplicate => !isNew;
}

/// Generic entity representing an offline outbox sync queue operation.
class OutboxOperation {
  /// Unique identifier of this operation (e.g. UUID).
  final String id;

  /// Domain entity type (e.g. 'profile', 'wellness', 'food_log').
  final String entityType;

  /// Identifier of the specific domain entity.
  final String entityId;

  /// The mutation operation type.
  final OutboxOperationType operationType;

  /// The JSON payload to be synchronized.
  final Map<String, dynamic> payload;

  /// Unique idempotency key to prevent double-application.
  final String idempotencyKey;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last updated timestamp.
  final DateTime updatedAt;

  /// Number of sync attempts performed so far.
  final int retryCount;

  /// Maximum allowed retry attempts before permanent failure.
  final int maxRetries;

  /// Current queue status.
  final OutboxStatus status;

  /// Human-readable error message from the last failed attempt.
  final String? lastError;

  /// Error code taxonomy classification (e.g. 'FK-3002', 'FK-2001', 'HTTP 503').
  final String? lastErrorCode;

  /// Optional dependency and reference metadata (e.g. parent references, ordering constraints).
  final Map<String, dynamic>? metadata;

  /// Scheduled timestamp for the next retry attempt.
  final DateTime? nextRetryAt;

  const OutboxOperation({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operationType,
    required this.payload,
    required this.idempotencyKey,
    required this.createdAt,
    required this.updatedAt,
    this.retryCount = 0,
    this.maxRetries = 5,
    this.status = OutboxStatus.pending,
    this.lastError,
    this.lastErrorCode,
    this.metadata,
    this.nextRetryAt,
  });

  /// Whether this operation is eligible to be retried.
  bool get isRetryable =>
      status == OutboxStatus.failed && retryCount < maxRetries;

  /// Whether this operation has failed permanently and will not be auto-retried.
  bool get isPermanentFailure => status == OutboxStatus.permanentlyFailed;

  /// Computes exponential backoff duration based on [retryCount].
  ///
  /// Formula: min(maxDelay, baseDelay * 2^(retryCount))
  Duration calculateExponentialBackoff({
    Duration baseDelay = const Duration(seconds: 2),
    Duration maxDelay = const Duration(minutes: 5),
  }) {
    final factor = pow(2, min(retryCount, 6)).toInt();
    final delayMillis = baseDelay.inMilliseconds * factor;
    final cappedMillis = min(delayMillis, maxDelay.inMilliseconds);
    return Duration(milliseconds: cappedMillis);
  }

  /// Maps a Drift [LocalSyncOutboxData] table row to an [OutboxOperation].
  factory OutboxOperation.fromDbRow(LocalSyncOutboxData row) {
    Map<String, dynamic> parsedPayload = {};
    try {
      parsedPayload = jsonDecode(row.payloadJson) as Map<String, dynamic>;
    } catch (_) {
      parsedPayload = {};
    }

    Map<String, dynamic>? parsedMetadata;
    if (row.metadataJson != null && row.metadataJson!.isNotEmpty) {
      try {
        parsedMetadata = jsonDecode(row.metadataJson!) as Map<String, dynamic>;
      } catch (_) {
        parsedMetadata = null;
      }
    }

    return OutboxOperation(
      id: row.id,
      entityType: row.entityType,
      entityId: row.entityId,
      operationType: OutboxOperationType.fromString(row.operation),
      payload: parsedPayload,
      idempotencyKey: row.idempotencyKey,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      retryCount: row.retryCount,
      maxRetries: row.maxRetries,
      status: OutboxStatus.fromString(row.status),
      lastError: row.lastError,
      lastErrorCode: row.lastErrorCode,
      metadata: parsedMetadata,
      nextRetryAt: row.nextRetryAt,
    );
  }

  /// Converts this operation into a Drift companion for persistence.
  LocalSyncOutboxCompanion toCompanion() {
    return LocalSyncOutboxCompanion(
      id: drift.Value(id),
      entityType: drift.Value(entityType),
      entityId: drift.Value(entityId),
      operation: drift.Value(operationType.name),
      payloadJson: drift.Value(jsonEncode(payload)),
      idempotencyKey: drift.Value(idempotencyKey),
      retryCount: drift.Value(retryCount),
      maxRetries: drift.Value(maxRetries),
      status: drift.Value(status.name),
      lastError: drift.Value(lastError),
      lastErrorCode: drift.Value(lastErrorCode),
      metadataJson:
          drift.Value(metadata != null ? jsonEncode(metadata) : null),
      nextRetryAt: drift.Value(nextRetryAt),
      createdAt: drift.Value(createdAt),
      updatedAt: drift.Value(updatedAt),
    );
  }

  OutboxOperation copyWith({
    String? id,
    String? entityType,
    String? entityId,
    OutboxOperationType? operationType,
    Map<String, dynamic>? payload,
    String? idempotencyKey,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? retryCount,
    int? maxRetries,
    OutboxStatus? status,
    String? lastError,
    String? lastErrorCode,
    Map<String, dynamic>? metadata,
    DateTime? nextRetryAt,
  }) {
    return OutboxOperation(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operationType: operationType ?? this.operationType,
      payload: payload ?? this.payload,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries ?? this.maxRetries,
      status: status ?? this.status,
      lastError: lastError ?? this.lastError,
      lastErrorCode: lastErrorCode ?? this.lastErrorCode,
      metadata: metadata ?? this.metadata,
      nextRetryAt: nextRetryAt ?? this.nextRetryAt,
    );
  }
}
