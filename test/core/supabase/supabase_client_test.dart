import 'dart:async';
import 'dart:io';

import 'package:fitkarma/app/fitkarma_app.dart';
import 'package:fitkarma/core/config/app_config.dart';
import 'package:fitkarma/core/errors/failures.dart';
import 'package:fitkarma/core/providers/core_providers.dart';
import 'package:fitkarma/core/supabase/mock_supabase_service.dart';
import 'package:fitkarma/core/supabase/supabase_client_service.dart';
import 'package:fitkarma/core/supabase/supabase_failure_mapper.dart';
import 'package:fitkarma/core/supabase/supabase_providers.dart';
import 'package:fitkarma/core/supabase/supabase_service_boundary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('Supabase Client Initialization & Environment Boundary Tests', () {
    test(
      'initializes with mock fallback when placeholder URL is provided',
      () async {
        const config = AppConfig(
          environment: AppEnvironment.development,
          supabaseUrl: 'https://placeholder-project.supabase.co',
          supabaseAnonKey: 'placeholder-anon-key-subject-to-rls',
        );

        final service = await SupabaseClientService.initialize(config: config);

        expect(service.isInitialized, isTrue);
        expect(service.isMock, isTrue);
        expect(service, isA<MockSupabaseService>());
      },
    );

    test(
      'initializes with mock service when forceMock is explicitly true',
      () async {
        const config = AppConfig(
          environment: AppEnvironment.staging,
          supabaseUrl: 'https://staging.supabase.co',
          supabaseAnonKey: 'valid-anon-key-staging',
        );

        final service = await SupabaseClientService.initialize(
          config: config,
          forceMock: true,
        );

        expect(service.isInitialized, isTrue);
        expect(service.isMock, isTrue);
      },
    );

    test('rejects server-role secret during initialization (SecurityViolationException)', () async {
      expect(
        () => AppConfig.assertNoServerSecrets({
          'SUPABASE_URL': 'https://live.supabase.co',
          'SUPABASE_ANON_KEY': 'anon-key',
          'SUPABASE_SERVICE_ROLE_KEY': 'super-secret-service-role-key',
        }),
        throwsA(isA<SecurityViolationException>()),
      );
    });
  });

  group('Supabase Auth Service Boundary Tests', () {
    late MockSupabaseService mockService;
    late MockSupabaseAuthService authService;

    setUp(() {
      mockService = MockSupabaseService();
      authService = mockService.auth;
    });

    test('starts with unauthenticated initial state', () {
      expect(authService.currentUser, isNull);
      expect(authService.currentSession, isNull);
    });

    test('simulateSignIn emits authenticated state and updates currentUser', () async {
      final user = FitKarmaUser(
        id: 'user_123',
        phone: '+919999900001',
        createdAt: DateTime.now(),
      );

      final states = <FitKarmaAuthState>[];
      final sub = authService.authStateChanges.listen(states.add);

      authService.simulateSignIn(user, 'token_xyz');

      await pumpEventQueue();

      expect(states.isNotEmpty, isTrue);
      expect(states.last.status, FitKarmaAuthStatus.authenticated);
      expect(states.last.user?.id, 'user_123');
      expect(authService.currentUser?.id, 'user_123');
      expect(authService.currentSession?.accessToken, 'token_xyz');

      await sub.cancel();
    });

    test('simulateSignOut clears user and session', () async {
      final user = FitKarmaUser(
        id: 'user_456',
        createdAt: DateTime.now(),
      );

      authService.simulateSignIn(user);
      expect(authService.currentUser?.id, 'user_456');

      authService.simulateSignOut();
      expect(authService.currentUser, isNull);
      expect(authService.currentSession, isNull);
    });

    test('verifyOtp succeeds with valid token and fails with invalid token', () async {
      final failResult = await authService.verifyOtp(phone: '+919999900001', token: '000000');
      expect(failResult.isFailure, isTrue);
      expect(failResult.failureOrNull?.code, 'FK-1001');

      final successResult = await authService.verifyOtp(phone: '+919999900001', token: '123456');
      expect(successResult.isSuccess, isTrue);
      expect(authService.currentUser, isNotNull);
    });

    test('signInWithEmailPassword rejects wrong password with FK-1001', () async {
      final fail = await authService.signInWithEmailPassword(
        email: 'test@fitkarma.in',
        password: 'wrong',
      );
      expect(fail.isFailure, isTrue);
      expect(fail.failureOrNull?.code, 'FK-1001');

      final success = await authService.signInWithEmailPassword(
        email: 'test@fitkarma.in',
        password: 'correct_password',
      );
      expect(success.isSuccess, isTrue);
      expect(authService.currentUser, isNotNull);
    });
  });

  group('Supabase Functions & Storage Service Boundary Tests', () {
    late MockSupabaseService mockService;

    setUp(() {
      mockService = MockSupabaseService();
    });

    test('invokes health-check function returning decoded data', () async {
      final res = await mockService.functions.invoke<Map<String, dynamic>>(
        'health-check',
        decoder: (data) => data as Map<String, dynamic>,
      );

      expect(res.isSuccess, isTrue);
      final data = res.dataOrNull!;
      expect(data['status'], 'healthy');
      expect(data['service'], 'fitkarma-edge-mock');
    });

    test(
      'storage service generates signed URLs and simulates upload',
      () async {
        final urlRes = await mockService.storage.getSignedUrl(
          'meal_photos',
          'user_1/meal.jpg',
        );
        expect(urlRes.isSuccess, isTrue);
        expect(urlRes.dataOrNull!, contains('meal_photos/user_1/meal.jpg'));

        final uploadRes = await mockService.storage.uploadFile(
          'meal_photos',
          'user_1/meal.jpg',
          [1, 2, 3],
        );
        expect(uploadRes.isSuccess, isTrue);
        expect(uploadRes.dataOrNull!, 'meal_photos/user_1/meal.jpg');
      },
    );
  });

  group('Supabase Failure Mapper Taxonomy Tests', () {
    test('maps AuthException rate limit to FK-1001', () {
      const authEx = AuthException('Rate limit exceeded', statusCode: '429');
      final failure = SupabaseFailureMapper.map(authEx);

      expect(failure.code, 'FK-1001');
      expect(failure, isA<AuthFailure>());
    });

    test('maps PostgrestException 42501 (RLS violation) to AuthZFailure FK-1002', () {
      const postgrestEx = PostgrestException(
        message: 'new row violates row-level security policy for table "food_logs"',
        code: '42501',
      );
      final failure = SupabaseFailureMapper.map(postgrestEx);

      expect(failure, isA<AuthZFailure>());
      expect(failure.code, 'FK-1002');
      expect(failure.retryable, isFalse);
    });

    test('maps PostgrestException 23505 (unique violation) to ConflictFailure FK-3003', () {
      const postgrestEx = PostgrestException(
        message: 'duplicate key value violates unique constraint',
        code: '23505',
      );
      final failure = SupabaseFailureMapper.map(postgrestEx);

      expect(failure, isA<ConflictFailure>());
      expect(failure.code, 'FK-3003');
    });

    test('maps SocketException to SyncFailure FK-3002 retryable', () {
      const socketEx = SocketException('Connection refused');
      final failure = SupabaseFailureMapper.map(socketEx);

      expect(failure, isA<SyncFailure>());
      expect(failure.code, 'FK-3002');
      expect(failure.retryable, isTrue);
    });

    test('maps TimeoutException to SyncFailure FK-3002 retryable', () {
      final timeoutEx = TimeoutException('Operation timed out');
      final failure = SupabaseFailureMapper.map(timeoutEx);

      expect(failure, isA<SyncFailure>());
      expect(failure.code, 'FK-3002');
      expect(failure.retryable, isTrue);
    });
  });

  group('Riverpod Providers & App Bootstrapping Tests', () {
    testWidgets(
      'boots FitKarmaApp with MockSupabaseService without production credentials',
      (tester) async {
        final mockService = MockSupabaseService();
        const config = AppConfig(
          environment: AppEnvironment.development,
          supabaseUrl: 'https://placeholder.supabase.co',
          supabaseAnonKey: 'placeholder-anon-key',
        );

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appConfigProvider.overrideWithValue(config),
              supabaseServiceProvider.overrideWithValue(mockService),
            ],
            child: const FitKarmaApp(),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(FitKarmaApp), findsOneWidget);
      },
    );

    test('currentUserProvider and isAuthenticatedProvider react to auth state changes', () async {
      final mockService = MockSupabaseService();
      final container = ProviderContainer(
        overrides: [supabaseServiceProvider.overrideWithValue(mockService)],
      );

      expect(container.read(isAuthenticatedProvider), isFalse);
      expect(container.read(currentUserProvider), isNull);

      final testUser = FitKarmaUser(
        id: '00000000-0000-0000-0000-000000000001',
        email: 'arjun@fitkarma.internal',
        createdAt: DateTime.now(),
      );

      mockService.auth.simulateSignIn(testUser);

      // Wait for stream event to propagate in container
      await container.read(supabaseAuthStateProvider.future);

      expect(container.read(isAuthenticatedProvider), isTrue);
      expect(container.read(currentUserProvider)?.id, testUser.id);

      mockService.auth.simulateSignOut();
      await pumpEventQueue();

      expect(container.read(isAuthenticatedProvider), isFalse);

      container.dispose();
    });
  });
}
