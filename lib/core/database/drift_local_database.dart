import 'dart:io';
import 'package:fitkarma/core/database/app_database.dart';
import 'package:fitkarma/core/database/connection/database_connection.dart';
import 'package:fitkarma/core/database/daos/app_settings_dao.dart';
import 'package:fitkarma/core/database/daos/profile_dao.dart';
import 'package:fitkarma/core/database/daos/sync_outbox_dao.dart';
import 'package:fitkarma/core/database/daos/wellness_profile_dao.dart';
import 'package:fitkarma/core/database/database_boundary.dart';

/// Concrete implementation of [LocalDatabase] backed by Drift and SQLCipher.
class DriftLocalDatabase implements LocalDatabase {
  final String _dbName;
  final Directory? _dbDir;
  final bool _isInMemory;

  AppDatabase? _database;

  ProfileDao? _profileDao;
  WellnessProfileDao? _wellnessProfileDao;
  SyncOutboxDao? _syncOutboxDao;
  AppSettingsDao? _appSettingsDao;

  /// Default file-backed database constructor.
  DriftLocalDatabase({
    String databaseName = DatabaseConnectionFactory.defaultDatabaseName,
    Directory? overrideDirectory,
  })  : _dbName = databaseName,
        _dbDir = overrideDirectory,
        _isInMemory = false;

  /// In-memory database constructor for testing.
  DriftLocalDatabase.inMemory({AppDatabase? preconfiguredDatabase})
      : _dbName = ':memory:',
        _dbDir = null,
        _isInMemory = true,
        _database = preconfiguredDatabase {
    if (preconfiguredDatabase != null) {
      _initDaos(preconfiguredDatabase);
    }
  }

  @override
  bool get isInitialized => _database != null;

  /// Underlying Drift [AppDatabase] instance.
  /// Throws [StateError] if [initialize] has not been called.
  AppDatabase get database {
    final db = _database;
    if (db == null) {
      throw StateError(
        'DriftLocalDatabase has not been initialized. Call initialize() before accessing the database.',
      );
    }
    return db;
  }

  /// Profile DAO for accessing local profiles table.
  ProfileDao get profileDao {
    _ensureInitialized();
    return _profileDao!;
  }

  /// Wellness Profile DAO for accessing local Ayurveda profiles table.
  WellnessProfileDao get wellnessProfileDao {
    _ensureInitialized();
    return _wellnessProfileDao!;
  }

  /// Sync Outbox DAO for offline transaction queuing (ADR-001).
  SyncOutboxDao get syncOutboxDao {
    _ensureInitialized();
    return _syncOutboxDao!;
  }

  /// App Settings DAO for key-value configuration.
  AppSettingsDao get appSettingsDao {
    _ensureInitialized();
    return _appSettingsDao!;
  }

  void _ensureInitialized() {
    if (_database == null) {
      throw StateError(
        'DriftLocalDatabase has not been initialized. Call initialize() first.',
      );
    }
  }

  void _initDaos(AppDatabase db) {
    _profileDao = ProfileDao(db);
    _wellnessProfileDao = WellnessProfileDao(db);
    _syncOutboxDao = SyncOutboxDao(db);
    _appSettingsDao = AppSettingsDao(db);
  }

  @override
  Future<void> initialize({required String encryptionKey}) async {
    if (_database != null) {
      return;
    }

    final AppDatabase db;
    if (_isInMemory) {
      final executor = DatabaseConnectionFactory.createInMemoryConnection(
        encryptionKey: encryptionKey,
      );
      db = AppDatabase(executor);
    } else {
      final executor = DatabaseConnectionFactory.createEncryptedConnection(
        databaseName: _dbName,
        encryptionKey: encryptionKey,
        overrideDirectory: _dbDir,
      );
      db = AppDatabase(executor);
    }

    // Force open and verify encryption / migrations
    await db.customSelect('SELECT 1;').get();

    _database = db;
    _initDaos(db);
  }

  @override
  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
      _profileDao = null;
      _wellnessProfileDao = null;
      _syncOutboxDao = null;
      _appSettingsDao = null;
    }
  }

  @override
  Future<void> wipeLocalData() async {
    final db = database;
    await db.wipeAllData();
  }

  @override
  Future<T> runInTransaction<T>(Future<T> Function() action) {
    final db = database;
    return db.transaction(action);
  }
}
