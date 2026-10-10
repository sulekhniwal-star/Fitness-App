import 'dart:async';
import 'package:fitkarma/core/sync/connectivity/connectivity_service.dart';
import 'package:fitkarma/core/sync/coordinator/sync_worker.dart';
import 'package:fitkarma/core/sync/models/sync_state.dart';
import 'package:fitkarma/core/sync/outbox/models/outbox_models.dart';
import 'package:fitkarma/core/sync/outbox/outbox_queue.dart';
import 'package:fitkarma/core/sync/sync_boundary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Coordinator orchestrating the offline synchronization state machine.
///
/// Implements state transitions:
/// idle -> syncing -> synced
///                -> error
///                -> conflict
class SyncCoordinator extends StateNotifier<SyncState> implements SyncEngine {
  final IOutboxQueue _queue;
  final IConnectivityService _connectivity;
  final ISyncWorker _worker;

  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();

  StreamSubscription<bool>? _connectivitySubscription;
  Timer? _retryTimer;
  bool _isCancelled = false;

  SyncCoordinator({
    required IOutboxQueue outboxQueue,
    required IConnectivityService connectivityService,
    ISyncWorker syncWorker = const DefaultSyncWorker(),
  })  : _queue = outboxQueue,
        _connectivity = connectivityService,
        _worker = syncWorker,
        super(SyncState.initial(isOnline: connectivityService.isConnected)) {
    _init();
  }

  void _init() {
    // Listen to network transitions: automatically resume sync on reconnect
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((isOnline) {
      if (!mounted) return;
      _updateState(state.copyWith(isOnline: isOnline));

      if (isOnline) {
        // Reconnected to network: trigger sync
        triggerSync();
      } else {
        // Lost network: cancel any active retry timer
        _retryTimer?.cancel();
      }
    });

    // Recover any operations left in 'processing' state from previous process interruptions
    recoverInterruptedOperations();
  }

  @override
  SyncStatus get currentStatus => state.status;

  /// Reactive stream of detailed [SyncState] changes.
  Stream<SyncState> get stateStream => stream;

  @override
  Stream<SyncStatus> get statusStream => _statusController.stream;

  void _updateState(SyncState newState) {
    if (!mounted) return;
    final statusChanged = state.status != newState.status;
    state = newState;
    if (statusChanged) {
      _statusController.add(state.status);
    }
  }

  /// Recovers operations that were in 'processing' state when the app was interrupted.
  Future<void> recoverInterruptedOperations() async {
    try {
      final eligible = await _queue.getEligibleOperations();
      _updateState(state.copyWith(pendingCount: eligible.length));
    } catch (_) {
      // Safe non-blocking recovery
    }
  }

