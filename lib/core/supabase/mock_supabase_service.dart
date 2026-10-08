import 'dart:async';

import 'package:fitkarma/core/errors/failures.dart';
import 'package:fitkarma/core/errors/result.dart';
import 'package:fitkarma/core/supabase/supabase_service_boundary.dart';

/// In-memory mock implementation of [ISupabaseService] for testing, preview,
/// and offline bootstrapping without network or production credentials.
class MockSupabaseService implements ISupabaseService {
  @override
  final MockSupabaseAuthService auth;

  @override
  final MockSupabaseFunctionsService functions;

  @override
  final MockSupabaseStorageService storage;

  MockSupabaseService({
    MockSupabaseAuthService? auth,
    MockSupabaseFunctionsService? functions,
    MockSupabaseStorageService? storage,
  }) : auth = auth ?? MockSupabaseAuthService(),
       functions = functions ?? MockSupabaseFunctionsService(),
       storage = storage ?? MockSupabaseStorageService();

  @override
  bool get isInitialized => true;

  @override
  bool get isMock => true;
}

/// Mock authentication service.
class MockSupabaseAuthService implements ISupabaseAuthService {
  final _authStateController = StreamController<FitKarmaAuthState>.broadcast();

  FitKarmaUser? _currentUser;
  FitKarmaAuthSession? _currentSession;

  MockSupabaseAuthService({FitKarmaUser? initialUser}) {
    if (initialUser != null) {
      simulateSignIn(initialUser);
    } else {
      _authStateController.add(FitKarmaAuthState.unauthenticated);
    }
  }

  @override
  Stream<FitKarmaAuthState> get authStateChanges => _authStateController.stream;

  @override
  FitKarmaUser? get currentUser => _currentUser;

  @override
  FitKarmaAuthSession? get currentSession => _currentSession;

  void simulateSignIn(FitKarmaUser user, [String token = 'mock_access_token']) {
    _currentUser = user;
    _currentSession = FitKarmaAuthSession(
      accessToken: token,
      refreshToken: 'mock_refresh_token',
      expiresAt: DateTime.now().add(const Duration(days: 7)),
      user: user,
    );
    _authStateController.add(
      FitKarmaAuthState(
        status: FitKarmaAuthStatus.authenticated,
        session: _currentSession,
        user: _currentUser,
      ),
    );
  }

  void simulateSignOut() {
    _currentUser = null;
    _currentSession = null;
    _authStateController.add(FitKarmaAuthState.unauthenticated);
  }

  @override
  Future<Result<void>> signInWithOtp({required String phone}) async {
    if (phone.isEmpty) {
      return const FailureResult(
        ValidationFailure(
          message: 'Phone number cannot be empty',
        ),
      );
    }
    // Simulate OTP sent
    return const Success(null);
  }

  @override
  Future<Result<FitKarmaAuthSession>> verifyOtp({
    required String phone,
    required String token,
  }) async {
    if (token == '000000' || token.isEmpty) {
      return const FailureResult(
        AuthFailure(
          message: 'Invalid verification code entered.',
        ),
      );
    }

    final user = FitKarmaUser(
      id: '00000000-0000-0000-0000-000000000001',
      phone: phone,
      createdAt: DateTime.now(),
      userMetadata: const {'role': 'user'},
    );

    simulateSignIn(user);
    return Success(_currentSession!);
  }

  @override
  Future<Result<FitKarmaAuthSession>> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    if (password == 'wrong') {
      return const FailureResult(
        AuthFailure(message: 'Invalid email or password.'),
      );
    }

    final user = FitKarmaUser(
      id: '00000000-0000-0000-0000-000000000001',
      email: email,
      createdAt: DateTime.now(),
      userMetadata: const {'role': 'user'},
    );

    simulateSignIn(user);
    return Success(_currentSession!);
  }

  @override
  Future<Result<void>> signOut() async {
    simulateSignOut();
    return const Success(null);
  }

  void dispose() {
    _authStateController.close();
  }
}

/// Mock Edge Functions service.
class MockSupabaseFunctionsService implements ISupabaseFunctionsService {
  final Map<String, dynamic> _mockResponses = {};

  void setMockResponse(String functionName, dynamic response) {
    _mockResponses[functionName] = response;
  }

  @override
  Future<Result<T>> invoke<T>(
    String functionName, {
    Map<String, dynamic>? payload,
    String? idempotencyKey,
    T Function(dynamic data)? decoder,
  }) async {
    if (_mockResponses.containsKey(functionName)) {
      final raw = _mockResponses[functionName];
      if (raw is AppFailure) {
        return FailureResult(raw);
      }
      final decoded = decoder != null ? decoder(raw) : raw as T;
      return Success(decoded);
    }

    // Default mock response for health check
    if (functionName == 'health-check') {
      final defaultHealth = <String, dynamic>{
        'status': 'healthy',
        'service': 'fitkarma-edge-mock',
        'timestamp': DateTime.now().toIso8601String(),
      };
      final decoded = decoder != null
          ? decoder(defaultHealth)
          : defaultHealth as T;
      return Success(decoded);
    }

    return const FailureResult(
      ExternalServiceFailure(
        message: 'Mock response not configured for function',
      ),
    );
  }
}

/// Mock storage service.
class MockSupabaseStorageService implements ISupabaseStorageService {
  @override
  Future<Result<String>> getSignedUrl(
    String bucket,
    String path, {
    Duration expiresIn = const Duration(hours: 1),
  }) async {
    return Success(
      'https://mock.storage.fitkarma.internal/$bucket/$path?token=mock_sig',
    );
  }

  @override
  Future<Result<String>> uploadFile(
    String bucket,
    String path,
    List<int> bytes, {
    String? contentType,
  }) async {
    return Success('$bucket/$path');
  }
}
