import 'package:fitkarma/core/sync/outbox/models/outbox_models.dart';

/// Outcome status from a remote sync worker dispatch.
enum SyncDispatchStatus {
  /// Mutation acknowledged successfully by the remote server.
  success,

  /// Transient failure (e.g. timeout, 503, connection dropped); eligible for retry.
  transientFailure,

  /// Terminal failure (e.g. invalid schema, 400 bad request, 403 forbidden); do not retry.
  permanentFailure,

  /// Conflict detected (e.g. concurrent mutation, version discrepancy).
  conflict,
}

/// Structured response from an [ISyncWorker] when processing an outbox operation.
class SyncDispatchResult {
  final SyncDispatchStatus status;
  final Map<String, dynamic>? serverResponse;
  final String? errorMessage;
  final String? errorCode;
  final Map<String, dynamic>? conflictDetails;

  const SyncDispatchResult({
    required this.status,
    this.serverResponse,
    this.errorMessage,
    this.errorCode,
    this.conflictDetails,
  });

  factory SyncDispatchResult.success({Map<String, dynamic>? serverResponse}) {
    return SyncDispatchResult(
      status: SyncDispatchStatus.success,
      serverResponse: serverResponse,
    );
  }

  factory SyncDispatchResult.transientFailure({
    required String errorMessage,
    String? errorCode = 'FK-3002',
  }) {
    return SyncDispatchResult(
      status: SyncDispatchStatus.transientFailure,
      errorMessage: errorMessage,
      errorCode: errorCode,
    );
  }

  factory SyncDispatchResult.permanentFailure({
    required String errorMessage,
    String? errorCode = 'FK-2001',
  }) {
    return SyncDispatchResult(
      status: SyncDispatchStatus.permanentFailure,
      errorMessage: errorMessage,
      errorCode: errorCode,
    );
  }

  factory SyncDispatchResult.conflict({
    required String errorMessage,
    String? errorCode = 'FK-3003',
    Map<String, dynamic>? conflictDetails,
  }) {
    return SyncDispatchResult(
      status: SyncDispatchStatus.conflict,
      errorMessage: errorMessage,
      errorCode: errorCode,
      conflictDetails: conflictDetails,
    );
  }
}

/// Contract interface for remote endpoint mutation dispatchers.
abstract interface class ISyncWorker {
  /// Dispatches an outbox operation to the appropriate remote endpoint.
  Future<SyncDispatchResult> processOperation(OutboxOperation operation);
}

/// Default sync worker that acknowledges operations (used as baseline before Task 023 endpoints).
class DefaultSyncWorker implements ISyncWorker {
  const DefaultSyncWorker();

  @override
  Future<SyncDispatchResult> processOperation(OutboxOperation operation) async {
    // Default pass-through acknowledging operation
    return SyncDispatchResult.success(
      serverResponse: {'synced_at': DateTime.now().toIso8601String()},
    );
  }
}
