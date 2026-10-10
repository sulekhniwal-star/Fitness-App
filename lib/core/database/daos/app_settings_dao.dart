import 'package:drift/drift.dart';
import 'package:fitkarma/core/database/app_database.dart';

/// Data Access Object for key-value application settings.
class AppSettingsDao {
  final AppDatabase _db;

  AppSettingsDao(this._db);

  /// Retrieves setting string value for [key], or null if unset.
  Future<String?> getValue(String key) async {
    final row = await (_db.select(_db.localAppSettings)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  /// Sets or updates a setting key-value pair.
  Future<int> setValue(String key, String value) {
    return _db.into(_db.localAppSettings).insertOnConflictUpdate(
          LocalAppSettingsCompanion(
            key: Value(key),
            value: Value(value),
            updatedAt: Value(DateTime.now()),
          ),
        );
  }

  /// Removes a setting by [key].
  Future<int> remove(String key) {
    return (_db.delete(_db.localAppSettings)..where((t) => t.key.equals(key)))
        .go();
  }
}
