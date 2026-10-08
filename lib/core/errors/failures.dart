/// Base failure primitive for FitKarma clean architecture.
///
/// Specific error taxonomy details align with Brain/error_handling.md.
abstract class Failure {
  final String message;
  final String code;

  const Failure({required this.message, required this.code});

  @override
  String toString() => '$runtimeType(code: $code, message: $message)';
}
