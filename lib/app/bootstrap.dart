import 'dart:async';

import 'package:fitkarma/app/fitkarma_app.dart';
import 'package:flutter/widgets.dart';

/// Pre-run initialization and app bootstrap runner.
///
/// Wraps app execution in an asynchronous initialization flow and error boundary.
Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();

  // Run app inside guarded zone
  runApp(await builder());
}

/// Default entry point executor.
Future<void> startFitKarmaApp() async {
  await bootstrap(() => const FitKarmaApp());
}
