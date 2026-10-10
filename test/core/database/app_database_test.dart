import 'dart:io';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:fitkarma/core/database/app_database.dart';
import 'package:fitkarma/core/database/drift_local_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppDatabase & DriftLocalDatabase Foundation Tests', () {
    late DriftLocalDatabase localDb;
    late AppDatabase db;

    setUp(() async {
      localDb = DriftLocalDatabase.inMemory();
      await localDb.initialize(encryptionKey: 'test_secret_passphrase_123');
      db = localDb.database;
    });

    tearDown(() async {
      await localDb.close();
    });

    test('initializes database with schemaVersion 1 and foreign keys enabled',
        () async {
      expect(localDb.isInitialized, isTrue);
      expect(db.schemaVersion, equals(1));

      // Verify PRAGMA foreign_keys is ON
      final result = await db.customSelect('PRAGMA foreign_keys;').getSingle();
      expect(result.data['foreign_keys'], equals(1));
    });

    test('profileDao performs insert, query, update, and stream watch correctly',
        () async {
      final now = DateTime.now();
      final profileDao = localDb.profileDao;

      // 1. Insert initial profile
      await profileDao.upsertProfile(
        LocalProfilesCompanion.insert(
          id: 'prof_local_1',
          userId: 'user_local_1',
          displayName: 'Aarav Sharma',
          age: const Value(29),
          biologicalSex: const Value('male'),
          heightCm: const Value(178.5),
          weightKg: const Value(74.0),
          goalsJson: const Value('["hypertrophy", "strength"]'),
          dietaryIdentity: const Value('vegetarian'),
          createdAt: now,
          updatedAt: now,
        ),
      );

      // 2. Query profile
      final retrieved = await profileDao.getProfileByUserId('user_local_1');
      expect(retrieved, isNotNull);
      expect(retrieved!.displayName, equals('Aarav Sharma'));
      expect(retrieved.age, equals(29));
      expect(retrieved.heightCm, equals(178.5));
      expect(retrieved.goalsJson, contains('hypertrophy'));

      // 3. Update profile
      await profileDao.upsertProfile(
        LocalProfilesCompanion.insert(
          id: 'prof_local_1',
          userId: 'user_local_1',
          displayName: 'Aarav Sharma Updated',
          age: const Value(30),
          createdAt: now,
          updatedAt: DateTime.now(),
        ),
      );

      final updated = await profileDao.getProfileByUserId('user_local_1');
      expect(updated!.displayName, equals('Aarav Sharma Updated'));
      expect(updated.age, equals(30));

      // 4. Delete profile
      await profileDao.deleteProfileByUserId('user_local_1');
      final afterDelete = await profileDao.getProfileByUserId('user_local_1');
      expect(afterDelete, isNull);
    });

    test('wellnessProfileDao handles Ayurveda profile persistence and queries',
        () async {
      final now = DateTime.now();
      final wellnessDao = localDb.wellnessProfileDao;

      await wellnessDao.upsertWellnessProfile(
        LocalWellnessProfilesCompanion.insert(
          id: 'wellness_local_1',
          userId: 'user_wellness_1',
          dominantDosha: 'Pitta',
          secondaryDosha: const Value('Vata'),
          isTridoshic: const Value(false),
          vataPercentage: 35.0,
          pittaPercentage: 45.0,
          kaphaPercentage: 20.0,
          answersJson: const Value('{"q1": "warm"}'),
          recommendationsJson: const Value('["cooling foods", "hydration"]'),
          updatedAt: now,
        ),
      );

      final retrieved =
          await wellnessDao.getWellnessProfileByUserId('user_wellness_1');
      expect(retrieved, isNotNull);
      expect(retrieved!.dominantDosha, equals('Pitta'));
      expect(retrieved.secondaryDosha, equals('Vata'));
      expect(retrieved.pittaPercentage, equals(45.0));
      expect(retrieved.recommendationsJson, contains('cooling foods'));
    });

    test('syncOutboxDao manages offline outbox lifecycle and retries', () async {
      final now = DateTime.now();
      final outboxDao = localDb.syncOutboxDao;

      // 1. Enqueue outbox item
      await outboxDao.enqueue(
        LocalSyncOutboxCompanion.insert(
          id: 'outbox_1',
          entityType: 'profile',
          entityId: 'prof_local_1',
          operation: 'upsert',
          payloadJson: '{"displayName": "Priya"}',
          idempotencyKey: 'idemp_key_1',
          createdAt: now,
          updatedAt: now,
        ),
      );

      // 2. Fetch pending entries
      final pending = await outboxDao.getPendingEntries();
      expect(pending.length, equals(1));
      expect(pending.first.entityType, equals('profile'));
      expect(pending.first.status, equals('pending'));

      // 3. Mark processing
      await outboxDao.markProcessing('outbox_1');
      final processingList = await outboxDao.getPendingEntries();
      expect(processingList, isEmpty);

      // 4. Mark failed with error
      await outboxDao.markFailed('outbox_1', 'HTTP 503 Service Unavailable',
          currentRetryCount: 0);
      final rawRow = await (db.select(db.localSyncOutbox)
            ..where((t) => t.id.equals('outbox_1')))
          .getSingle();
      expect(rawRow.status, equals('failed'));
      expect(rawRow.retryCount, equals(1));
      expect(rawRow.lastError, contains('503'));

      // 5. Mark completed removes row
      await outboxDao.markCompleted('outbox_1');
      final afterComplete = await (db.select(db.localSyncOutbox)
            ..where((t) => t.id.equals('outbox_1')))
          .getSingleOrNull();
      expect(afterComplete, isNull);
    });

    test('appSettingsDao stores and retrieves key-value configuration',
        () async {
      final settingsDao = localDb.appSettingsDao;

      await settingsDao.setValue('theme_mode', 'dark');
      await settingsDao.setValue('onboarding_completed', 'true');

      expect(await settingsDao.getValue('theme_mode'), equals('dark'));
      expect(
          await settingsDao.getValue('onboarding_completed'), equals('true'));
      expect(await settingsDao.getValue('unknown_key'), isNull);

      await settingsDao.remove('theme_mode');
      expect(await settingsDao.getValue('theme_mode'), isNull);
    });

    test('runInTransaction commits atomically on success', () async {
      final now = DateTime.now();

      await localDb.runInTransaction(() async {
        await localDb.profileDao.upsertProfile(
          LocalProfilesCompanion.insert(
            id: 'tx_prof_1',
            userId: 'tx_user_1',
            displayName: 'Tx User',
            createdAt: now,
            updatedAt: now,
          ),
        );
        await localDb.appSettingsDao.setValue('tx_status', 'committed');
      });

      expect(await localDb.profileDao.getProfileByUserId('tx_user_1'), isNotNull);
      expect(await localDb.appSettingsDao.getValue('tx_status'),
          equals('committed'));
    });

    test('runInTransaction rolls back all modifications on unhandled exception',
        () async {
      final now = DateTime.now();

      expect(
        () => localDb.runInTransaction(() async {
          await localDb.profileDao.upsertProfile(
            LocalProfilesCompanion.insert(
              id: 'tx_prof_rollback',
              userId: 'tx_user_rollback',
              displayName: 'Rollback User',
              createdAt: now,
              updatedAt: now,
            ),
          );
          throw Exception('Simulated database write failure');
        }),
        throwsA(isA<Exception>()),
      );

      // Verify no changes were committed to database
      final profile =
          await localDb.profileDao.getProfileByUserId('tx_user_rollback');
      expect(profile, isNull);
    });

    test('wipeLocalData atomically empties all tables across the database',
        () async {
      final now = DateTime.now();

      // Seed all 4 tables
      await localDb.profileDao.upsertProfile(
        LocalProfilesCompanion.insert(
          id: 'wipe_prof',
          userId: 'wipe_user',
          displayName: 'Wipe User',
          createdAt: now,
          updatedAt: now,
        ),
      );

      await localDb.wellnessProfileDao.upsertWellnessProfile(
        LocalWellnessProfilesCompanion.insert(
          id: 'wipe_wellness',
          userId: 'wipe_user',
          dominantDosha: 'Vata',
          vataPercentage: 50.0,
          pittaPercentage: 30.0,
          kaphaPercentage: 20.0,
          updatedAt: now,
        ),
      );

      await localDb.syncOutboxDao.enqueue(
        LocalSyncOutboxCompanion.insert(
          id: 'wipe_outbox',
          entityType: 'profile',
          entityId: 'wipe_prof',
          operation: 'insert',
          payloadJson: '{}',
          idempotencyKey: 'idemp_wipe',
          createdAt: now,
          updatedAt: now,
        ),
      );

      await localDb.appSettingsDao.setValue('wipe_key', 'wipe_value');

      // Assert data is present before wipe
      expect((await db.select(db.localProfiles).get()).length, equals(1));
      expect((await db.select(db.localWellnessProfiles).get()).length, equals(1));
      expect((await db.select(db.localSyncOutbox).get()).length, equals(1));
      expect((await db.select(db.localAppSettings).get()).length, equals(1));

      // Execute wipe
      await localDb.wipeLocalData();

      // Assert all tables are completely empty
      expect((await db.select(db.localProfiles).get()), isEmpty);
      expect((await db.select(db.localWellnessProfiles).get()), isEmpty);
      expect((await db.select(db.localSyncOutbox).get()), isEmpty);
      expect((await db.select(db.localAppSettings).get()), isEmpty);
    });
  });

  group('SQLCipher File-backed Encrypted Store Tests', () {
    test('creates encrypted database file, writes data, and reopens successfully',
        () async {
      final tempDir = await Directory.systemTemp.createTemp('fitkarma_db_test_');

      try {
        final dbFile =
            DriftLocalDatabase(overrideDirectory: tempDir, databaseName: 'enc.db');
        await dbFile.initialize(encryptionKey: 'super_secret_master_key_42');

        await dbFile.appSettingsDao.setValue('cipher_check', 'verified_encrypted');

        await dbFile.close();

        // Reopen with the same key
        final reopenedDb =
            DriftLocalDatabase(overrideDirectory: tempDir, databaseName: 'enc.db');
        await reopenedDb.initialize(encryptionKey: 'super_secret_master_key_42');

        final value = await reopenedDb.appSettingsDao.getValue('cipher_check');
        expect(value, equals('verified_encrypted'));

        await reopenedDb.close();
      } finally {
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
        }
      }
    });
  });
}
