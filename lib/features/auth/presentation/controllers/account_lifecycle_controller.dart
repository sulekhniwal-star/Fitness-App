import 'package:fitkarma/features/auth/domain/models/account_lifecycle_models.dart';
import 'package:fitkarma/features/auth/domain/services/account_lifecycle_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// State representation for account lifecycle operations.
class AccountLifecycleState {
  final bool isLoading;
  final bool isDeleting;
  final AccountDeletionReceipt? deletionReceipt;
  final SessionRestorationResult? restorationResult;
  final LocalWipeResult? lastWipeResult;
  final String? errorMessage;
  final String? successMessage;

  const AccountLifecycleState({
    this.isLoading = false,
    this.isDeleting = false,
    this.deletionReceipt,
    this.restorationResult,
    this.lastWipeResult,
    this.errorMessage,
    this.successMessage,
  });

  AccountLifecycleState copyWith({
    bool? isLoading,
    bool? isDeleting,
    AccountDeletionReceipt? deletionReceipt,
    SessionRestorationResult? restorationResult,
    LocalWipeResult? lastWipeResult,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
  }) {
    return AccountLifecycleState(
      isLoading: isLoading ?? this.isLoading,
      isDeleting: isDeleting ?? this.isDeleting,
      deletionReceipt: deletionReceipt ?? this.deletionReceipt,
      restorationResult: restorationResult ?? this.restorationResult,
      lastWipeResult: lastWipeResult ?? this.lastWipeResult,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: successMessage ?? this.successMessage,
    );
  }
}

/// Controller managing account logout, session restoration, deletion request,
/// and local data wiping.
class AccountLifecycleController extends StateNotifier<AccountLifecycleState> {
  final IAccountLifecycleService _lifecycleService;

  AccountLifecycleController(this._lifecycleService)
      : super(const AccountLifecycleState());

  /// Restores session on app startup.
  Future<SessionRestorationResult> restoreSession() async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _lifecycleService.restoreSession();
    state = state.copyWith(
      isLoading: false,
      restorationResult: result,
      errorMessage: result.isSuccessful ? null : result.message,
    );
    return result;
  }

  /// Signs out the user and coordinates local data wipe.
  Future<bool> logout({bool wipeLocalData = true}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _lifecycleService.logout(wipeLocalData: wipeLocalData);
    final isSuccess = result.isSuccess;
    state = state.copyWith(
      isLoading: false,
      errorMessage: result.isFailure ? result.failureOrNull?.message : null,
      successMessage: isSuccess ? 'Signed out successfully' : null,
    );
    return isSuccess;
  }

  /// Initiates account deletion and executes client-side data wiping.
  Future<AccountDeletionReceipt?> requestAccountDeletion({
    String? reason,
    bool confirmDataLoss = true,
  }) async {
    state = state.copyWith(isDeleting: true, clearError: true);
    final result = await _lifecycleService.requestAccountDeletion(
      reason: reason,
      confirmDataLoss: confirmDataLoss,
    );

    AccountDeletionReceipt? receipt;
    result.when(
      success: (data) {
        receipt = data;
        state = state.copyWith(
          isDeleting: false,
          deletionReceipt: data,
          successMessage: 'Account deletion initiated. Local data wiped.',
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isDeleting: false,
          errorMessage: failure.message,
        );
      },
    );
    return receipt;
  }

  /// Cancels an active account deletion request during the grace period.
  Future<bool> cancelAccountDeletion(String requestId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _lifecycleService.cancelAccountDeletion(
      requestId: requestId,
    );

    bool isSuccess = false;
    result.when(
      success: (updated) {
        isSuccess = true;
        state = state.copyWith(
          isLoading: false,
          deletionReceipt: updated,
          successMessage: 'Account deletion request cancelled.',
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
      },
    );
    return isSuccess;
  }
}
