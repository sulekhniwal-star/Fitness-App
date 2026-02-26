import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'l10n/app_localizations.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/router.dart';
import 'core/storage/hive_service.dart';
import 'core/network/pocketbase_client.dart';
import 'core/sync/notification_service.dart';
import 'core/monitoring/analytics_service.dart';
import 'data/providers/locale_provider.dart';

void main() async {
  // Ensure we bind framework prior to attempting directory accesses for Hive.
  WidgetsFlutterBinding.ensureInitialized();

  await SentryFlutter.init(
    (options) {
      // Typically inject via String.fromEnvironment or dotenv in production
      options.dsn = '';
      options.tracesSampleRate = 1.0;
    },
    appRunner: () async {
      // Initialize Hive Framework
      await Hive.initFlutter();

      // Initialize Application local schemas
      await HiveService.initBoxes();

      // Initialize Mixpanel / core tracking
      await analyticsService.init();

      // Extract Auth status
      const secureStorage = FlutterSecureStorage();
      final pbAuthStr = await secureStorage.read(key: 'pb_auth');

      runApp(
        ProviderScope(
          overrides: [
            initialPbAuthProvider.overrideWithValue(pbAuthStr),
          ],
          child: const FitKarmaApp(),
        ),
      );
    },
  );
}

class FitKarmaApp extends ConsumerWidget {
  const FitKarmaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    // Initialize notification service
    ref.watch(notificationServiceProvider);

    return MaterialApp.router(
      title: 'FitKarma',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: ref.watch(localeProvider),
    );
  }
}
