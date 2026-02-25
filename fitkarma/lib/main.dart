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
  await SentryFlutter.init(
    (options) {
      options.dsn = ''; // Using empty DSN to prevent crashes while inactive
      options.tracesSampleRate = 1.0;
    },
    appRunner: () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Hive
      await Hive.initFlutter();

      // Initialize Hive boxes
      await HiveService.initBoxes();

      // Initialize Analytics
      await analyticsService.init();

      // Read initial pocketbase auth config from secure storage
      const secureStorage = FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );
      final initialAuth = await secureStorage.read(key: 'pb_auth');

      runApp(
        ProviderScope(
          overrides: [
            initialPbAuthProvider.overrideWithValue(initialAuth),
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
