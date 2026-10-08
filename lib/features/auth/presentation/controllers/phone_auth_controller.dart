import 'dart:async';

import 'package:fitkarma/core/errors/failures.dart';
import 'package:fitkarma/core/errors/result.dart';
import 'package:fitkarma/core/supabase/supabase_providers.dart';
import 'package:fitkarma/core/supabase/supabase_service_boundary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Status of the phone OTP authentication lifecycle.
enum PhoneAuthStatus {
  idle,
  sendingOtp,
  otpSent,
  verifyingOtp,
  verified,
  failure,
}

/// Immutable state for the phone OTP authentication flow.
class PhoneAuthState {
  final PhoneAuthStatus status;
  final String phoneNumber; // 10-digit national number (e.g. 9876543210)
  final String countryCode; // E.g. +91
  final AppFailure? failure;
  final int resendCooldown; // Seconds remaining until resend is enabled

  const PhoneAuthState({
    this.status = PhoneAuthStatus.idle,
    this.phoneNumber = '',
    this.countryCode = '+91',
    this.failure,
    this.resendCooldown = 0,
  });

  /// Fully formatted E.164 phone string (e.g. +919876543210).
  String get fullPhoneNumber => '$countryCode$phoneNumber';

  /// Masked phone number for privacy display (e.g. +91 98••• ••210).
  String get maskedPhoneNumber {
    if (phoneNumber.length < 10) return fullPhoneNumber;
    final start = phoneNumber.substring(0, 2);
    final end = phoneNumber.substring(8);
    return '$countryCode $start••• ••$end';
  }

  /// Whether a network operation is in flight.
  bool get isLoading =>
      status == PhoneAuthStatus.sendingOtp ||
      status == PhoneAuthStatus.verifyingOtp;

  /// Whether the user can trigger a resend operation.
  bool get canResend => resendCooldown <= 0 && !isLoading;

  /// Whether authentication succeeded.
  bool get isVerified => status == PhoneAuthStatus.verified;

