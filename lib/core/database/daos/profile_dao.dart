import 'package:fitkarma/core/database/app_database.dart';

/// Data Access Object for local user profiles.
class ProfileDao {
  final AppDatabase _db;

  ProfileDao(this._db);

  /// Retrieves a profile by [userId] if present.
  Future<LocalProfile?> getProfileByUserId(String userId) {
    return (_db.select(_db.localProfiles)
          ..where((t) => t.userId.equals(userId)))
        .getSingleOrNull();
  }

  /// Watches a profile by [userId] as a reactive Stream.
  Stream<LocalProfile?> watchProfileByUserId(String userId) {
    return (_db.select(_db.localProfiles)
          ..where((t) => t.userId.equals(userId)))
        .watchSingleOrNull();
  }

  /// Inserts or updates the given profile row.
  Future<int> upsertProfile(LocalProfilesCompanion companion) {
    return _db.into(_db.localProfiles).insertOnConflictUpdate(companion);
  }

  /// Deletes a profile by [userId].
  Future<int> deleteProfileByUserId(String userId) {
    return (_db.delete(_db.localProfiles)
          ..where((t) => t.userId.equals(userId)))
        .go();
  }
}
