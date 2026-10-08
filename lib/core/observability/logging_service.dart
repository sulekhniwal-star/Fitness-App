/// Severity levels for logging.
enum LogLevel { debug, info, warning, error }

/// Structured diagnostic/telemetry event.
class DiagnosticEvent {
  final String name;
  final String category;
  final DateTime timestamp;
  final Map<String, dynamic>? parameters;

  DiagnosticEvent({
    required this.name,
    required this.category,
    DateTime? timestamp,
    this.parameters,
  }) : timestamp = timestamp ?? DateTime.now().toUtc();

  Map<String, dynamic> toJson() => {
    'name': name,
    'category': category,
    'timestamp': timestamp.toIso8601String(),
    if (parameters != null) 'parameters': parameters,
  };

  @override
  String toString() =>
      'DiagnosticEvent($name, category: $category, params: $parameters)';
}

/// Abstract logging interface enforcing redaction and structured events.
abstract interface class LoggingService {
  void log(
    LogLevel level,
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  });

  void recordEvent(DiagnosticEvent event);

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
