/// Diagnostic log level.
enum LogLevel { debug, info, warning, error }

/// Abstract logging interface enforcing PII and secret redaction.
abstract interface class LoggingService {
  void log(
    LogLevel level,
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  });
  void debug(String message, {Map<String, dynamic>? data});
  void info(String message, {Map<String, dynamic>? data});
  void warning(String message, {Map<String, dynamic>? data, Object? error});
  void error(
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  });
}
