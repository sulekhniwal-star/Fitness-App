import 'package:fitkarma/core/routing/app_routes.dart';
import 'package:fitkarma/core/routing/auth_nav_state.dart';
import 'package:fitkarma/core/routing/placeholder_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Notifier bridging Riverpod auth state with GoRouter's Listenable refresh.
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen<AuthNavStatus>(
      authNavStatusProvider,
      (previous, next) => notifyListeners(),
    );
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final authStatus = _ref.read(authNavStatusProvider);
    final location = state.uri.path;
    final isPublic = AppRoutes.isPublic(location);

    if (authStatus == AuthNavStatus.unauthenticated) {
      if (!isPublic) {
        return AppRoutes.onboarding;
      }
    } else if (authStatus == AuthNavStatus.authenticated) {
      if (isPublic || location == AppRoutes.root) {
        return AppRoutes.dashboard;
      }
    }

    return null;
  }
}

/// Provider for the application router notifier.
final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

/// Riverpod provider for the central [GoRouter] instance.
final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: AppRoutes.onboarding,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    routes: [
      GoRoute(
        path: AppRoutes.root,
        builder: (context, state) => const AreaPlaceholderScreen(
          title: 'FitKarma',
          subtitle: 'Welcome to FitKarma',
          semanticKey: Key('screen_root'),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const AreaPlaceholderScreen(
          title: 'Onboarding',
          subtitle: 'FitKarma Personalization & Consent',
          semanticKey: Key('screen_onboarding'),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const AreaPlaceholderScreen(
          title: 'Login',
          subtitle: 'Sign in to FitKarma',
          semanticKey: Key('screen_login'),
        ),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) => const AreaPlaceholderScreen(
          title: 'OTP Verification',
          subtitle: 'Enter verification code',
          semanticKey: Key('screen_otp'),
        ),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const AreaPlaceholderScreen(
          title: 'Dashboard',
          subtitle: 'Daily Intelligence Package (DIP)',
          semanticKey: Key('screen_dashboard'),
        ),
      ),
      GoRoute(
        path: AppRoutes.nutrition,
        builder: (context, state) => const AreaPlaceholderScreen(
          title: 'Nutrition',
          subtitle: 'Indian Nutrition Engine',
          semanticKey: Key('screen_nutrition'),
        ),
        routes: [
          GoRoute(
            path: 'log',
            builder: (context, state) => const AreaPlaceholderScreen(
              title: 'Log Meal',
              subtitle: 'Household portions, raw/cooked, Tadka',
              semanticKey: Key('screen_nutrition_log'),
            ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.workouts,
        builder: (context, state) => const AreaPlaceholderScreen(
          title: 'Workouts',
          subtitle: 'Workout Tracking & Exercises',
          semanticKey: Key('screen_workouts'),
        ),
      ),
      GoRoute(
        path: AppRoutes.sleep,
        builder: (context, state) => const AreaPlaceholderScreen(
          title: 'Sleep',
          subtitle: 'Sleep Stages & Circadian Rhythm',
          semanticKey: Key('screen_sleep'),
        ),
      ),
      GoRoute(
        path: AppRoutes.recovery,
        builder: (context, state) => const AreaPlaceholderScreen(
          title: 'Recovery',
          subtitle: 'Readiness & HRV Telemetry',
          semanticKey: Key('screen_recovery'),
        ),
      ),
      GoRoute(
        path: AppRoutes.aiMealAnalyze,
        builder: (context, state) => const AreaPlaceholderScreen(
          title: 'AI Meal Analysis',
          subtitle: 'Text, Voice & Vision Extraction',
          semanticKey: Key('screen_ai'),
        ),
      ),
      GoRoute(
        path: AppRoutes.family,
        builder: (context, state) => const AreaPlaceholderScreen(
          title: 'Family Care',
          subtitle: 'Consented Household Health Governance',
          semanticKey: Key('screen_family'),
        ),
      ),
      GoRoute(
        path: AppRoutes.subscriptions,
        builder: (context, state) => const AreaPlaceholderScreen(
          title: 'Subscriptions',
          subtitle: 'Karma Pro & UPI AutoPay',
          semanticKey: Key('screen_subscriptions'),
        ),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const AreaPlaceholderScreen(
          title: 'Settings',
          subtitle: 'Preferences & Notifications',
          semanticKey: Key('screen_settings'),
        ),
      ),
      GoRoute(
        path: AppRoutes.dataVault,
        builder: (context, state) => const AreaPlaceholderScreen(
          title: 'Data Vault',
          subtitle: 'DPDP Privacy, Export & Erasure',
          semanticKey: Key('screen_data_vault'),
        ),
      ),
    ],
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.error}'))),
  );
});
