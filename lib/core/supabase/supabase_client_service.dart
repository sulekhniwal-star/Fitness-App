import 'dart:async';

import 'package:fitkarma/core/config/app_config.dart';
import 'package:fitkarma/core/errors/failures.dart';
import 'package:fitkarma/core/errors/result.dart';
import 'package:fitkarma/core/supabase/mock_supabase_service.dart';
import 'package:fitkarma/core/supabase/supabase_failure_mapper.dart';
import 'package:fitkarma/core/supabase/supabase_service_boundary.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Concrete production implementation of [ISupabaseService] wrapping the Supabase Flutter SDK.
class SupabaseClientService implements ISupabaseService {
  final SupabaseClient _client;

  @override
  final ISupabaseAuthService auth;

  @override
  final ISupabaseFunctionsService functions;

  @override
  final ISupabaseStorageService storage;

  SupabaseClientService._(this._client)
    : auth = _SupabaseAuthServiceImpl(_client.auth),
      functions = _SupabaseFunctionsServiceImpl(_client.functions),
      storage = _SupabaseStorageServiceImpl(_client.storage);

  @override
  bool get isInitialized => true;

  @override
  bool get isMock => false;

  /// Exposes the underlying [SupabaseClient] for specialized integrations if needed.
  SupabaseClient get rawClient => _client;

  /// Initializes the Supabase client boundary from [AppConfig].
  ///
  /// If [forceMock] is true or the configured URL contains a placeholder or test domain,
  /// this factory gracefully returns a [MockSupabaseService] allowing the app to boot
  /// without live backend credentials or network access.
  static Future<ISupabaseService> initialize({
    required AppConfig config,
    bool forceMock = false,
  }) async {
    // 1. Strict validation rejecting server secrets
    AppConfig.assertNoServerSecrets({
      'SUPABASE_URL': config.supabaseUrl,
      'SUPABASE_ANON_KEY': config.supabaseAnonKey,
    });

    // 2. Mock mode detection
    final isPlaceholderUrl =
        config.supabaseUrl.contains('placeholder') ||
        config.supabaseUrl.contains('mock') ||
        config.supabaseAnonKey.contains('placeholder');

    if (forceMock || isPlaceholderUrl) {
      return MockSupabaseService();
    }

    try {
      final supabase = await Supabase.initialize(
        url: config.supabaseUrl,
        // ignore: deprecated_member_use
        anonKey: config.supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
          autoRefreshToken: true,
        ),
      );

      return SupabaseClientService._(supabase.client);
    } catch (e, st) {
      // If initialization fails (e.g. running in widget test harness without plugins), fallback to mock
      if (config.environment == AppEnvironment.development) {
        return MockSupabaseService();
      }
      throw SupabaseFailureMapper.map(e, st);
    }
  }
}

class _SupabaseAuthServiceImpl implements ISupabaseAuthService {
  final GoTrueClient _auth;

  _SupabaseAuthServiceImpl(this._auth);