  @override
  Future<void> triggerSync() async {
    if (!mounted) return;

    // 1. Guard against concurrent sync cycles
    if (state.status == SyncStatus.syncing) {
      return;
    }

    // 2. Connectivity check
    final isConnected = await _connectivity.checkConnectivity();
    if (!isConnected) {
      final pending = await _queue.getEligibleOperations();
      _updateState(
        state.copyWith(
          status: SyncStatus.idle,
          isOnline: false,
          pendingCount: pending.length,
          errorMessage: 'Device is offline. Changes are saved locally.',
          errorCode: 'FK-3001',
        ),
      );
      return;
    }

    // 3. Reset cancellation flag and transition to syncing
    _isCancelled = false;
    _retryTimer?.cancel();

    final eligibleOperations = await _queue.getEligibleOperations();
    if (eligibleOperations.isEmpty) {
      // Zero pending operations -> cleanly synced
      _updateState(
        state.copyWith(
          status: SyncStatus.synced,
          pendingCount: 0,
          activeOperationId: null,
          lastSyncedAt: DateTime.now(),
          errorMessage: null,
          errorCode: null,
        ),
      );
      return;
    }

    _updateState(
      state.copyWith(
        status: SyncStatus.syncing,
        pendingCount: eligibleOperations.length,
        errorMessage: null,
        errorCode: null,
      ),
    );

    // 4. Sequentially process outbox queue with cancellation and error checks
    for (final op in eligibleOperations) {
      if (_isCancelled || !mounted) {
        // Safe cancellation interruption
        _updateState(state.copyWith(status: SyncStatus.idle));
        return;
      }

      _updateState(state.copyWith(activeOperationId: op.id));
      await _queue.markProcessing(op.id);

      final result = await _worker.processOperation(op);

      switch (result.status) {
        case SyncDispatchStatus.success:
          await _queue.markSuccess(op.id);
          break;

        case SyncDispatchStatus.transientFailure:
          // Mark failure with exponential backoff calculation
          final delay = op.calculateExponentialBackoff();
          await _queue.markRetryableFailure(
            op.id,
            error: result.errorMessage ?? 'Transient synchronization error',
            errorCode: result.errorCode ?? 'FK-3002',
            backoffDelay: delay,
          );

          final remaining = await _queue.getEligibleOperations();
          _updateState(
            state.copyWith(
              status: SyncStatus.error,
              pendingCount: remaining.length,
              errorMessage: result.errorMessage ?? 'Temporary sync failure',
              errorCode: result.errorCode ?? 'FK-3002',
            ),
          );

          // Schedule automatic retry timer after backoff
          _scheduleRetry(delay);
          return;

        case SyncDispatchStatus.permanentFailure:
          // Non-retryable error (e.g. FK-2001 validation failure)
          await _queue.markPermanentFailure(
            op.id,
            error: result.errorMessage ?? 'Permanent mutation rejection',
            errorCode: result.errorCode ?? 'FK-2001',
          );

          final remaining = await _queue.getEligibleOperations();
          _updateState(
            state.copyWith(
              status: SyncStatus.error,
              pendingCount: remaining.length,
              errorMessage: result.errorMessage ?? 'Permanent sync failure',
              errorCode: result.errorCode ?? 'FK-2001',
            ),
          );
          return;

        case SyncDispatchStatus.conflict:
          // Conflict detected -> transition to SyncStatus.conflict
          _updateState(
            state.copyWith(
              status: SyncStatus.conflict,
              errorMessage: result.errorMessage ?? 'Sync conflict detected',
              errorCode: result.errorCode ?? 'FK-3003',
              conflictDetails: result.conflictDetails,
            ),
          );
          return;
      }
    }

    // 5. All operations in the batch processed successfully
    final remainingAfterBatch = await _queue.getEligibleOperations();
    if (remainingAfterBatch.isEmpty) {
      _updateState(
        state.copyWith(
          status: SyncStatus.synced,
          pendingCount: 0,
          activeOperationId: null,
          lastSyncedAt: DateTime.now(),
          errorMessage: null,
          errorCode: null,
        ),
      );
    } else {
      _updateState(
        state.copyWith(
          status: SyncStatus.idle,
          pendingCount: remainingAfterBatch.length,
          activeOperationId: null,
        ),
      );
    }
  }

  void _scheduleRetry(Duration delay) {
    _retryTimer?.cancel();
    _retryTimer = Timer(delay, () {
      if (mounted && _connectivity.isConnected) {
        triggerSync();
      }
    });
  }

  /// Cancels an in-flight synchronization cycle gracefully.
  void cancelSync() {
    _isCancelled = true;
    _retryTimer?.cancel();
    if (state.status == SyncStatus.syncing) {
      _updateState(state.copyWith(status: SyncStatus.idle));
    }
  }

  @override
  Future<void> enqueueOperation({
    required String entityType,
    required String operationType,
    required Map<String, dynamic> payload,
    required String idempotencyKey,
    String? entityId,
    Map<String, dynamic>? metadata,
  }) async {
    final result = await _queue.enqueue(
      entityType: entityType,
      entityId: entityId ?? payload['id']?.toString() ?? 'anonymous',
      operationType: OutboxOperationType.fromString(operationType),
      payload: payload,
      idempotencyKey: idempotencyKey,
      metadata: metadata,
    );

    final pending = await _queue.getEligibleOperations();
    _updateState(state.copyWith(pendingCount: pending.length));

    // If online, proactively trigger sync
    if (_connectivity.isConnected && result.isNew) {
      triggerSync();
    }
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _connectivitySubscription?.cancel();
    _statusController.close();
    super.dispose();
  }
}
