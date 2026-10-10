import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Utility functions for opening Drift database connections with SQLCipher support.
class DatabaseConnectionFactory {
  const DatabaseConnectionFactory._();

  /// Default database filename for FitKarma's encrypted store.
  static const String defaultDatabaseName = 'fitkarma_encrypted.db';

  /// Opens a file-backed encrypted database using SQLCipher.
  ///
  /// Escapes the [encryptionKey] to prevent SQL injection during PRAGMA key execution.
  static QueryExecutor createEncryptedConnection({
    String databaseName = defaultDatabaseName,
    required String encryptionKey,
    Directory? overrideDirectory,
  }) {
    return LazyDatabase(() async {
      final Directory targetDir;
      if (overrideDirectory != null) {
        targetDir = overrideDirectory;
      } else {
        targetDir = await getApplicationDocumentsDirectory();
      }

      final file = File(p.join(targetDir.path, databaseName));
      final escapedKey = encryptionKey.replaceAll("'", "''");

      return NativeDatabase.createInBackground(
        file,
        setup: (rawDb) {
          if (escapedKey.isNotEmpty) {
            rawDb.execute("PRAGMA key = '$escapedKey';");
            rawDb.execute('PRAGMA cipher_memory_security = ON;');
          }
          rawDb.execute('PRAGMA foreign_keys = ON;');
        },
      );
    });
  }

  /// Opens an in-memory database connection for fast, isolated testing.
  static QueryExecutor createInMemoryConnection({
    String? encryptionKey,
    bool logStatements = false,
  }) {
    return NativeDatabase.memory(
      logStatements: logStatements,
      setup: (rawDb) {
        if (encryptionKey != null && encryptionKey.isNotEmpty) {
          final escapedKey = encryptionKey.replaceAll("'", "''");
          rawDb.execute("PRAGMA key = '$escapedKey';");
        }
        rawDb.execute('PRAGMA foreign_keys = ON;');
      },
    );
  }
}
