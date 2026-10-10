import 'package:fitkarma/core/errors/result.dart';
import 'package:fitkarma/core/supabase/supabase_service_boundary.dart';
import 'package:fitkarma/features/auth/domain/models/account_lifecycle_models.dart';

/// Contract governing comprehensive account lifecycle management:
/// authentication termination, session restoration & expiration safeguards,
/// client deletion boundary with local wipe, and account recovery hooks.
abstract interface class IAccountLifecycleService {
  /// Signs out the user session and optionally wipes local memory/storage caches.
  Future<Result<void>> logout({bool wipeLocalData = true});

  /// Evaluates and restores persisted session on app launch.
  Future<SessionRestorationResult> restoreSession();

  /// Handles expired sessions safely without app crash or leaking stale user data.
  Future<Result<FitKarmaAuthSession>> handleSessionExpiration({
    bool attemptRefresh = true,
  });

  /// Client boundary for initiating account deletion (DPDP compliance).
  ///
  /// Records deletion request receipt and executes local data wipe.
  Future<Result<AccountDeletionReceipt>> requestAccountDeletion({
    String? reason,
    bool confirmDataLoss = true,
  });

  /// Cancels an active account deletion request if still within the grace period.
  Future<Result<AccountDeletionReceipt>> cancelAccountDeletion({
    required String requestId,
  });

  /// Checks the status of an existing deletion request receipt.
  Future<Result<AccountDeletionReceipt>> checkDeletionStatus({
    required String requestId,
  });

  /// Triggers the account recovery workflow (e.g. phone SMS OTP or email link).
  Future<Result<AccountRecoveryReceipt>> initiateAccountRecovery(
    AccountRecoveryRequest request,
  );
}
