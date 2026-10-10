import 'package:fitkarma/core/supabase/supabase_service_boundary.dart';

/// Status of an account deletion request under DPDP regulations.
enum DeletionRequestStatus {
  pending,
  processing,
  completed,
  cancelled;

  String get displayName => switch (this) {
        DeletionRequestStatus.pending => 'Pending Grace Period',
        DeletionRequestStatus.processing => 'Processing Erasure',
        DeletionRequestStatus.completed => 'Completed',
        DeletionRequestStatus.cancelled => 'Cancelled',
      };
}

/// Strongly-typed receipt returned by the client boundary upon requesting
/// account erasure and local data wipe.
class AccountDeletionReceipt {
  final String requestId;
  final String userId;
  final String? reason;
  final DateTime requestedAt;
  final DateTime scheduledPurgeAt;
  final DeletionRequestStatus status;
  final bool localDataWiped;

  const AccountDeletionReceipt({
    required this.requestId,
    required this.userId,
    this.reason,
    required this.requestedAt,
    required this.scheduledPurgeAt,
    required this.status,
    required this.localDataWiped,
  });

  bool get isGracePeriodActive =>
      status == DeletionRequestStatus.pending &&
      DateTime.now().isBefore(scheduledPurgeAt);

  Map<String, dynamic> toJson() => {
        'request_id': requestId,
        'user_id': userId,
        'reason': reason,
        'requested_at': requestedAt.toIso8601String(),
        'scheduled_purge_at': scheduledPurgeAt.toIso8601String(),
        'status': status.name,
        'local_data_wiped': localDataWiped,
      };

  factory AccountDeletionReceipt.fromJson(Map<String, dynamic> json) =>
      AccountDeletionReceipt(
        requestId: json['request_id'] as String,
        userId: json['user_id'] as String,
        reason: json['reason'] as String?,
        requestedAt: DateTime.tryParse(json['requested_at'] as String? ?? '') ??
            DateTime.now(),
        scheduledPurgeAt: DateTime.tryParse(
                json['scheduled_purge_at'] as String? ?? '') ??
            DateTime.now().add(const Duration(days: 30)),
        status: DeletionRequestStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => DeletionRequestStatus.pending,
        ),
        localDataWiped: json['local_data_wiped'] as bool? ?? true,
      );

  AccountDeletionReceipt copyWith({
    String? requestId,
    String? userId,
    String? reason,
    DateTime? requestedAt,
    DateTime? scheduledPurgeAt,
    DeletionRequestStatus? status,
    bool? localDataWiped,
  }) {
    return AccountDeletionReceipt(
      requestId: requestId ?? this.requestId,
      userId: userId ?? this.userId,
      reason: reason ?? this.reason,
      requestedAt: requestedAt ?? this.requestedAt,
      scheduledPurgeAt: scheduledPurgeAt ?? this.scheduledPurgeAt,
      status: status ?? this.status,
      localDataWiped: localDataWiped ?? this.localDataWiped,
    );
  }
}

/// Recovery method types for account access restoration.
enum RecoveryMethod {
  phoneOtp,
  emailLink;
}

/// Status of an account recovery attempt.
enum RecoveryStatus {
  initiated,
  verified,
  failed;
}

/// Request for initiating account recovery.
class AccountRecoveryRequest {
  final String identifier;
  final RecoveryMethod method;

  const AccountRecoveryRequest({
    required this.identifier,
    required this.method,
  });

  Map<String, dynamic> toJson() => {
        'identifier': identifier,
        'method': method.name,
      };
}

/// Receipt returned after initiating or verifying account recovery.
class AccountRecoveryReceipt {
  final String recoveryId;
  final String identifier;
  final RecoveryMethod method;
  final RecoveryStatus status;
  final DateTime initiatedAt;
  final String? message;

  const AccountRecoveryReceipt({
    required this.recoveryId,
    required this.identifier,
    required this.method,
    required this.status,
    required this.initiatedAt,
    this.message,
  });

  Map<String, dynamic> toJson() => {
        'recovery_id': recoveryId,
        'identifier': identifier,
        'method': method.name,
        'status': status.name,
        'initiated_at': initiatedAt.toIso8601String(),
        'message': message,
      };

  factory AccountRecoveryReceipt.fromJson(Map<String, dynamic> json) =>
      AccountRecoveryReceipt(
        recoveryId: json['recovery_id'] as String,
        identifier: json['identifier'] as String,
        method: RecoveryMethod.values.firstWhere(
          (e) => e.name == json['method'],
          orElse: () => RecoveryMethod.phoneOtp,
        ),
        status: RecoveryStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => RecoveryStatus.initiated,
        ),
        initiatedAt: DateTime.tryParse(json['initiated_at'] as String? ?? '') ??
            DateTime.now(),
        message: json['message'] as String?,
      );
}

/// Possible outcomes of a session restoration check.
enum SessionRestorationStatus {
  restored,
  expired,
  noSession,
  failed;
}

/// Comprehensive outcome of session restoration check on app launch.
class SessionRestorationResult {
  final SessionRestorationStatus status;
  final FitKarmaAuthSession? session;
  final String? message;

  const SessionRestorationResult({
    required this.status,
    this.session,
    this.message,
  });

  bool get isSuccessful => status == SessionRestorationStatus.restored;

  @override
  String toString() =>
      'SessionRestorationResult(status: $status, user: ${session?.user.id})';
}

/// Result of local data wiping operations across memory caches and databases.
class LocalWipeResult {
  final bool isSuccess;
  final List<String> wipedStores;
  final DateTime timestamp;
  final String? errorMessage;

  const LocalWipeResult({
    required this.isSuccess,
    required this.wipedStores,
    required this.timestamp,
    this.errorMessage,
  });

  factory LocalWipeResult.success(List<String> stores) => LocalWipeResult(
        isSuccess: true,
        wipedStores: stores,
        timestamp: DateTime.now(),
      );

  factory LocalWipeResult.failure(String error, List<String> partialStores) =>
      LocalWipeResult(
        isSuccess: false,
        wipedStores: partialStores,
        timestamp: DateTime.now(),
        errorMessage: error,
      );

  @override
  String toString() =>
      'LocalWipeResult(success: $isSuccess, stores: $wipedStores)';
}
