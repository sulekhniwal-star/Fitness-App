import 'package:fitkarma/core/supabase/supabase_providers.dart';
import 'package:fitkarma/features/profile/data/repositories/local_first_wellness_repository.dart';
import 'package:fitkarma/features/profile/domain/repositories/wellness_profile_repository.dart';
import 'package:fitkarma/features/profile/domain/wellness/dosha_wellness_service.dart';
import 'package:fitkarma/features/profile/domain/wellness/wellness_profile.dart';
import 'package:fitkarma/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides the domain [DoshaWellnessService].
final doshaWellnessServiceProvider = Provider<DoshaWellnessService>((ref) {
  return const DoshaWellnessService();
});

/// Provides the [IWellnessProfileRepository].
final wellnessProfileRepositoryProvider =
    Provider<IWellnessProfileRepository>((ref) {
  final supabase = ref.watch(supabaseServiceProvider);
  final profileRepo = ref.watch(userProfileRepositoryProvider);
  return LocalFirstWellnessRepository(
    supabaseService: supabase,
    profileRepository: profileRepo,
  );
});

/// Reactive stream of the active [WellnessProfile].
final wellnessProfileStreamProvider =
    StreamProvider<WellnessProfile?>((ref) {
  final repository = ref.watch(wellnessProfileRepositoryProvider);
  return repository.watchWellnessProfile();
});

/// State controller managing interactive Dosha assessment, answering questions,
/// skipping, and saving results.
class WellnessController extends StateNotifier<AsyncValue<WellnessProfile?>> {
  final IWellnessProfileRepository _repo;
  final DoshaWellnessService _wellnessService;
  final String _uid;

  WellnessController({
    required IWellnessProfileRepository repository,
    required DoshaWellnessService service,
    required String userId,
  })  : _repo = repository,
        _wellnessService = service,
        _uid = userId,
        super(const AsyncValue.loading()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final result = await _repo.getWellnessProfile(userId: _uid);
    result.when(
      success: (profile) => state = AsyncValue.data(profile),
      failure: (failure) => state = AsyncValue.error(failure, StackTrace.current),
    );
  }

  /// Calculates and saves the profile from raw answers.
  Future<void> submitAssessment(Map<String, String> rawAnswers) async {
    state = const AsyncValue.loading();
    final profile = _wellnessService.buildProfile(
      userId: _uid,
      rawAnswers: rawAnswers,
    );
    final result = await _repo.saveWellnessProfile(profile);
    result.when(
      success: (saved) => state = AsyncValue.data(saved),
      failure: (failure) => state = AsyncValue.error(failure, StackTrace.current),
    );
  }

  /// Records an intentional skip.
  Future<void> skipAssessment() async {
    state = const AsyncValue.loading();
    final result = await _repo.skipWellnessProfile(userId: _uid);
    result.when(
      success: (_) {
        final skipped = WellnessProfile.initial(userId: _uid, isSkipped: true);
        state = AsyncValue.data(skipped);
      },
      failure: (failure) => state = AsyncValue.error(failure, StackTrace.current),
    );
  }

  /// Clears/resets the assessment so the user can retake it fresh.
  Future<void> resetAssessment() async {
    state = const AsyncValue.loading();
    final result = await _repo.resetWellnessProfile(userId: _uid);
    result.when(
      success: (_) => state = const AsyncValue.data(null),
      failure: (failure) => state = AsyncValue.error(failure, StackTrace.current),
    );
  }
}

/// Provider for [WellnessController].
final wellnessControllerProvider = StateNotifierProvider.autoDispose<
    WellnessController, AsyncValue<WellnessProfile?>>((ref) {
  final repository = ref.watch(wellnessProfileRepositoryProvider);
  final service = ref.watch(doshaWellnessServiceProvider);
  final currentUser = ref.watch(currentUserProvider);
  final userId = currentUser?.id ?? 'local_user';

  return WellnessController(
    repository: repository,
    service: service,
    userId: userId,
  );
});
