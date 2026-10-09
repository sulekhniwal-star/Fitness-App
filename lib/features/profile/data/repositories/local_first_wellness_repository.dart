import 'dart:async';

import 'package:fitkarma/core/errors/failures.dart';
import 'package:fitkarma/core/errors/result.dart';
import 'package:fitkarma/core/supabase/supabase_service_boundary.dart';
import 'package:fitkarma/features/profile/domain/repositories/user_profile_repository.dart';
import 'package:fitkarma/features/profile/domain/repositories/wellness_profile_repository.dart';
import 'package:fitkarma/features/profile/domain/wellness/dosha_score.dart';
import 'package:fitkarma/features/profile/domain/wellness/wellness_profile.dart';

/// Local-first implementation of [IWellnessProfileRepository].
///
/// Features immediate in-memory cache updates, reactive broadcast stream,
/// integration with [IUserProfileRepository] metadata synchronization, and
/// offline resilience.
class LocalFirstWellnessRepository implements IWellnessProfileRepository {
  final ISupabaseService? _supabase;
  final IUserProfileRepository? _profileRepo;

  WellnessProfile? _cachedProfile;
  final StreamController<WellnessProfile?> _streamController =
      StreamController<WellnessProfile?>.broadcast();

  LocalFirstWellnessRepository({
    ISupabaseService? supabaseService,
    IUserProfileRepository? profileRepository,
  })  : _supabase = supabaseService,
        _profileRepo = profileRepository;

  String _resolveUserId(String? providedId) {
    if (providedId != null && providedId.isNotEmpty) {
      return providedId;
    }
    final authUserId = _supabase?.auth.currentUser?.id;
    if (authUserId != null && authUserId.isNotEmpty) {
      return authUserId;
    }
    return 'local_user';
  }

  @override
  Future<Result<WellnessProfile?>> getWellnessProfile({String? userId}) async {
    final effectiveId = _resolveUserId(userId);

    if (_cachedProfile != null && _cachedProfile!.userId == effectiveId) {
      return Result.success(_cachedProfile);
    }

    // Try loading from parent UserProfile metadata if available
    final repo = _profileRepo;
    if (repo != null) {
      try {
        final profileResult = await repo.getProfile();
        if (profileResult.isSuccess && profileResult.dataOrNull != null) {
          final userProfile = profileResult.dataOrNull!;
          // If UserProfile has an explicit dosha set without a detailed wellness profile
          if (_cachedProfile == null && userProfile.dosha != null) {
            final recovered = WellnessProfile(
              id: 'wp_$effectiveId',
              userId: effectiveId,
              dominantDosha: userProfile.dosha!,
              secondaryDosha: null,
              score: DoshaScore.empty(),
              rawAnswers: const {},
              recommendations: const [],
              isCompleted: true,
              isSkipped: false,
              completedAt: userProfile.updatedAt,
              updatedAt: userProfile.updatedAt,
            );
            _cachedProfile = recovered;
            _streamController.add(recovered);
            return Result.success(recovered);
          }
        }
      } catch (_) {
        // Fallback safely to empty cache
      }
    }

    return Result.success(_cachedProfile);
  }

  @override
  Stream<WellnessProfile?> watchWellnessProfile({String? userId}) async* {
    yield _cachedProfile;
    yield* _streamController.stream;
  }

  @override
  Future<Result<WellnessProfile>> saveWellnessProfile(
    WellnessProfile profile,
  ) async {
    try {
      _cachedProfile = profile;
      _streamController.add(profile);

      // Synchronize with UserProfile.dosha if repository is provided
      final repo = _profileRepo;
      if (repo != null) {
        final profileResult = await repo.getProfile();
        if (profileResult.isSuccess && profileResult.dataOrNull != null) {
          final currentProfile = profileResult.dataOrNull!;
          final updated = currentProfile.copyWith(
            dosha: profile.dominantDosha,
          );
          await repo.saveProfile(updated);
        }
      }

      return Result.success(profile);
    } catch (e) {
      return Result.failure(
        InternalFailure(
          message: 'Failed to persist wellness profile: $e',
          details: {'error': e.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<void>> skipWellnessProfile({required String userId}) async {
    try {
      final skipped = WellnessProfile.initial(userId: userId, isSkipped: true);
      _cachedProfile = skipped;
      _streamController.add(skipped);

      final repo = _profileRepo;
      if (repo != null) {
        final profileResult = await repo.getProfile();
        if (profileResult.isSuccess && profileResult.dataOrNull != null) {
          final currentProfile = profileResult.dataOrNull!;
          final updated = currentProfile.copyWith(dosha: null);
          await repo.saveProfile(updated);
        }
      }

      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        InternalFailure(
          message: 'Failed to record skipped wellness profile: $e',
          details: {'error': e.toString()},
        ),
      );
    }
  }

  @override
  Future<Result<void>> resetWellnessProfile({required String userId}) async {
    try {
      _cachedProfile = null;
      _streamController.add(null);

      final repo = _profileRepo;
      if (repo != null) {
        final profileResult = await repo.getProfile();
        if (profileResult.isSuccess && profileResult.dataOrNull != null) {
          final currentProfile = profileResult.dataOrNull!;
          final updated = currentProfile.copyWith(dosha: null);
          await repo.saveProfile(updated);
        }
      }

      return const Result.success(null);
    } catch (e) {
      return Result.failure(
        InternalFailure(
          message: 'Failed to reset wellness profile: $e',
          details: {'error': e.toString()},
        ),
      );
    }
  }

  void dispose() {
    _streamController.close();
  }
}
