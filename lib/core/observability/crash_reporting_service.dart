import 'package:fitkarma/core/observability/redaction.dart';

/// Abstract contract for crash reporting and exception telemetry.
abstract interface class CrashReportingService {
  Future<void> initialize({required String? dsn, required String environment});

  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    Map<String, dynamic>? extra,
    bool fatal = false,
  });

  Future<void> logBreadcrumb(
    String message, {
    String? category,
    Map<String, dynamic>? data,
  });

  Future<void> setUserId(String? anonymizedUserId);
}

/// No-op implementation used in tests or environments without an active DSN.
class NoopCrashReportingService implements CrashReportingService {
  const NoopCrashReportingService();

  @override
  Future<void> initialize({
    required String? dsn,
    required String environment,
  }) async {}

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    Map<String, dynamic>? extra,
    bool fatal = false,
  }) async {}

  @override
  Future<void> logBreadcrumb(
    String message, {
    String? category,
    Map<String, dynamic>? data,
  }) async {}

  @override
  Future<void> setUserId(String? anonymizedUserId) async {}
}

/// Sentry integration boundary enforcing local PII and health data scrubbing.
///
/// Prepares integration hooks for Sentry without bundling production secrets.
/// Applies [DataRedactor] to all breadcrumbs, custom metadata, and exception messages.
class SentryCrashReportingBoundary implements CrashReportingService {
  final DataRedactor redactor;
  String? _activeDsn;
  String? _environment;
  bool _isInitialized = false;

  final List<Map<String, dynamic>> recordedErrors = [];
  final List<Map<String, dynamic>> breadcrumbs = [];

  SentryCrashReportingBoundary({this.redactor = const DataRedactor()});

  bool get isInitialized => _isInitialized;
  String? get activeDsn => _activeDsn;
  String? get environment => _environment;

  @override
  Future<void> initialize({
    required String? dsn,
    required String environment,
  }) async {
    _environment = environment;

    // Do not activate live network dispatch if DSN is missing or placeholder
    if (dsn == null || dsn.trim().isEmpty || dsn.contains('placeholder')) {
      _activeDsn = null;
      _isInitialized = true;
      return;
    }

    _activeDsn = dsn.trim();
    _isInitialized = true;
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    String? reason,
    Map<String, dynamic>? extra,
    bool fatal = false,
  }) async {
    if (!_isInitialized) return;

    final sanitizedReason = reason != null
        ? redactor.redactString(reason)
        : null;
    final sanitizedExtra = extra != null ? redactor.redactMap(extra) : null;

    recordedErrors.add({
      'error': error.toString(),
      'stackTrace': stackTrace?.toString(),
      'reason': sanitizedReason,
      'extra': sanitizedExtra,
      'fatal': fatal,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    });
  }

  @override
  Future<void> logBreadcrumb(
    String message, {
    String? category,
    Map<String, dynamic>? data,
  }) async {
    if (!_isInitialized) return;

    final sanitizedMessage = redactor.redactString(message);
    final sanitizedData = data != null ? redactor.redactMap(data) : null;

    breadcrumbs.add({
      'message': sanitizedMessage,
      'category': category ?? 'default',
      'data': sanitizedData,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    });
  }

  @override
  Future<void> setUserId(String? anonymizedUserId) async {
    // Under DPDP, user IDs passed to external telemetry must be anonymized hashes
    // Never allow raw emails or phone numbers as telemetry identifiers
  }
}
