import 'package:drift/drift.dart';

/// Local Drift table definition for Ayurveda/Dosha WellnessProfile.
class LocalWellnessProfiles extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text().unique()();
  TextColumn get dominantDosha => text()();
  TextColumn get secondaryDosha => text().nullable()();
  BoolColumn get isTridoshic =>
      boolean().withDefault(const Constant(false))();
  RealColumn get vataPercentage => real()();
  RealColumn get pittaPercentage => real()();
  RealColumn get kaphaPercentage => real()();
  TextColumn get answersJson => text().withDefault(const Constant('{}'))();
  TextColumn get recommendationsJson =>
      text().withDefault(const Constant('[]'))();
  BoolColumn get isSkipped => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(true))();

  @override
  Set<Column> get primaryKey => {id};
}
