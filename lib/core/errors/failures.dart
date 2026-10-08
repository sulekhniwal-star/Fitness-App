/// Central error taxonomy adhering strictly to Brain/error_handling.md.
///
/// Error codes follow the FK-xxxx taxonomy:
/// - FK-1001: Auth (authentication required/expired)
/// - FK-1002: AuthZ (access denied)
/// - FK-2001: Validation (invalid user input)
/// - FK-3001: Offline (queued locally)
/// - FK-3002: Sync (transient sync failure)
/// - FK-3003: Conflict (reconciliation required)
/// - FK-4001: AI (provider/unparseable AI result)
/// - FK-4002: AI (low-confidence result needs confirmation)
/// - FK-5001: Payment (provider request failed)
/// - FK-5002: Payment (verification failed)
/// - FK-5003: Payment (mandate/payment failed)
/// - FK-5004: Payment (webhook duplicate/already processed)
/// - FK-6001: External (third-party dependency unavailable)
/// - FK-7001: Privacy (deletion/export operation failed)
/// - FK-9999: Internal / Unknown failure
sealed class AppFailure implements Exception {
  final String code;
  final String message;
  final bool retryable;
  final String? requestId;
  final Map<String, dynamic>? details;

  const AppFailure({
    required this.code,
    required this.message,
    this.retryable = false,
    this.requestId,
    this.details,
  });

  /// Serializes into the standard FK envelope:
  /// ```json
  /// {
  ///   "code": "FK-XXXX",
  ///   "message": "User-safe message",
  ///   "retryable": false,
  ///   "request_id": "..."
  /// }
  /// ```
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'message': message,
      'retryable': retryable,
      if (requestId != null) 'request_id': requestId,
    };
  }

  /// Parses from standard error JSON envelope.
  static AppFailure fromJson(Map<String, dynamic> json) {
    final code = json['code'] as String? ?? 'FK-9999';
    final rawMessage =
        json['message'] as String? ?? 'An unexpected error occurred.';
    final safeMessage = sanitizeUserMessage(rawMessage);
    final retryable = json['retryable'] as bool? ?? false;
    final requestId = json['request_id'] as String?;

    return switch (code) {
      'FK-1001' => AuthFailure(message: safeMessage, requestId: requestId),
      'FK-1002' => AuthZFailure(message: safeMessage, requestId: requestId),
      'FK-2001' => ValidationFailure(
        message: safeMessage,
        requestId: requestId,
      ),
      'FK-3001' => OfflineFailure(message: safeMessage, requestId: requestId),
      'FK-3002' => SyncFailure(message: safeMessage, requestId: requestId),
      'FK-3003' => ConflictFailure(message: safeMessage, requestId: requestId),
      'FK-4001' => AiFailure(message: safeMessage, requestId: requestId),
      'FK-4002' => AiConfidenceFailure(
        message: safeMessage,
        requestId: requestId,
      ),
      'FK-5001' => PaymentFailure(message: safeMessage, requestId: requestId),
      'FK-5002' => PaymentVerificationFailure(
        message: safeMessage,
        requestId: requestId,
      ),
      'FK-5003' => PaymentMandateFailure(
        message: safeMessage,
        requestId: requestId,
      ),
      'FK-5004' => PaymentDuplicateFailure(
        message: safeMessage,
        requestId: requestId,
      ),
      'FK-6001' => ExternalServiceFailure(
        message: safeMessage,
        requestId: requestId,
      ),
      'FK-7001' => PrivacyFailure(message: safeMessage, requestId: requestId),
      _ => InternalFailure(
        message: safeMessage,
        code: code,
        retryable: retryable,
        requestId: requestId,
      ),
    };
  }

  /// Strips stack traces, credentials, secrets, and raw database errors
  /// to ensure zero sensitive data leaks into user-facing presentation.
  static String sanitizeUserMessage(String raw) {
    var sanitized = raw;

    // Check for stack trace patterns
    if (sanitized.contains('#0') ||
        sanitized.contains('dart:') ||
        sanitized.contains('package:')) {
      return 'An unexpected internal error occurred. Please try again.';
    }

    // Check for database / SQL internals
    final lower = sanitized.toLowerCase();
    if (lower.contains('postgres') ||
        lower.contains('sql') ||
        lower.contains('table') ||
        lower.contains('column') ||
        lower.contains('violates foreign key')) {
      return 'The requested operation could not be completed.';
    }

    // Redact potential secret tokens
    final sensitiveKeywords = [
      'secret',
      'token',
      'key',
      'password',
      'bearer',
      'cvv',
      'pin',
    ];
    for (final kw in sensitiveKeywords) {
      if (lower.contains(kw) && (lower.contains('=') || lower.contains(':'))) {
        return 'A security validation error occurred.';
      }
    }

    return sanitized.trim();
  }

  @override
  String toString() =>
      '$runtimeType(code: $code, message: $message, retryable: $retryable)';
}

