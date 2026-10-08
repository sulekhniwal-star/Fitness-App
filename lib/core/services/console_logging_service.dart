import 'dart:developer' as developer;

import 'package:fitkarma/core/observability/logging_service.dart';
import 'package:fitkarma/core/observability/redaction.dart';

/// Console-based logging service implementation with comprehensive PII, health,
/// and secret redaction.
class ConsoleLoggingService implements LoggingService {
  final bool isDebug;
  final DataRedactor redactor;

  const ConsoleLoggingService({
    this.isDebug = true,
    this.redactor = const DataRedactor(),
  });

  @override
  void log(
    LogLevel level,
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!isDebug && level == LogLevel.debug) return;

    final sanitizedMessage = redactor.redactString(message);
    final sanitizedData = data != null ? redactor.redactMap(data) : null;

    developer.log(
      '[$level] $sanitizedMessage ${sanitizedData != null ? '| data: $sanitizedData' : ''}',
      name: 'FitKarma',
      error: error,
      stackTrace: stackTrace,
      level: _toDeveloperLevel(level),
    );
  }

  @override
  void recordEvent(DiagnosticEvent event) {
    if (!isDebug) return;

    final sanitizedParams = event.parameters != null
        ? redactor.redactMap(event.parameters!)
        : null;

    developer.log(
      '[EVENT] ${event.name} (category: ${event.category}) ${sanitizedParams != null ? '| params: $sanitizedParams' : ''}',
      name: 'FitKarma.Telemetry',
      level: 700,
    );
  }

  @override
  void debug(String message, {Map<String, dynamic>? data}) =>
      log(LogLevel.debug, message, data: data);

  @override
  void info(String message, {Map<String, dynamic>? data}) =>
      log(LogLevel.info, message, data: data);

  @override
  void warning(String message, {Map<String, dynamic>? data, Object? error}) =>
      log(LogLevel.warning, message, data: data, error: error);

  @override
  void error(
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) => log(
    LogLevel.error,
    message,
    data: data,
    error: error,
    stackTrace: stackTrace,
  );

  int _toDeveloperLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }
}
