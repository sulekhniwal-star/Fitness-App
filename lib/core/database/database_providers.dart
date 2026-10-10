import 'package:fitkarma/core/database/app_database.dart';
import 'package:fitkarma/core/database/daos/app_settings_dao.dart';
import 'package:fitkarma/core/database/daos/profile_dao.dart';
import 'package:fitkarma/core/database/daos/sync_outbox_dao.dart';
import 'package:fitkarma/core/database/daos/wellness_profile_dao.dart';
import 'package:fitkarma/core/database/drift_local_database.dart';
import 'package:fitkarma/core/providers/core_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for the concrete [DriftLocalDatabase] implementation.
final driftLocalDatabaseProvider = Provider<DriftLocalDatabase>((ref) {
  final localDb = ref.watch(localDatabaseProvider);
  if (localDb is DriftLocalDatabase) {
    return localDb;
  }
  throw StateError(
    'The provided LocalDatabase is not an instance of DriftLocalDatabase.',
  );
}, name: 'driftLocalDatabaseProvider');

/// Provider for the underlying Drift [AppDatabase].
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return ref.watch(driftLocalDatabaseProvider).database;
}, name: 'appDatabaseProvider');

/// Provider for the [ProfileDao].
final profileDaoProvider = Provider<ProfileDao>((ref) {
  return ref.watch(driftLocalDatabaseProvider).profileDao;
}, name: 'profileDaoProvider');

/// Provider for the [WellnessProfileDao].
final wellnessProfileDaoProvider = Provider<WellnessProfileDao>((ref) {
  return ref.watch(driftLocalDatabaseProvider).wellnessProfileDao;
}, name: 'wellnessProfileDaoProvider');

/// Provider for the [SyncOutboxDao].
final syncOutboxDaoProvider = Provider<SyncOutboxDao>((ref) {
  return ref.watch(driftLocalDatabaseProvider).syncOutboxDao;
}, name: 'syncOutboxDaoProvider');

/// Provider for the [AppSettingsDao].
final appSettingsDaoProvider = Provider<AppSettingsDao>((ref) {
  return ref.watch(driftLocalDatabaseProvider).appSettingsDao;
}, name: 'appSettingsDaoProvider');
