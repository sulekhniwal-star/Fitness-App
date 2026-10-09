import 'dart:async';

import 'package:fitkarma/core/errors/failures.dart';
import 'package:fitkarma/core/errors/result.dart';
import 'package:fitkarma/core/supabase/supabase_client_service.dart';
import 'package:fitkarma/core/supabase/supabase_failure_mapper.dart';
import 'package:fitkarma/core/supabase/supabase_service_boundary.dart';
import 'package:fitkarma/features/profile/domain/models/user_profile.dart';
import 'package:fitkarma/features/profile/domain/repositories/user_profile_repository.dart';

/// Local-first implementation of [IUserProfileRepository].
///
/// Immediately records and validates profile updates locally before
/// synchronizing with Supabase in the background, preserving offline resilience.
class LocalFirstProfileRepository implements IUserProfileRepository {
  final ISupabaseService _supabase;
  final StreamController<UserProfile?> _profileStreamController =
      StreamController<UserProfile?>.broadcast();

  UserProfile? _cachedProfile;
  bool _hasPendingSync = false;

  LocalFirstProfileRepository({
    required ISupabaseService supabaseService,
    UserProfile? initialProfile,
  }) : _supabase = supabaseService,
       _cachedProfile = initialProfile;

  @override
  Stream<UserProfile?> watchProfile() async* {
    if (_cachedProfile != null) {
      yield _cachedProfile;
    }
    yield* _profileStreamController.stream;
  }

  @override
  Future<Result<UserProfile?>> getProfile({bool forceRefresh = false}) async {
    // 1. Return local cache if available and refresh is not forced
    if (_cachedProfile != null && !forceRefresh) {
      return Success(_cachedProfile);
    }

    final currentUser = _supabase.auth.currentUser;
    if (currentUser == null) {
      return const Success(null);
    }

    // In mock mode, return cached profile or mock baseline
    if (_supabase.isMock) {
      return Success(_cachedProfile);
    }

    // 2. Fetch latest profile from Supabase profiles table
    try {
      final supabase = _supabase;
      if (supabase is! SupabaseClientService) {
        return Success(_cachedProfile);
      }

      final client = supabase.rawClient;
      final response = await client
          .from('profiles')
          .select()
          .eq('user_id', currentUser.id)
          .maybeSingle();

      if (response == null) {
        return const Success(null);
      }

      final remoteProfile = UserProfile.fromDatabaseRow(
        response,
        isSynced: true,
      );
      _cachedProfile = remoteProfile;
      _hasPendingSync = false;
      _profileStreamController.add(_cachedProfile);
      return Success(remoteProfile);
    } catch (e, st) {
      // Offline fallback: preserve local profile if available
      if (_cachedProfile != null) {
        return Success(_cachedProfile);
      }
      return FailureResult(SupabaseFailureMapper.map(e, st));
    }
  }

  @override
  Future<Result<UserProfile>> saveProfile(UserProfile profile) async {
    // 1. Domain Validation
    final validationError = profile.validate();
    if (validationError != null) {
      return FailureResult(validationError);
    }

    // 2. Local-first persistence
    final localCopy = profile.copyWith(
      isSynced: false,
      updatedAt: DateTime.now(),
    );
    _cachedProfile = localCopy;
    _hasPendingSync = true;
    _profileStreamController.add(_cachedProfile);

    // 3. Server synchronization
    if (_supabase.isMock) {
      // Mock environment completes sync immediately
      _cachedProfile = localCopy.copyWith(isSynced: true);
      _hasPendingSync = false;
      _profileStreamController.add(_cachedProfile);
      return Success(_cachedProfile!);
    }

    try {
      final supabase = _supabase;
      if (supabase is SupabaseClientService) {
        final client = supabase.rawClient;
        final response = await client
            .from('profiles')
            .upsert(localCopy.toDatabaseRow())
            .select()
            .single();

        final syncedProfile = UserProfile.fromDatabaseRow(
          response,
          isSynced: true,
        );
        _cachedProfile = syncedProfile;
        _hasPendingSync = false;
        _profileStreamController.add(_cachedProfile);
        return Success(_cachedProfile!);
      }

      return Success(_cachedProfile!);
    } catch (e, st) {
      // Server sync failed or offline: preserve local record with pending sync
      final failure = SupabaseFailureMapper.map(e, st);
      if (failure is SyncFailure || failure is OfflineFailure) {
        _hasPendingSync = true;
        return Success(_cachedProfile!);
      }
      return FailureResult(failure);
    }
  }

  @override
  Future<Result<void>> syncWithServer() async {
    if (!_hasPendingSync || _cachedProfile == null) {
      return const Success(null);
    }

    final result = await saveProfile(_cachedProfile!);
    return switch (result) {
      Success() => const Success(null),
      FailureResult(:final failure) => FailureResult(failure),
    };
  }

  @override
  Future<Result<void>> clearLocalCache() async {
    _cachedProfile = null;
    _hasPendingSync = false;
    _profileStreamController.add(null);
    return const Success(null);
  }

  void dispose() {
    _profileStreamController.close();
  }
}