  @override
  Stream<FitKarmaAuthState> get authStateChanges =>
      _auth.onAuthStateChange.map((data) {
        final session = data.session;
        final user = session?.user;

        if (session == null || user == null) {
          return FitKarmaAuthState.unauthenticated;
        }

        final fitKarmaUser = FitKarmaUser(
          id: user.id,
          email: user.email,
          phone: user.phone,
          createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
          userMetadata: user.userMetadata ?? const {},
        );

        final fitKarmaSession = FitKarmaAuthSession(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken,
          expiresAt: session.expiresAt != null
              ? DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)
              : null,
          user: fitKarmaUser,
        );

        final status = switch (data.event) {
          AuthChangeEvent.signedIn => FitKarmaAuthStatus.authenticated,
          AuthChangeEvent.tokenRefreshed => FitKarmaAuthStatus.tokenRefreshed,
          AuthChangeEvent.signedOut => FitKarmaAuthStatus.signedOut,
          _ => FitKarmaAuthStatus.authenticated,
        };

        return FitKarmaAuthState(
          status: status,
          session: fitKarmaSession,
          user: fitKarmaUser,
        );
      });

  @override
  FitKarmaUser? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return FitKarmaUser(
      id: user.id,
      email: user.email,
      phone: user.phone,
      createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
      userMetadata: user.userMetadata ?? const {},
    );
  }

  @override
  FitKarmaAuthSession? get currentSession {
    final session = _auth.currentSession;
    final user = currentUser;
    if (session == null || user == null) return null;
    return FitKarmaAuthSession(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      expiresAt: session.expiresAt != null
          ? DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)
          : null,
      user: user,
    );
  }

  @override
  Future<Result<void>> signInWithOtp({required String phone}) async {
    try {
      await _auth.signInWithOtp(phone: phone);
      return const Success(null);
    } catch (e, st) {
      return FailureResult(SupabaseFailureMapper.map(e, st));
    }
  }

  @override
  Future<Result<FitKarmaAuthSession>> verifyOtp({
    required String phone,
    required String token,
  }) async {
    try {
      final res = await _auth.verifyOTP(
        phone: phone,
        token: token,
        type: OtpType.sms,
      );

      final session = res.session;
      final user = res.user;
      if (session == null || user == null) {
        return FailureResult(
          SupabaseFailureMapper.map('Missing session after OTP verification'),
        );
      }

      final fitKarmaUser = FitKarmaUser(
        id: user.id,
        email: user.email,
        phone: user.phone,
        createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
        userMetadata: user.userMetadata ?? const {},
      );

      return Success(
        FitKarmaAuthSession(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken,
          expiresAt: session.expiresAt != null
              ? DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)
              : null,
          user: fitKarmaUser,
        ),
      );
    } catch (e, st) {
      return FailureResult(SupabaseFailureMapper.map(e, st));
    }
  }

  @override
  Future<Result<FitKarmaAuthSession>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      final session = res.session;
      final user = res.user;

      if (session == null || user == null) {
        return FailureResult(
          SupabaseFailureMapper.map('Missing session after sign-in'),
        );
      }

      final fitKarmaUser = FitKarmaUser(
        id: user.id,
        email: user.email,
        phone: user.phone,
        createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
        userMetadata: user.userMetadata ?? const {},
      );

      return Success(
        FitKarmaAuthSession(
          accessToken: session.accessToken,
          refreshToken: session.refreshToken,
          expiresAt: session.expiresAt != null
              ? DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)
              : null,
          user: fitKarmaUser,
        ),
      );
    } catch (e, st) {
      return FailureResult(SupabaseFailureMapper.map(e, st));
    }
  }

  @override
  Future<Result<FitKarmaAuthSession>> signInWithGoogle({
    String? redirectTo,
    String? idToken,
    String? accessToken,
  }) async {
    try {
      if (idToken != null) {
        final res = await _auth.signInWithIdToken(
          provider: OAuthProvider.google,
          idToken: idToken,
          accessToken: accessToken,
        );
        final session = res.session;
        final user = res.user;
        if (session == null || user == null) {
          return FailureResult(
            SupabaseFailureMapper.map('Missing session after Google Sign-In'),
          );
        }
        final fitKarmaUser = FitKarmaUser(
          id: user.id,
          email: user.email,
          phone: user.phone,
          createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
          userMetadata: user.userMetadata ?? const {},
        );
        return Success(
          FitKarmaAuthSession(
            accessToken: session.accessToken,
            refreshToken: session.refreshToken,
            expiresAt: session.expiresAt != null
                ? DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)
                : null,
            user: fitKarmaUser,
          ),
        );
      } else {
        final hasLaunched = await _auth.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: redirectTo,
        );
        if (!hasLaunched) {
          return const FailureResult(
            AuthFailure(
              message: 'Google Sign-In was cancelled by the user.',
              details: {'cancelled': true},
            ),
          );
        }
        final current = currentSession;
        if (current != null) {
          return Success(current);
        }
        return const FailureResult(
          AuthFailure(
            message: 'Waiting for OAuth browser callback to complete.',
          ),
        );
      }
    } catch (e, st) {
      return FailureResult(SupabaseFailureMapper.map(e, st));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _auth.signOut();
      return const Success(null);
    } catch (e, st) {
      return FailureResult(SupabaseFailureMapper.map(e, st));
    }
  }
}

class _SupabaseFunctionsServiceImpl implements ISupabaseFunctionsService {
  final FunctionsClient _functions;

  _SupabaseFunctionsServiceImpl(this._functions);

  @override
  Future<Result<T>> invoke<T>(
    String functionName, {
    Map<String, dynamic>? payload,
    String? idempotencyKey,
    T Function(dynamic data)? decoder,
  }) async {
    try {
      final headers = <String, String>{};
      if (idempotencyKey != null) {
        headers['Idempotency-Key'] = idempotencyKey;
      }

      final response = await _functions.invoke(
        functionName,
        body: payload != null ? {'payload': payload} : null,
        headers: headers,
      );

      final data = response.data;
      if (data is Map<String, dynamic> &&
          data.containsKey('error') &&
          data['error'] != null) {
        return FailureResult(SupabaseFailureMapper.map(data['error']));
      }

      final resultData =
          (data is Map<String, dynamic> && data.containsKey('data'))
          ? data['data']
          : data;

      final decoded = decoder != null ? decoder(resultData) : resultData as T;
      return Success(decoded);
    } catch (e, st) {
      return FailureResult(SupabaseFailureMapper.map(e, st));
    }
  }
}

class _SupabaseStorageServiceImpl implements ISupabaseStorageService {
  final SupabaseStorageClient _storage;

  _SupabaseStorageServiceImpl(this._storage);

  @override
  Future<Result<String>> getSignedUrl(
    String bucket,
    String path, {
    Duration expiresIn = const Duration(hours: 1),
  }) async {
    try {
      final url = await _storage
          .from(bucket)
          .createSignedUrl(path, expiresIn.inSeconds);
      return Success(url);
    } catch (e, st) {
      return FailureResult(SupabaseFailureMapper.map(e, st));
    }
  }

  @override
  Future<Result<String>> uploadFile(
    String bucket,
    String path,
    List<int> bytes, {
    String? contentType,
  }) async {
    try {
      await _storage
          .from(bucket)
          .uploadBinary(
            path,
            bytes as dynamic,
            fileOptions: FileOptions(contentType: contentType),
          );
      return Success('$bucket/$path');
    } catch (e, st) {
      return FailureResult(SupabaseFailureMapper.map(e, st));
    }
  }
}