  PhoneAuthState copyWith({
    PhoneAuthStatus? status,
    String? phoneNumber,
    String? countryCode,
    AppFailure? failure,
    bool clearFailure = false,
    int? resendCooldown,
  }) {
    return PhoneAuthState(
      status: status ?? this.status,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
      failure: clearFailure ? null : (failure ?? this.failure),
      resendCooldown: resendCooldown ?? this.resendCooldown,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PhoneAuthState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          phoneNumber == other.phoneNumber &&
          countryCode == other.countryCode &&
          failure == other.failure &&
          resendCooldown == other.resendCooldown;

  @override
  int get hashCode => Object.hash(
    status,
    phoneNumber,
    countryCode,
    failure,
    resendCooldown,
  );
}

/// Controller managing Phone OTP state, countdown timers, and Supabase Auth interactions.
class PhoneAuthController extends StateNotifier<PhoneAuthState> {
  final ISupabaseAuthService _authService;
  Timer? _countdownTimer;

  PhoneAuthController({
    required ISupabaseAuthService auth,
    PhoneAuthState initialState = const PhoneAuthState(),
  }) : _authService = auth,
       super(initialState);

  static const int defaultCooldownSeconds = 30;
  static final RegExp _indianPhoneRegex = RegExp(r'^[6-9]\d{9}$');

  /// Normalizes and validates Indian 10-digit mobile phone numbers.
  static String? normalizeIndianPhone(String input) {
    // Strip spaces, dashes, parentheses
    String cleaned = input.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.startsWith('+91')) {
      cleaned = cleaned.substring(3);
    } else if (cleaned.startsWith('91') && cleaned.length == 12) {
      cleaned = cleaned.substring(2);
    } else if (cleaned.startsWith('0') && cleaned.length == 11) {
      cleaned = cleaned.substring(1);
    }

    if (_indianPhoneRegex.hasMatch(cleaned)) {
      return cleaned;
    }
    return null;
  }

  /// Initiates OTP delivery to the specified mobile phone number.
  Future<bool> sendOtp(String rawPhone) async {
    final normalized = normalizeIndianPhone(rawPhone);
    if (normalized == null) {
      state = state.copyWith(
        status: PhoneAuthStatus.failure,
        failure: const ValidationFailure(
          message: 'Please enter a valid 10-digit Indian mobile number',
        ),
      );
      return false;
    }

    state = state.copyWith(
      status: PhoneAuthStatus.sendingOtp,
      phoneNumber: normalized,
      clearFailure: true,
    );

    final result = await _authService.signInWithOtp(
      phone: state.fullPhoneNumber,
    );

    switch (result) {
      case Success():
        _startResendTimer(defaultCooldownSeconds);
        state = state.copyWith(
          status: PhoneAuthStatus.otpSent,
          clearFailure: true,
        );
        return true;
      case FailureResult(:final failure):
        state = state.copyWith(
          status: PhoneAuthStatus.failure,
          failure: failure,
        );
        return false;
    }
  }

  /// Verifies the entered 6-digit OTP token against Supabase Auth.
  Future<bool> verifyOtp(String rawToken) async {
    final cleaned = rawToken.replaceAll(RegExp(r'\s'), '');
    if (cleaned.length != 6 || !RegExp(r'^\d{6}$').hasMatch(cleaned)) {
      state = state.copyWith(
        status: PhoneAuthStatus.failure,
        failure: const ValidationFailure(
          message: 'Please enter a valid 6-digit verification code',
        ),
      );
      return false;
    }

    state = state.copyWith(
      status: PhoneAuthStatus.verifyingOtp,
      clearFailure: true,
    );

    final result = await _authService.verifyOtp(
      phone: state.fullPhoneNumber,
      token: cleaned,
    );

    switch (result) {
      case Success():
        _countdownTimer?.cancel();
        state = state.copyWith(
          status: PhoneAuthStatus.verified,
          clearFailure: true,
        );
        return true;
      case FailureResult(:final failure):
        state = state.copyWith(
          status: PhoneAuthStatus.failure,
          failure: failure,
        );
        return false;
    }
  }

  /// Resends OTP to the currently held phone number if cooldown has elapsed.
  Future<bool> resendOtp() async {
    if (!state.canResend || state.phoneNumber.isEmpty) {
      return false;
    }

    state = state.copyWith(
      status: PhoneAuthStatus.sendingOtp,
      clearFailure: true,
    );

    final result = await _authService.signInWithOtp(
      phone: state.fullPhoneNumber,
    );

    switch (result) {
      case Success():
        _startResendTimer(defaultCooldownSeconds);
        state = state.copyWith(
          status: PhoneAuthStatus.otpSent,
          clearFailure: true,
        );
        return true;
      case FailureResult(:final failure):
        state = state.copyWith(
          status: PhoneAuthStatus.failure,
          failure: failure,
        );
        return false;
    }
  }

  /// Clears any active error failure.
  void clearFailure() {
    if (state.failure != null) {
      state = state.copyWith(clearFailure: true);
    }
  }

  /// Resets state back to idle for phone re-entry.
  void reset() {
    _countdownTimer?.cancel();
    state = const PhoneAuthState();
  }

  void _startResendTimer(int seconds) {
    _countdownTimer?.cancel();
    state = state.copyWith(resendCooldown: seconds);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.resendCooldown <= 1) {
        timer.cancel();
        state = state.copyWith(resendCooldown: 0);
      } else {
        state = state.copyWith(resendCooldown: state.resendCooldown - 1);
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }
}

/// Provider for [PhoneAuthController].
final phoneAuthControllerProvider =
    StateNotifierProvider<PhoneAuthController, PhoneAuthState>((ref) {
      final authService = ref.watch(supabaseAuthServiceProvider);
      return PhoneAuthController(auth: authService);
    }, name: 'phoneAuthControllerProvider');
