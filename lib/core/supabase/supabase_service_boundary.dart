import 'dart:async';

import 'package:fitkarma/core/errors/result.dart';

/// Normalized user model returned by the Supabase auth boundary.
class FitKarmaUser {
  final String id;
  final String? email;
  final String? phone;
  final DateTime createdAt;
  final Map<String, dynamic> userMetadata;

  const FitKarmaUser({
    required this.id,
    this.email,
    this.phone,
    required this.createdAt,
    this.userMetadata = const {},
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FitKarmaUser &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          email == other.email &&
          phone == other.phone;

  @override
  int get hashCode => id.hashCode ^ email.hashCode ^ phone.hashCode;

  @override
  String toString() =>
      'FitKarmaUser(id: $id, email: $email, phone: $phone, metadataCount: ${userMetadata.length})';
}

/// Normalized auth session model returned by the Supabase auth boundary.
class FitKarmaAuthSession {
  final String accessToken;
  final String? refreshToken;
  final DateTime? expiresAt;
  final FitKarmaUser user;

  const FitKarmaAuthSession({
    required this.accessToken,
    this.refreshToken,
    this.expiresAt,
    required this.user,
  });

  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  @override
  String toString() =>
      'FitKarmaAuthSession(user: ${user.id}, expiresAt: $expiresAt)';
}

/// Authentication lifecycle states.
enum FitKarmaAuthStatus {
  unauthenticated,
  authenticated,
  tokenRefreshed,
  signedOut,
}

/// Normalized auth state holding session and user context.
class FitKarmaAuthState {
  final FitKarmaAuthStatus status;
  final FitKarmaAuthSession? session;
  final FitKarmaUser? user;

  const FitKarmaAuthState({required this.status, this.session, this.user});

  static const unauthenticated = FitKarmaAuthState(
    status: FitKarmaAuthStatus.unauthenticated,
  );

  bool get isAuthenticated =>
      status == FitKarmaAuthStatus.authenticated && user != null;

  @override
  String toString() => 'FitKarmaAuthState(status: $status, user: ${user?.id})';
}

/// Authentication service contract.
abstract interface class ISupabaseAuthService {
  /// Reactive stream of authentication changes.
  Stream<FitKarmaAuthState> get authStateChanges;

  /// Currently logged in user (null if unauthenticated).
  FitKarmaUser? get currentUser;

  /// Currently active session (null if unauthenticated).
  FitKarmaAuthSession? get currentSession;

  /// Requests phone SMS OTP for authentication (India-first login flow).
  Future<Result<void>> signInWithOtp({required String phone});

  /// Verifies phone SMS OTP token.
  Future<Result<FitKarmaAuthSession>> verifyOtp({
    required String phone,
    required String token,
  });

  /// Standard email/password authentication.
  Future<Result<FitKarmaAuthSession>> signInWithEmailPassword({
    required String email,
    required String password,
  });

  /// Signs out the current user session and clears local credentials.
  Future<Result<void>> signOut();
}

/// Edge Functions invocation contract conforming to Brain/api_contract.md.
abstract interface class ISupabaseFunctionsService {
  /// Invokes an Edge Function using standard request/response envelopes.
  Future<Result<T>> invoke<T>(
    String functionName, {
    Map<String, dynamic>? payload,
    String? idempotencyKey,
    T Function(dynamic data)? decoder,
  });
}

/// Storage service contract for private media assets.
abstract interface class ISupabaseStorageService {
  /// Retrieves a time-limited signed URL for private bucket objects.
  Future<Result<String>> getSignedUrl(
    String bucket,
    String path, {
    Duration expiresIn = const Duration(hours: 1),
  });

  /// Uploads binary data to a private bucket.
  Future<Result<String>> uploadFile(
    String bucket,
    String path,
    List<int> bytes, {
    String? contentType,
  });
}

/// Root Supabase client service boundary.
abstract interface class ISupabaseService {
  ISupabaseAuthService get auth;
  ISupabaseFunctionsService get functions;
  ISupabaseStorageService get storage;
  bool get isInitialized;
  bool get isMock;
}
