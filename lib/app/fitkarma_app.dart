import 'package:fitkarma/core/constants/app_constants.dart';
import 'package:fitkarma/core/routing/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Root widget for the FitKarma application configured with Riverpod and GoRouter.
class FitKarmaApp extends ConsumerWidget {
  const FitKarmaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0D0F12),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00E599),
          surface: Color(0xFF161A22),
        ),
        useMaterial3: true,
      ),
    );
  }
}
