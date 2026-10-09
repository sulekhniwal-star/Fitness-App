import 'package:fitkarma/core/errors/result.dart';
import 'package:fitkarma/features/profile/domain/models/user_profile.dart';

/// Repository boundary for user profile domain entity.
///
/// Encapsulates local-first persistence, client-side validation, and
/// server synchronization behind this interface.
abstract interface class IUserProfileRepository {
  /// Fetches the profile for the currently authenticated user.
  ///
  /// Returns the local cached profile first; fetches from server if cache
  /// is empty or if [forceRefresh] is requested.
  Future<Result<UserProfile?>> getProfile({bool forceRefresh = false});

  /// Reactive stream of the current user's profile state.
  Stream<UserProfile?> watchProfile();

  /// Validates and saves the user profile.
  ///
  /// Writes locally first, then synchronously or asynchronously reconciles
  /// with the Supabase backend.
  Future<Result<UserProfile>> saveProfile(UserProfile profile);

  /// Synchronizes any pending local changes with the remote Supabase database.
  Future<Result<void>> syncWithServer();

  /// Clears local cache (called on sign-out).
  Future<Result<void>> clearLocalCache();
}
