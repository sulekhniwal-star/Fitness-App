import 'package:fitkarma/core/constants/app_constants.dart';
import 'package:fitkarma/core/routing/app_router.dart';
import 'package:fitkarma/shared/presentation/theme/app_theme.dart';
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
      theme: FitKarmaTheme.darkTheme,
    );
  }
}
