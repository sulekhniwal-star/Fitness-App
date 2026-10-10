import 'package:drift/drift.dart';

/// Local Drift table definition for application settings and offline flags.
class LocalAppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}
