import 'dart:async';
import 'dart:io';

import 'package:fitkarma/core/errors/failures.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized mapper translating Supabase SDK exceptions into FitKarma AppFailure taxonomy.
///
/// Guarantees that internal database queries, credential leaks, and technical stack traces
/// are scrubbed before reaching the presentation layer.
class SupabaseFailureMapper {
  const SupabaseFailureMapper._();

  /// Maps any caught exception during Supabase operations into strongly-typed [AppFailure].
  static AppFailure map(Object error, [StackTrace? stackTrace]) {
    if (error is AppFailure) {
      return error;
    }

    if (error is AuthException) {
      return _mapAuthException(error);
    }

    if (error is PostgrestException) {
      return _mapPostgrestException(error);
    }

    if (error is FunctionException) {
      return _mapFunctionException(error);
    }

    if (error is StorageException) {
      return _mapStorageException(error);
    }

    if (error is SocketException) {
      return const SyncFailure(
        message: 'No internet connection. Actions will be queued offline.',
      );
    }

    if (error is TimeoutException) {
      return const SyncFailure(
        message: 'Operation timed out. Please check your network connection.',
      );
    }

    // Fallback safe internal failure
    return InternalFailure(
      message: AppFailure.sanitizeUserMessage(error.toString()),
    );
  }

  static AppFailure _mapAuthException(AuthException error) {
    final status = int.tryParse(error.statusCode ?? '');
    final msg = error.message.toLowerCase();

    if (status == 429 || msg.contains('rate limit') || msg.contains('too many')) {
      return const AuthFailure(
        message: 'Too many authentication attempts. Please wait before trying again.',
      );
    }

    if (status == 403 || msg.contains('not authorized')) {
      return const AuthZFailure(
        message: 'Access denied: You do not have permission for this action.',
      );
    }

    if (msg.contains('expired') || msg.contains('invalid token')) {
      return const AuthFailure(
        message: 'Session or verification code expired. Please request a new one.',
      );
    }

    if (msg.contains('invalid login') || msg.contains('invalid otp') || msg.contains('token has expired')) {
      return const AuthFailure(
        message: 'Invalid credentials or verification code entered.',
      );
    }

    if (msg.contains('cancel') || msg.contains('cancelled') || msg.contains('user cancelled')) {
      return const AuthFailure(
        message: 'Google Sign-In was cancelled by the user.',
        details: {'cancelled': true},
      );
    }

    if (msg.contains('provider') || msg.contains('oauth') || msg.contains('external')) {
      return AuthFailure(
        message: AppFailure.sanitizeUserMessage(error.message),
        details: {'provider_error': true},
      );
    }

    return AuthFailure(
      message: AppFailure.sanitizeUserMessage(error.message),
    );
  }

  static AppFailure _mapPostgrestException(PostgrestException error) {
    // Postgres Error Code 42501 = insufficient_privilege (RLS rejection)
    if (error.code == '42501') {
      return const AuthZFailure(
        message: 'Access denied: Operation rejected by Row Level Security policy.',
      );
    }

    // Postgres Error Code 23505 = unique_violation
    if (error.code == '23505') {
      return const ConflictFailure(
        message: 'A conflicting record with this identifier already exists.',
      );
    }

    // Postgres Error Code 23503 = foreign_key_violation
    if (error.code == '23503') {
      return const ValidationFailure(
        message: 'Invalid reference: Associated resource does not exist.',
      );
    }

    return ValidationFailure(
      message: AppFailure.sanitizeUserMessage(error.message),
    );
  }

  static AppFailure _mapFunctionException(FunctionException error) {
    final details = error.details;
    if (details is Map<String, dynamic> && details.containsKey('error')) {
      final errorMap = details['error'];
      if (errorMap is Map<String, dynamic>) {
        return AppFailure.fromJson(errorMap);
      }
    }

    final message = details != null
        ? AppFailure.sanitizeUserMessage(details.toString())
        : 'Edge function invocation failed.';

    return InternalFailure(
      message: message,
    );
  }

  static AppFailure _mapStorageException(StorageException error) {
    final status = int.tryParse(error.statusCode ?? '');
    if (status == 403 || error.message.contains('Unauthorized')) {
      return const AuthZFailure(
        message: 'Access denied: You do not have permission to access this asset.',
      );
    }

    return ValidationFailure(
      message: AppFailure.sanitizeUserMessage(error.message),
    );
  }
}
