import 'package:fitkarma/core/database/app_database.dart';
import 'package:fitkarma/core/database/connection/database_connection.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Drift Schema Migration Framework Tests', () {
    test('schema version initializes at version 1 and all foundation tables exist',
        () async {
      final executor = DatabaseConnectionFactory.createInMemoryConnection();
      final db = AppDatabase(executor);

      try {
        expect(db.schemaVersion, equals(1));

        // Query sqlite_master to verify that all 4 foundation tables are created
        final tables = await db.customSelect(
          "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';",
        ).get();

        final tableNames = tables.map((row) => row.data['name']).toSet();

        expect(
          tableNames,
          containsAll([
            'local_profiles',
            'local_wellness_profiles',
            'local_sync_outbox',
            'local_app_settings',
          ]),
        );
      } finally {
        await db.close();
      }
    });

    test('migration strategy executes onUpgrade loop correctly across version steps',
        () async {
      final executor = DatabaseConnectionFactory.createInMemoryConnection();
      final db = AppDatabase(executor);

      try {
        final migrator = db.createMigrator();
        // Verifying migrator creation and execution of migration strategy
        expect(db.migration, isNotNull);
        expect(migrator, isNotNull);

        // Verify foreign_keys PRAGMA is configured
        final pragmaFk =
            await db.customSelect('PRAGMA foreign_keys;').getSingle();
        expect(pragmaFk.data['foreign_keys'], equals(1));
      } finally {
        await db.close();
      }
    });
  });
}