/// Authentication failure (FK-1001).
final class AuthFailure extends AppFailure {
  const AuthFailure({
    super.message = 'Authentication required or session expired.',
    super.requestId,
    super.details,
  }) : super(code: 'FK-1001', retryable: false);
}

/// Authorization / Access Denied failure (FK-1002).
final class AuthZFailure extends AppFailure {
  const AuthZFailure({
    super.message =
        'Access denied. You do not have permission for this action.',
    super.requestId,
    super.details,
  }) : super(code: 'FK-1002', retryable: false);
}

/// User input validation failure (FK-2001).
final class ValidationFailure extends AppFailure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    super.message = 'Please review your input and try again.',
    this.fieldErrors,
    super.requestId,
    super.details,
  }) : super(code: 'FK-2001', retryable: false);
}

/// Operation queued locally in offline mode (FK-3001).
final class OfflineFailure extends AppFailure {
  const OfflineFailure({
    super.message =
        'You are currently offline. Changes are saved locally and will sync when connected.',
    super.requestId,
    super.details,
  }) : super(code: 'FK-3001', retryable: true);
}

/// Transient sync failure (FK-3002).
final class SyncFailure extends AppFailure {
  const SyncFailure({
    super.message =
        'Unable to sync with the cloud. Will automatically retry.',
    super.requestId,
    super.details,
  }) : super(code: 'FK-3002', retryable: true);
}

/// Data conflict requiring user reconciliation (FK-3003).
final class ConflictFailure extends AppFailure {
  const ConflictFailure({
    super.message =
        'A conflicting update was detected. Please choose which version to keep.',
    super.requestId,
    super.details,
  }) : super(code: 'FK-3003', retryable: false);
}

/// AI extraction / parse failure (FK-4001).
final class AiFailure extends AppFailure {
  const AiFailure({
    super.message =
        'Could not analyze meal automatically. Please enter your meal details manually.',
    super.requestId,
    super.details,
  }) : super(code: 'FK-4001', retryable: true);
}

/// AI low-confidence estimate requiring confirmation (FK-4002).
final class AiConfidenceFailure extends AppFailure {
  const AiConfidenceFailure({
    super.message =
        'AI recognized portion has ambiguity. Please confirm the portion size.',
    super.requestId,
    super.details,
  }) : super(code: 'FK-4002', retryable: false);
}

/// Payment provider request failure (FK-5001).
final class PaymentFailure extends AppFailure {
  const PaymentFailure({
    super.message =
        'Payment request could not be processed. Please try again.',
    super.requestId,
    super.details,
  }) : super(code: 'FK-5001', retryable: false);
}

/// Payment verification failure (FK-5002).
final class PaymentVerificationFailure extends AppFailure {
  const PaymentVerificationFailure({
    super.message =
        'Payment verification is pending or failed. Entitlement remains unconfirmed.',
    super.requestId,
    super.details,
  }) : super(code: 'FK-5002', retryable: false);
}

/// UPI mandate or recurring payment failure (FK-5003).
final class PaymentMandateFailure extends AppFailure {
  const PaymentMandateFailure({
    super.message =
        'UPI recurring mandate could not be authorized. Please review your UPI app.',
    super.requestId,
    super.details,
  }) : super(code: 'FK-5003', retryable: false);
}

/// Duplicate payment webhook or idempotent request already processed (FK-5004).
final class PaymentDuplicateFailure extends AppFailure {
  const PaymentDuplicateFailure({
    super.message = 'This payment transaction was already processed.',
    super.requestId,
    super.details,
  }) : super(code: 'FK-5004', retryable: false);
}

/// Third-party provider or network unavailability (FK-6001).
final class ExternalServiceFailure extends AppFailure {
  const ExternalServiceFailure({
    super.message =
        'External service is temporarily unavailable. Please try again shortly.',
    super.requestId,
    super.details,
  }) : super(code: 'FK-6001', retryable: true);
}

/// DPDP privacy export or deletion failure (FK-7001).
final class PrivacyFailure extends AppFailure {
  const PrivacyFailure({
    super.message =
        'Data privacy request could not be completed. Please retry or contact support.',
    super.requestId,
    super.details,
  }) : super(code: 'FK-7001', retryable: false);
}

/// Internal unexpected failure (FK-9999).
final class InternalFailure extends AppFailure {
  const InternalFailure({
    super.message = 'An unexpected error occurred. Please try again later.',
    super.code = 'FK-9999',
    super.retryable = false,
    super.requestId,
    super.details,
  });
}
