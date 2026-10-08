import 'package:fitkarma/core/config/app_config.dart';
import 'package:fitkarma/core/config/remote_config_service.dart';
import 'package:fitkarma/core/database/database_boundary.dart';
import 'package:fitkarma/core/observability/crash_reporting_service.dart';
import 'package:fitkarma/core/observability/logging_service.dart';
import 'package:fitkarma/core/observability/redaction.dart';
import 'package:fitkarma/core/services/console_logging_service.dart';
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

/// Provider for the PII and health data redactor.
final dataRedactorProvider = Provider<DataRedactor>((ref) {
  return const DataRedactor();
}, name: 'dataRedactorProvider');

/// Provider for remote configuration and feature flags.
final remoteConfigServiceProvider = Provider<RemoteConfigService>((ref) {
  return RemoteConfigService();
}, name: 'remoteConfigServiceProvider');

/// Provider for crash reporting service (defaults to Sentry boundary in production, Noop in tests).
final crashReportingServiceProvider = Provider<CrashReportingService>((ref) {
  final redactor = ref.watch(dataRedactorProvider);
  return SentryCrashReportingBoundary(redactor: redactor);
}, name: 'crashReportingServiceProvider');

/// Provider for the centralized logging service.
final loggingServiceProvider = Provider<LoggingService>((ref) {
  final isDebug =
      ref.watch(appConfigProvider).environment == AppEnvironment.development;
  final redactor = ref.watch(dataRedactorProvider);
  return ConsoleLoggingService(isDebug: isDebug, redactor: redactor);
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
