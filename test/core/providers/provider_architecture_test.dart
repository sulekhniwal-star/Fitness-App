import 'package:fitkarma/core/config/app_config.dart';
import 'package:fitkarma/core/database/database_boundary.dart';
import 'package:fitkarma/core/providers/core_providers.dart';
import 'package:fitkarma/core/services/logging_service.dart';
import 'package:fitkarma/core/sync/sync_boundary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeLoggingService implements LoggingService {
  final List<String> logs = [];

  @override
  void log(
    LogLevel level,
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logs.add('[$level] $message');
  }

  @override
  void recordEvent(DiagnosticEvent event) {
    logs.add('[EVENT] ${event.name}');
  }

  @override
  void debug(String message, {Map<String, dynamic>? data}) =>
      log(LogLevel.debug, message, data: data);

  @override
  void info(String message, {Map<String, dynamic>? data}) =>
      log(LogLevel.info, message, data: data);

  @override
  void warning(String message, {Map<String, dynamic>? data, Object? error}) =>
      log(LogLevel.warning, message, data: data, error: error);

  @override
  void error(
    String message, {
    Map<String, dynamic>? data,
    Object? error,
    StackTrace? stackTrace,
  }) => log(
    LogLevel.error,
    message,
    data: data,
    error: error,
    stackTrace: stackTrace,
  );
}

class _FakeLocalDatabase implements LocalDatabase {
  bool initialized = false;

  @override
  bool get isInitialized => initialized;

  @override
  Future<void> initialize({required String encryptionKey}) async {
    initialized = true;
  }

  @override
  Future<void> close() async {
    initialized = false;
  }

  @override
  Future<void> wipeLocalData() async {}

  @override
  Future<T> runInTransaction<T>(Future<T> Function() action) => action();
}

class _FakeSyncEngine implements SyncEngine {
  @override
  SyncStatus get currentStatus => SyncStatus.idle;

  @override
  Stream<SyncStatus> get statusStream => Stream.value(SyncStatus.idle);

  @override
  Future<void> triggerSync() async {}

  @override
  Future<void> enqueueOperation({
    required String entityType,
    required String operationType,
    required Map<String, dynamic> payload,
    required String idempotencyKey,
  }) async {}
}

void main() {
  group('Riverpod Application Architecture & DI Tests', () {
    final testConfig = AppConfig.fromMap({
      'APP_ENV': 'staging',
      'SUPABASE_URL': 'https://staging.supabase.co',
      'SUPABASE_ANON_KEY': 'staging-anon-key',
    });

    test('providers can be overridden in ProviderContainer', () {
      final fakeLogger = _FakeLoggingService();
      final fakeDb = _FakeLocalDatabase();
      final fakeSync = _FakeSyncEngine();

      final container = ProviderContainer(
        overrides: [
          appConfigProvider.overrideWithValue(testConfig),
          loggingServiceProvider.overrideWithValue(fakeLogger),
          localDatabaseProvider.overrideWithValue(fakeDb),
          syncEngineProvider.overrideWithValue(fakeSync),
        ],
      );

      // Verify overridden instances resolve cleanly
      final config = container.read(appConfigProvider);
      expect(config.environment, AppEnvironment.staging);
      expect(config.supabaseUrl, 'https://staging.supabase.co');

      final logger = container.read(loggingServiceProvider);
      expect(logger, isA<_FakeLoggingService>());

      final db = container.read(localDatabaseProvider);
      expect(db, isA<_FakeLocalDatabase>());

      final sync = container.read(syncEngineProvider);
      expect(sync, isA<_FakeSyncEngine>());

      container.dispose();
    });

    test(
      'default appConfigProvider throws UnimplementedError if not overridden',
      () {
        final container = ProviderContainer();
        expect(
          () => container.read(appConfigProvider),
          throwsA(isA<UnimplementedError>()),
        );
        container.dispose();
      },
    );

    testWidgets('widget tree can read overridden providers safely', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appConfigProvider.overrideWithValue(testConfig)],
          child: MaterialApp(
            home: Consumer(
              builder: (context, ref, child) {
                final envName = ref.watch(appConfigProvider).environment.name;
                return Scaffold(body: Text('Active Env: $envName'));
              },
            ),
          ),
        ),
      );

      expect(find.text('Active Env: staging'), findsOneWidget);
    });

    test('AppProviderObserver intercepts updates and failures gracefully', () {
      final fakeLogger = _FakeLoggingService();
      final observer = AppProviderObserver(logger: fakeLogger);

      final container = ProviderContainer(
        observers: [observer],
        overrides: [appConfigProvider.overrideWithValue(testConfig)],
      );

      // Trigger read
      container.read(appConfigProvider);

      // Verify observer did not throw
      expect(
        fakeLogger.logs.any((l) => l.contains('appConfigProvider')),
        isTrue,
      );
      container.dispose();
    });
  });
}
