import 'package:fitkarma/core/errors/result.dart';
import 'package:fitkarma/features/profile/domain/wellness/wellness_profile.dart';

/// Contract for accessing and persisting user Ayurvedic wellness and Prakriti profiles.
///
/// Implementations must support local-first caching, reactive stream updates,
/// and safe failure propagation via the [Result] boundary.
abstract class IWellnessProfileRepository {
  /// Retrieves the active wellness profile for [userId].
  Future<Result<WellnessProfile?>> getWellnessProfile({String? userId});

  /// Emits reactive wellness profile updates.
  Stream<WellnessProfile?> watchWellnessProfile({String? userId});

  /// Saves or updates the calculated [profile].
  Future<Result<WellnessProfile>> saveWellnessProfile(WellnessProfile profile);

  /// Records that the user has intentionally skipped the assessment.
  Future<Result<void>> skipWellnessProfile({required String userId});

  /// Clears/resets the current wellness profile for [userId].
  Future<Result<void>> resetWellnessProfile({required String userId});
}
