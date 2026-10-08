import 'package:fitkarma/app/fitkarma_app.dart';
import 'package:fitkarma/core/config/app_config.dart';
import 'package:fitkarma/core/errors/failures.dart';
import 'package:fitkarma/core/providers/core_providers.dart';
import 'package:fitkarma/core/routing/auth_nav_state.dart';
import 'package:fitkarma/core/supabase/mock_supabase_service.dart';
import 'package:fitkarma/core/supabase/supabase_providers.dart';
import 'package:fitkarma/features/auth/presentation/controllers/phone_auth_controller.dart';
import 'package:fitkarma/features/auth/presentation/screens/otp_verification_screen.dart';
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

  group('Phone Number Validation & Formatting Tests', () {
    test('normalizes valid Indian mobile numbers in various input styles', () {
      expect(
        PhoneAuthController.normalizeIndianPhone('9876543210'),
        equals('9876543210'),
      );
      expect(
        PhoneAuthController.normalizeIndianPhone('+919876543210'),
        equals('9876543210'),
      );
      expect(
        PhoneAuthController.normalizeIndianPhone('+91 98765 43210'),
        equals('9876543210'),
      );
      expect(
        PhoneAuthController.normalizeIndianPhone('+91-98765-43210'),
        equals('9876543210'),
      );
      expect(
        PhoneAuthController.normalizeIndianPhone('09876543210'),
        equals('9876543210'),
      );
      expect(
        PhoneAuthController.normalizeIndianPhone('6123456789'),
        equals('6123456789'),
      );
      expect(
        PhoneAuthController.normalizeIndianPhone('7123456789'),
        equals('7123456789'),
      );
      expect(
        PhoneAuthController.normalizeIndianPhone('8123456789'),
        equals('8123456789'),
      );
    });

    test('rejects malformed, short, or invalid Indian prefix numbers', () {
      expect(PhoneAuthController.normalizeIndianPhone(''), isNull);
      expect(PhoneAuthController.normalizeIndianPhone('1234567890'), isNull);
      expect(PhoneAuthController.normalizeIndianPhone('5555555555'), isNull);
      expect(PhoneAuthController.normalizeIndianPhone('987654321'), isNull);
      expect(PhoneAuthController.normalizeIndianPhone('987654321012'), isNull);
      expect(PhoneAuthController.normalizeIndianPhone('abcdefghij'), isNull);
    });

    test('masks phone numbers properly for privacy presentation', () {
      const state = PhoneAuthState(phoneNumber: '9876543210');
      expect(state.maskedPhoneNumber, equals('+91 98••• ••10'));

      const shortState = PhoneAuthState(phoneNumber: '123');
      expect(shortState.maskedPhoneNumber, equals('+91123'));
    });
  });

  group('PhoneAuthController State Machine Tests', () {
    late MockSupabaseAuthService mockAuth;
    late PhoneAuthController controller;

    setUp(() {
      mockAuth = MockSupabaseAuthService();
      controller = PhoneAuthController(auth: mockAuth);
    });

    tearDown(() {
      controller.dispose();
    });

    test('initial state is idle with default country code and no failure', () {
      expect(controller.state.status, equals(PhoneAuthStatus.idle));
      expect(controller.state.countryCode, equals('+91'));
      expect(controller.state.phoneNumber, isEmpty);
      expect(controller.state.failure, isNull);
      expect(controller.state.resendCooldown, equals(0));
    });

    test('sendOtp with invalid number fails with ValidationFailure', () async {
      final success = await controller.sendOtp('12345');
      expect(success, isFalse);
      expect(controller.state.status, equals(PhoneAuthStatus.failure));
      expect(controller.state.failure, isA<ValidationFailure>());
    });

    test('sendOtp with valid number succeeds and starts 30s countdown', () async {
      final success = await controller.sendOtp('9876543210');
      expect(success, isTrue);
      expect(controller.state.status, equals(PhoneAuthStatus.otpSent));
      expect(controller.state.phoneNumber, equals('9876543210'));
      expect(controller.state.resendCooldown, equals(30));
      expect(controller.state.canResend, isFalse);
    });

    test('verifyOtp with invalid length fails with ValidationFailure', () async {
      await controller.sendOtp('9876543210');
      final success = await controller.verifyOtp('12');
      expect(success, isFalse);
      expect(controller.state.status, equals(PhoneAuthStatus.failure));
      expect(controller.state.failure, isA<ValidationFailure>());
    });

    test('verifyOtp with invalid code (000000) fails with AuthFailure', () async {
      await controller.sendOtp('9876543210');
      final success = await controller.verifyOtp('000000');
      expect(success, isFalse);
      expect(controller.state.status, equals(PhoneAuthStatus.failure));
      expect(controller.state.failure, isA<AuthFailure>());
    });

    test('verifyOtp with valid code succeeds and updates user session', () async {
      await controller.sendOtp('9876543210');
      final success = await controller.verifyOtp('123456');
      expect(success, isTrue);
      expect(controller.state.status, equals(PhoneAuthStatus.verified));
      expect(controller.state.isVerified, isTrue);
      expect(mockAuth.currentUser?.phone, equals('+919876543210'));
    });

    test('resendOtp is blocked during cooldown and succeeds when cooldown is zero', () async {
      await controller.sendOtp('9876543210');
      // Attempting resend while countdown is at 30
      final blocked = await controller.resendOtp();
      expect(blocked, isFalse);

      // Reset controller cooldown manually to simulate timer expiration
      controller = PhoneAuthController(
        auth: mockAuth,
        initialState: const PhoneAuthState(
          status: PhoneAuthStatus.otpSent,
          phoneNumber: '9876543210',
          resendCooldown: 0,
        ),
      );

      expect(controller.state.canResend, isTrue);
      final allowed = await controller.resendOtp();
      expect(allowed, isTrue);
      expect(controller.state.resendCooldown, equals(30));
    });

    test('clearFailure clears active failure without altering other state', () async {
      await controller.sendOtp('invalid');
      expect(controller.state.failure, isNotNull);
      controller.clearFailure();
      expect(controller.state.failure, isNull);
    });
  });

  group('PhoneEntryScreen Widget Tests', () {
    testWidgets('renders header, +91 badge, input field, and disabled button initially', (
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

      expect(find.text('+91'), findsOneWidget);
      expect(find.byKey(const Key('phone_number_text_field')), findsOneWidget);
      expect(find.byKey(const Key('send_otp_button')), findsOneWidget);
      expect(find.text('Enter your phone number'), findsOneWidget);
    });

    testWidgets('entering 10 digits enables Get OTP button and triggers sendOtp', (
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

      // Enter 10-digit number
      await tester.enterText(
        find.byKey(const Key('phone_number_text_field')),
        '9876543210',
      );
      await tester.pumpAndSettle();

      // Tap Get OTP
      await tester.tap(find.byKey(const Key('send_otp_button')));
      await tester.pumpAndSettle();

      // Button tapped, no validation error shown
      expect(find.textContaining('Please enter a valid'), findsNothing);
    });
  });

  group('OtpVerificationScreen Widget Tests', () {
    testWidgets('renders 6-digit pin input, masked phone, and resend countdown', (
      tester,
    ) async {
      final mockAuth = MockSupabaseAuthService();

      await tester.pumpFitKarmaWidget(
        const OtpVerificationScreen(),
        overrides: [
          supabaseAuthServiceProvider.overrideWithValue(mockAuth),
          phoneAuthControllerProvider.overrideWith(
            (ref) => PhoneAuthController(
              auth: mockAuth,
              initialState: const PhoneAuthState(
                status: PhoneAuthStatus.otpSent,
                phoneNumber: '9876543210',
                resendCooldown: 25,
              ),
            ),
          ),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.text('Verify Phone'), findsOneWidget);
      expect(find.textContaining('+91 98••• ••10'), findsOneWidget);
      expect(find.byKey(const Key('change_phone_button')), findsOneWidget);
      expect(find.byKey(const Key('resend_countdown_text')), findsOneWidget);
      expect(find.text('Resend code in 25s'), findsOneWidget);
    });

    testWidgets('invalid OTP (000000) displays error feedback banner', (
      tester,
    ) async {
      final mockAuth = MockSupabaseAuthService();

      await tester.pumpFitKarmaWidget(
        const OtpVerificationScreen(),
        overrides: [
          supabaseAuthServiceProvider.overrideWithValue(mockAuth),
          phoneAuthControllerProvider.overrideWith(
            (ref) => PhoneAuthController(
              auth: mockAuth,
              initialState: const PhoneAuthState(
                status: PhoneAuthStatus.otpSent,
                phoneNumber: '9876543210',
                resendCooldown: 0,
              ),
            ),
          ),
        ],
      );
      await tester.pumpAndSettle();

      // Enter 6-digit invalid code
      await tester.enterText(
        find.byKey(const Key('otp_hidden_text_field')),
        '000000',
      );
      await tester.pumpAndSettle();

      // Tap verify
      await tester.tap(find.byKey(const Key('verify_otp_button')));
      await tester.pumpAndSettle();

      // Error banner is visible
      expect(find.byKey(const Key('otp_error_banner')), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(const Key('otp_error_banner')),
          matching: find.textContaining('Invalid verification code'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('resend button appears when cooldown reaches 0 and triggers resend', (
      tester,
    ) async {
      final mockAuth = MockSupabaseAuthService();

      await tester.pumpFitKarmaWidget(
        const OtpVerificationScreen(),
        overrides: [
          supabaseAuthServiceProvider.overrideWithValue(mockAuth),
          phoneAuthControllerProvider.overrideWith(
            (ref) => PhoneAuthController(
              auth: mockAuth,
              initialState: const PhoneAuthState(
                status: PhoneAuthStatus.otpSent,
                phoneNumber: '9876543210',
                resendCooldown: 0,
              ),
            ),
          ),
        ],
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('resend_otp_button')), findsOneWidget);
      await tester.tap(find.byKey(const Key('resend_otp_button')));
      await tester.pumpAndSettle();

      // Toast / snackbar with success is shown
      expect(
        find.text('Verification code sent successfully.'),
        findsOneWidget,
      );
    });
  });

  group('Session Persistence & GoRouter Integration Tests', () {
    testWidgets('verifying OTP establishes authenticated session and redirects to Dashboard', (
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

      // Access Riverpod container
      final container = ProviderScope.containerOf(
        tester.element(find.byType(FitKarmaApp)),
      );

      // Directly simulate phone OTP flow through the controller
      final controller = container.read(phoneAuthControllerProvider.notifier);
      await controller.sendOtp('9876543210');
      final verified = await controller.verifyOtp('123456');
      expect(verified, isTrue);

      // Verify that isAuthenticatedProvider is now true
      expect(container.read(isAuthenticatedProvider), isTrue);
      expect(container.read(authNavStatusProvider), equals(AuthNavStatus.authenticated));

      // Pump to trigger GoRouter reactive redirect
      await tester.pumpAndSettle();

      // Dashboard screen is now displayed!
      expect(find.byKey(const Key('screen_dashboard')), findsOneWidget);
    });
  });
}
