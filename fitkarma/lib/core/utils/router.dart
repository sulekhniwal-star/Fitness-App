import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/auth_provider.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/register_screen.dart';
import '../../presentation/screens/auth/phone_otp_screen.dart';
import '../../presentation/screens/home/dashboard_tab.dart';
import '../../presentation/screens/home/onboarding_screen.dart';
import '../../presentation/screens/home/splash_screen.dart';
import '../../presentation/screens/home/community_tab.dart';
import '../../presentation/screens/home/activity_tracking_screen.dart';
import '../../presentation/screens/food/food_logging_screen.dart';
import '../../presentation/screens/workouts/workout_list_screen.dart';
import '../../presentation/screens/profile/profile_screen.dart';
import '../../presentation/screens/profile/leaderboard_screen.dart';
import '../../shared/widgets/app_shell.dart';
import '../monitoring/analytics_service.dart';

class AnalyticsObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings.name != null) {
      analyticsService.trackEvent('page_view', properties: {
        'page_name': route.settings.name,
      });
    }
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    observers: [AnalyticsObserver()],
    redirect: (context, state) {
      final isLoggedIn = authState.status == AuthStatus.authenticated;
      final isOnAuthPage = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/phone-otp';
      final isOnboarding = state.matchedLocation == '/onboarding';
      final isOnSplash = state.matchedLocation == '/';

      // If not logged in and not on auth/onboarding/splash pages, redirect to login
      if (!isLoggedIn && !isOnAuthPage && !isOnboarding && !isOnSplash) {
        return '/login';
      }

      // If logged in and on auth page, redirect to home
      if (isLoggedIn && isOnAuthPage) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/phone-otp',
        name: 'phone-otp',
        builder: (context, state) {
          final phone = state.extra as String? ?? '';
          return PhoneOtpScreen(phoneNumber: phone);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const DashboardTab(),
                routes: [
                  GoRoute(
                    path: 'activity-tracking',
                    name: 'activity-tracking',
                    builder: (context, state) => const ActivityTrackingScreen(),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/food',
                name: 'food',
                builder: (context, state) => const FoodLoggingScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/workouts',
                name: 'workouts',
                builder: (context, state) => const WorkoutListScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/social',
                name: 'social',
                builder: (context, state) => const CommunityTab(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: 'leaderboard',
                    name: 'leaderboard',
                    builder: (context, state) => const LeaderboardScreen(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(state.error.toString()),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/home'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
