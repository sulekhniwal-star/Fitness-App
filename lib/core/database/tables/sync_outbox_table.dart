import 'package:drift/drift.dart';

/// Local Drift table definition for offline outbox synchronization (ADR-001).
class LocalSyncOutbox extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()(); // 'profile', 'wellness', etc.
  TextColumn get entityId => text()();
  TextColumn get operation => text()(); // 'create', 'update', 'delete'
  TextColumn get payloadJson => text()();
  TextColumn get idempotencyKey => text()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant('pending'))(); // pending, processing, failed
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
