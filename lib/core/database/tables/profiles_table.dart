import 'package:drift/drift.dart';

/// Local Drift table definition for UserProfile conforming to Brain/data_model.md.
class LocalProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().unique()();
  TextColumn get displayName => text()();
  IntColumn get age => integer().nullable()();
  TextColumn get biologicalSex => text().nullable()();
  RealColumn get heightCm => real().nullable()();
  RealColumn get weightKg => real().nullable()();
  TextColumn get goalsJson => text().withDefault(const Constant('[]'))();
  TextColumn get activityLevel => text().nullable()();
  TextColumn get dietaryIdentity => text().nullable()();
  IntColumn get mealFrequency => integer().nullable()();
  TextColumn get fastingProtocol => text().nullable()();
  TextColumn get allergiesJson => text().withDefault(const Constant('[]'))();
  IntColumn get targetCalories => integer().nullable()();
  TextColumn get locale => text().withDefault(const Constant('en'))();
  BoolColumn get isConsentGiven =>
      boolean().withDefault(const Constant(false))();
  TextColumn get metadataJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
