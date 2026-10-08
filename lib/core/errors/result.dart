import 'package:fitkarma/core/errors/failures.dart';

/// Functional Result primitive representing either [Success] or [FailureResult].
sealed class Result<T> {
  const Result();

  /// Creates a successful [Result] containing [data].
  const factory Result.success(T data) = Success<T>;

  /// Creates a failed [Result] containing [failure].
  const factory Result.failure(AppFailure failure) = FailureResult<T>;

  /// Returns true if the result is [Success].
  bool get isSuccess => this is Success<T>;

  /// Returns true if the result is [FailureResult].
  bool get isFailure => this is FailureResult<T>;

  /// Returns the data if [Success], otherwise returns null.
  T? get dataOrNull => switch (this) {
    Success(data: final d) => d,
    FailureResult() => null,
  };

  /// Returns the failure if [FailureResult], otherwise returns null.
  AppFailure? get failureOrNull => switch (this) {
    Success() => null,
    FailureResult(failure: final f) => f,
  };

  /// Pattern-matches over the result.
  R when<R>({
    required R Function(T data) success,
    required R Function(AppFailure failure) failure,
  }) {
    return switch (this) {
      Success(data: final d) => success(d),
      FailureResult(failure: final f) => failure(f),
    };
  }

  /// Maps the success value using [mapper].
  Result<R> map<R>(R Function(T data) mapper) {
    return switch (this) {
      Success(data: final d) => Result.success(mapper(d)),
      FailureResult(failure: final f) => Result.failure(f),
    };
  }

  /// Flat-maps the success value into another [Result] using [mapper].
  Result<R> flatMap<R>(Result<R> Function(T data) mapper) {
    return switch (this) {
      Success(data: final d) => mapper(d),
      FailureResult(failure: final f) => Result.failure(f),
    };
  }

  /// Unwraps the data or uses [fallback] if failed.
  T getOrElse(T Function(AppFailure failure) fallback) {
    return switch (this) {
      Success(data: final d) => d,
      FailureResult(failure: final f) => fallback(f),
    };
  }
}

/// Represents successful operation outcome.
final class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
          runtimeType == other.runtimeType &&
          data == other.data;

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Result.success($data)';
}

/// Represents failed operation outcome.
final class FailureResult<T> extends Result<T> {
  final AppFailure failure;

  const FailureResult(this.failure);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FailureResult<T> &&
          runtimeType == other.runtimeType &&
          failure == other.failure;

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'Result.failure($failure)';
}
