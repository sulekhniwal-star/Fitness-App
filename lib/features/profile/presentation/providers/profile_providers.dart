import 'package:fitkarma/core/errors/result.dart';
import 'package:fitkarma/core/supabase/supabase_providers.dart';
import 'package:fitkarma/features/profile/data/repositories/local_first_profile_repository.dart';
import 'package:fitkarma/features/profile/domain/models/user_profile.dart';
import 'package:fitkarma/features/profile/domain/repositories/user_profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for [IUserProfileRepository].
final userProfileRepositoryProvider = Provider<IUserProfileRepository>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  return LocalFirstProfileRepository(supabaseService: supabase);
}, name: 'userProfileRepositoryProvider');

/// Stream provider for the active user's profile state.
final userProfileStreamProvider = StreamProvider<UserProfile?>((ref) {
  final repo = ref.watch(userProfileRepositoryProvider);
  return repo.watchProfile();
}, name: 'userProfileStreamProvider');

/// Read-only snapshot of the current user profile.
final currentProfileProvider = Provider<UserProfile?>((ref) {
  final streamState = ref.watch(userProfileStreamProvider);
  return streamState.value;
}, name: 'currentProfileProvider');

/// Controller managing profile mutations and synchronization state.
class ProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final IUserProfileRepository _repository;

  ProfileNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadProfile();
  }

  /// Loads or refreshes the profile.
  Future<void> loadProfile({bool forceRefresh = false}) async {
    state = const AsyncValue.loading();
    final result = await _repository.getProfile(forceRefresh: forceRefresh);
    switch (result) {
      case Success(:final data):
        state = AsyncValue.data(data);
      case FailureResult(:final failure):
        state = AsyncValue.error(failure, StackTrace.current);
    }
  }

  /// Validates and saves profile updates.
  Future<Result<UserProfile>> saveProfile(UserProfile profile) async {
    state = const AsyncValue.loading();
    final result = await _repository.saveProfile(profile);
    switch (result) {
      case Success(:final data):
        state = AsyncValue.data(data);
        return Success(data);
      case FailureResult(:final failure):
        state = AsyncValue.error(failure, StackTrace.current);
        return FailureResult(failure);
    }
  }

  /// Triggers server sync for pending local changes.
  Future<Result<void>> syncWithServer() async {
    return _repository.syncWithServer();
  }

  /// Clears local profile cache (e.g. on user sign-out).
  Future<void> clearCache() async {
    await _repository.clearLocalCache();
    state = const AsyncValue.data(null);
  }
}

/// Provider for [ProfileNotifier].
final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, AsyncValue<UserProfile?>>((ref) {
      final repo = ref.watch(userProfileRepositoryProvider);
      return ProfileNotifier(repo);
    }, name: 'profileNotifierProvider');
