import 'dart:async';

import 'package:fitkarma/app/fitkarma_app.dart';
import 'package:fitkarma/core/config/app_config.dart';
import 'package:fitkarma/core/providers/core_providers.dart';
import 'package:fitkarma/core/services/console_logging_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Pre-run initialization and app bootstrap runner with Riverpod architecture.
///
/// Wraps application execution in a [ProviderScope] with root configuration,
/// dependency overrides, and an [AppProviderObserver] error boundary.
Future<void> bootstrap(
  FutureOr<Widget> Function() builder, {
  List<Override> overrides = const [],
  AppConfig? initialConfig,
}) async {
  WidgetsFlutterBinding.ensureInitialized();

  final config = initialConfig ?? AppConfig.fromEnvironment();
  final logger = ConsoleLoggingService(
    isDebug: config.environment == AppEnvironment.development,
  );

  runApp(
    ProviderScope(
      observers: [AppProviderObserver(logger: logger)],
      overrides: [appConfigProvider.overrideWithValue(config), ...overrides],
      child: await builder(),
    ),
  );
}

/// Default production/development entry point executor.
Future<void> startFitKarmaApp() async {
  await bootstrap(() => const FitKarmaApp());
}
