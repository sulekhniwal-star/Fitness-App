import 'package:fitkarma/core/config/app_config.dart';
import 'package:fitkarma/core/database/database_boundary.dart';
import 'package:fitkarma/core/services/console_logging_service.dart';
import 'package:fitkarma/core/services/logging_service.dart';
import 'package:fitkarma/core/sync/sync_boundary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for application environment configuration.
///
/// Throws [UnimplementedError] if not overridden in [ProviderScope] during bootstrap.
final appConfigProvider = Provider<AppConfig>((ref) {
  throw UnimplementedError(
    'appConfigProvider must be overridden in ProviderScope during app initialization.',
  );
}, name: 'appConfigProvider');

/// Provider for the centralized logging service.
final loggingServiceProvider = Provider<LoggingService>((ref) {
  final isDebug =
      ref.watch(appConfigProvider).environment == AppEnvironment.development;
  return ConsoleLoggingService(isDebug: isDebug);
}, name: 'loggingServiceProvider');

/// Boundary provider for the local encrypted database (Drift + SQLCipher).
///
/// Implemented by the data persistence layer in Phase 3 (Task 020).
final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  throw UnimplementedError(
    'localDatabaseProvider must be overridden with concrete LocalDatabase implementation.',
  );
}, name: 'localDatabaseProvider');

/// Boundary provider for the offline synchronization engine.
///
/// Implemented by the sync engine in Phase 3 (Tasks 021-023).
final syncEngineProvider = Provider<SyncEngine>((ref) {
  throw UnimplementedError(
    'syncEngineProvider must be overridden with concrete SyncEngine implementation.',
  );
}, name: 'syncEngineProvider');

/// Riverpod lifecycle observer for application observability and error monitoring.
class AppProviderObserver extends ProviderObserver {
  final LoggingService? logger;

  const AppProviderObserver({this.logger});

  @override
  void didAddProvider(
    ProviderBase<Object?> provider,
    Object? value,
    ProviderContainer container,
  ) {
    logger?.debug(
      'Provider initialized: ${provider.name ?? provider.runtimeType}',
      data: {'provider': provider.name ?? provider.runtimeType.toString()},
    );
  }

  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    logger?.error(
      'Provider failure: ${provider.name ?? provider.runtimeType}',
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void didUpdateProvider(
    ProviderBase<Object?> provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    logger?.debug(
      'Provider update: ${provider.name ?? provider.runtimeType}',
      data: {'provider': provider.name ?? provider.runtimeType.toString()},
    );
  }
}
