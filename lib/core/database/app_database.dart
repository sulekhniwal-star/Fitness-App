import 'package:drift/drift.dart';
import 'package:fitkarma/core/database/tables/app_settings_table.dart';
import 'package:fitkarma/core/database/tables/profiles_table.dart';
import 'package:fitkarma/core/database/tables/sync_outbox_table.dart';
import 'package:fitkarma/core/database/tables/wellness_profiles_table.dart';

part 'app_database.g.dart';

/// Central Drift database for FitKarma local persistence with SQLCipher encryption.
@DriftDatabase(tables: [
  LocalProfiles,
  LocalWellnessProfiles,
  LocalSyncOutbox,
  LocalAppSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Version migration framework: handles step-by-step upgrades
          for (var target = from + 1; target <= to; target++) {
            await _applyMigrationStep(m, target);
          }
        },
        beforeOpen: (OpeningDetails details) async {
          await customStatement('PRAGMA foreign_keys = ON;');
        },
      );

  /// Performs schema migration for a specific version step.
  Future<void> _applyMigrationStep(Migrator m, int targetVersion) async {
    switch (targetVersion) {
      case 1:
        // Initial baseline schema
        await m.createAll();
        break;
      default:
        // Reserved for future migrations
        break;
    }
  }

  /// Atomically wipes all user data across all tables within a single transaction.
  Future<void> wipeAllData() async {
    await transaction(() async {
      await delete(localProfiles).go();
      await delete(localWellnessProfiles).go();
      await delete(localSyncOutbox).go();
      await delete(localAppSettings).go();
    });
  }
}
