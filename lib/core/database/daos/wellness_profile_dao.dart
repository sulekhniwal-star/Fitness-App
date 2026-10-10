import 'package:fitkarma/core/database/app_database.dart';

/// Data Access Object for local Ayurveda wellness profiles.
class WellnessProfileDao {
  final AppDatabase _db;

  WellnessProfileDao(this._db);

  /// Retrieves wellness profile by [userId].
  Future<LocalWellnessProfile?> getWellnessProfileByUserId(String userId) {
    return (_db.select(_db.localWellnessProfiles)
          ..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();
  }

  /// Watches wellness profile by [userId] as a reactive Stream.
  Stream<LocalWellnessProfile?> watchWellnessProfileByUserId(String userId) {
    return (_db.select(_db.localWellnessProfiles)
          ..where((t) => t.userId.equals(userId)))
        .watchSingleOrNull();
  }

  /// Inserts or updates a wellness profile.
  Future<int> upsertWellnessProfile(LocalWellnessProfilesCompanion companion) {
    return _db
        .into(_db.localWellnessProfiles)
        .insertOnConflictUpdate(companion);
  }

  /// Deletes a wellness profile by [userId].
  Future<int> deleteWellnessProfileByUserId(String userId) {
    return (_db.delete(_db.localWellnessProfiles)
          ..where((t) => t.userId.equals(userId)))
        .go();
  }
}
