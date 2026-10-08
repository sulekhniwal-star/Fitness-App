import 'package:fitkarma/core/errors/failures.dart';
import 'package:fitkarma/core/errors/result.dart';
import 'package:fitkarma/core/supabase/supabase_providers.dart';
import 'package:fitkarma/core/supabase/supabase_service_boundary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lifecycle statuses for Google OAuth authentication.
enum GoogleAuthStatus {
  idle,
  authenticating,
  authenticated,
  cancelled,
  failure,
}

/// Immutable state for Google authentication.
class GoogleAuthState {
  final GoogleAuthStatus status;
  final AppFailure? failure;

  const GoogleAuthState({
    this.status = GoogleAuthStatus.idle,
    this.failure,
  });

  bool get isLoading => status == GoogleAuthStatus.authenticating;
  bool get isCancelled => status == GoogleAuthStatus.cancelled;
  bool get isAuthenticated => status == GoogleAuthStatus.authenticated;

  GoogleAuthState copyWith({
    GoogleAuthStatus? status,
    AppFailure? failure,
    bool clearFailure = false,
  }) {
    return GoogleAuthState(
      status: status ?? this.status,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GoogleAuthState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          failure == other.failure;

  @override
  int get hashCode => Object.hash(status, failure);
}

/// Controller managing Google OAuth / Native Sign-In flows, cancellation,
/// provider errors, and session sign-out.
class GoogleAuthController extends StateNotifier<GoogleAuthState> {
  final ISupabaseAuthService _authService;

  GoogleAuthController({
    required ISupabaseAuthService auth,
    GoogleAuthState initialState = const GoogleAuthState(),
  }) : _authService = auth,
       super(initialState);

  /// Initiates the Google Sign-In flow.
  Future<bool> signInWithGoogle({
    String? idToken,
    String? accessToken,
    String? redirectTo,
  }) async {
    state = state.copyWith(
      status: GoogleAuthStatus.authenticating,
      clearFailure: true,
    );

    final result = await _authService.signInWithGoogle(
      idToken: idToken,
      accessToken: accessToken,
      redirectTo: redirectTo,
    );

    switch (result) {
      case Success():
        state = state.copyWith(
          status: GoogleAuthStatus.authenticated,
          clearFailure: true,
        );
        return true;
      case FailureResult(:final failure):
        final isCancelled =
            failure.details?['cancelled'] == true ||
            failure.message.toLowerCase().contains('cancel');

        if (isCancelled) {
          state = state.copyWith(
            status: GoogleAuthStatus.cancelled,
            clearFailure: true,
          );
          return false;
        }

        state = state.copyWith(
          status: GoogleAuthStatus.failure,
          failure: failure,
        );
        return false;
    }
  }

  /// Signs out of the active user session.
  Future<Result<void>> signOut() async {
    final result = await _authService.signOut();
    state = const GoogleAuthState();
    return result;
  }

  /// Clears any active error state.
  void clearFailure() {
    if (state.failure != null) {
      state = state.copyWith(
        status: GoogleAuthStatus.idle,
        clearFailure: true,
      );
    }
  }

  /// Resets state back to idle.
  void reset() {
    state = const GoogleAuthState();
  }
}

/// Riverpod provider for [GoogleAuthController].
final googleAuthControllerProvider =
    StateNotifierProvider<GoogleAuthController, GoogleAuthState>((ref) {
      final authService = ref.watch(supabaseAuthServiceProvider);
      return GoogleAuthController(auth: authService);
    }, name: 'googleAuthControllerProvider');
