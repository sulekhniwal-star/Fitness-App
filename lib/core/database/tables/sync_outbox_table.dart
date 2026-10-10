import 'package:drift/drift.dart';

/// Local Drift table definition for offline outbox synchronization (ADR-001).
class LocalSyncOutbox extends Table {
  TextColumn get id => text()();
  TextColumn get entityType => text()(); // 'profile', 'wellness', etc.
  TextColumn get entityId => text()();
  TextColumn get operation => text()(); // 'create', 'update', 'delete', 'upsert'
  TextColumn get payloadJson => text()();
  TextColumn get idempotencyKey => text().unique()();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  IntColumn get maxRetries => integer().withDefault(const Constant(5))();
  TextColumn get lastError => text().nullable()();
  TextColumn get lastErrorCode => text().nullable()();
  TextColumn get status =>
      text().withDefault(const Constant('pending'))(); // pending, processing, completed, failed, permanentlyFailed
  TextColumn get metadataJson => text().nullable()(); // dependency / reference metadata
  DateTimeColumn get nextRetryAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
