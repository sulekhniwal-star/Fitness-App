import 'dart:developer' as developer;

import 'package:fitkarma/core/services/logging_service.dart';

/// Console-based logging service implementation with secret and PII awareness.
class ConsoleLoggingService implements LoggingService {
  final bool isDebug;

  const ConsoleLoggingService({this.isDebug = true});

  @override
  void log(
    LogLevel level,
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!isDebug && level == LogLevel.debug) return;

    final sanitizedData = _sanitize(data);
    developer.log(
      '[$level] $message ${sanitizedData != null ? '| data: $sanitizedData' : ''}',
      name: 'FitKarma',
      error: error,
      stackTrace: stackTrace,
      level: _toDeveloperLevel(level),
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

  Map<String, dynamic>? _sanitize(Map<String, dynamic>? data) {
    if (data == null) return null;
    final sanitized = <String, dynamic>{};
    for (final entry in data.entries) {
      final key = entry.key.toLowerCase();
      if (key.contains('secret') ||
          key.contains('password') ||
          key.contains('token') ||
          key.contains('key') ||
          key.contains('pin')) {
        sanitized[entry.key] = '[REDACTED]';
      } else {
        sanitized[entry.key] = entry.value;
      }
    }
    return sanitized;
  }

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
