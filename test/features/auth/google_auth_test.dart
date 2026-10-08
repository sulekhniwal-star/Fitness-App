import 'package:fitkarma/app/fitkarma_app.dart';
import 'package:fitkarma/core/config/app_config.dart';
import 'package:fitkarma/core/errors/failures.dart';
import 'package:fitkarma/core/providers/core_providers.dart';
import 'package:fitkarma/core/routing/auth_nav_state.dart';
import 'package:fitkarma/core/supabase/mock_supabase_service.dart';
import 'package:fitkarma/core/supabase/supabase_providers.dart';
import 'package:fitkarma/features/auth/presentation/controllers/google_auth_controller.dart';
import 'package:fitkarma/features/auth/presentation/screens/phone_entry_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/pump_app.dart';

void main() {
  final testConfig = AppConfig.fromMap({
    'APP_ENV': 'development',
    'SUPABASE_URL': 'https://test.supabase.co',
    'SUPABASE_ANON_KEY': 'test-anon-key',
  });

  group('GoogleAuthController State Machine Tests', () {
    late MockSupabaseAuthService mockAuth;
    late GoogleAuthController controller;

    setUp(() {
      mockAuth = MockSupabaseAuthService();
      controller = GoogleAuthController(auth: mockAuth);
    });

    tearDown(() {
      controller.dispose();
    });

    test('initial state is idle with no loading and no failure', () {
      expect(controller.state.status, equals(GoogleAuthStatus.idle));
      expect(controller.state.isLoading, isFalse);
      expect(controller.state.failure, isNull);
    });

    test('signInWithGoogle success establishes authenticated session', () async {
      final success = await controller.signInWithGoogle();

      expect(success, isTrue);
      expect(controller.state.status, equals(GoogleAuthStatus.authenticated));
      expect(controller.state.isAuthenticated, isTrue);
      expect(controller.state.failure, isNull);
      expect(mockAuth.currentUser?.email, equals('user.fitkarma@gmail.com'));
      expect(mockAuth.currentUser?.userMetadata['provider'], equals('google'));
    });

    test('signInWithGoogle cancellation updates state to cancelled without failure error', () async {
      mockAuth.simulateCancellation = true;

      final success = await controller.signInWithGoogle();

      expect(success, isFalse);
      expect(controller.state.status, equals(GoogleAuthStatus.cancelled));
      expect(controller.state.isCancelled, isTrue);
      expect(controller.state.failure, isNull);
      expect(mockAuth.currentUser, isNull);
    });

    test('signInWithGoogle provider error records AuthFailure', () async {
      mockAuth.simulateProviderError = true;

      final success = await controller.signInWithGoogle();

      expect(success, isFalse);
      expect(controller.state.status, equals(GoogleAuthStatus.failure));
      expect(controller.state.failure, isA<AuthFailure>());
      expect(controller.state.failure?.details?['provider_error'], isTrue);
      expect(mockAuth.currentUser, isNull);
    });

    test('signOut clears active user session and resets state to idle', () async {
      // First sign in
      await controller.signInWithGoogle();
      expect(mockAuth.currentUser, isNotNull);

      // Sign out
      final result = await controller.signOut();
      expect(result.isSuccess, isTrue);
      expect(controller.state.status, equals(GoogleAuthStatus.idle));
      expect(mockAuth.currentUser, isNull);
      expect(mockAuth.currentSession, isNull);
    });
  });

  group('User Deduplication Tests', () {
    test('consecutive Google sign-ins with the same email reuse the existing user record', () async {
      final mockAuth = MockSupabaseAuthService();

      // First sign-in
      final firstRes = await mockAuth.signInWithGoogle();
      expect(firstRes.isSuccess, isTrue);
      final firstUser = mockAuth.currentUser!;
      final firstSession = mockAuth.currentSession!;

      // User signs out
      await mockAuth.signOut();
      expect(mockAuth.currentUser, isNull);

      // Second sign-in with the exact same Google account
      final secondRes = await mockAuth.signInWithGoogle();
      expect(secondRes.isSuccess, isTrue);
      final secondUser = mockAuth.currentUser!;
      final secondSession = mockAuth.currentSession!;

      // Verification: exact same user identity ID, no duplicate record created
      expect(secondUser.id, equals(firstUser.id));
      expect(secondUser.email, equals(firstUser.email));
      expect(secondUser.createdAt, equals(firstUser.createdAt));
      expect(secondSession.user.id, equals(firstSession.user.id));
    });
  });

  group('PhoneEntryScreen Google Sign-In UI Tests', () {
    testWidgets('renders Continue with Google button and or divider', (
      tester,
    ) async {
      final mockAuth = MockSupabaseAuthService();

      await tester.pumpFitKarmaWidget(
        const PhoneEntryScreen(),
        overrides: [
          supabaseAuthServiceProvider.overrideWithValue(mockAuth),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('google_sign_in_button')), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('or'), findsOneWidget);
    });

    testWidgets('cancelling Google Sign-In displays subtle cancellation toast', (
      tester,
    ) async {
      final mockAuth = MockSupabaseAuthService();
      mockAuth.simulateCancellation = true;

      await tester.pumpFitKarmaWidget(
        const PhoneEntryScreen(),
        overrides: [
          supabaseAuthServiceProvider.overrideWithValue(mockAuth),
        ],
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('google_sign_in_button')));
      await tester.pumpAndSettle();

      expect(find.text('Google Sign-In was cancelled.'), findsOneWidget);
    });

    testWidgets('Google provider error displays error toast', (
      tester,
    ) async {
      final mockAuth = MockSupabaseAuthService();
      mockAuth.simulateProviderError = true;

      await tester.pumpFitKarmaWidget(
        const PhoneEntryScreen(),
        overrides: [
          supabaseAuthServiceProvider.overrideWithValue(mockAuth),
        ],
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('google_sign_in_button')));
      await tester.pumpAndSettle();

      expect(
        find.text('Google authentication provider error occurred.'),
        findsOneWidget,
      );
    });
  });

  group('Google Sign-In & Logout End-to-End Routing Tests', () {
    testWidgets('sign-in redirects to Dashboard; logout button redirects back to Onboarding', (
      tester,
    ) async {
      final mockSupabase = MockSupabaseService();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(testConfig),
            supabaseServiceProvider.overrideWithValue(mockSupabase),
          ],
          child: const FitKarmaApp(),
        ),
      );
      await tester.pumpAndSettle();

      // Initially unauthenticated -> redirects to Onboarding
      expect(find.byKey(const Key('screen_onboarding')), findsOneWidget);

      final container = ProviderScope.containerOf(
        tester.element(find.byType(FitKarmaApp)),
      );

      // Perform Google Sign-In via controller
      final googleController = container.read(googleAuthControllerProvider.notifier);
      final success = await googleController.signInWithGoogle();
      expect(success, isTrue);

      // Auth state updates
      expect(container.read(isAuthenticatedProvider), isTrue);
      expect(container.read(authNavStatusProvider), equals(AuthNavStatus.authenticated));

      // Router reacts and displays Dashboard
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('screen_dashboard')), findsOneWidget);

      // Logout button is present in AppBar
      expect(find.byKey(const Key('logout_button')), findsOneWidget);

      // Tap logout
      await tester.tap(find.byKey(const Key('logout_button')));
      await tester.pumpAndSettle();

      // Session cleared
      expect(container.read(isAuthenticatedProvider), isFalse);
      expect(container.read(authNavStatusProvider), equals(AuthNavStatus.unauthenticated));

      // Router automatically redirects back to Onboarding!
      expect(find.byKey(const Key('screen_onboarding')), findsOneWidget);
    });
  });
}
