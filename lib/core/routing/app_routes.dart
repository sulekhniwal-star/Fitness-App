/// Centralized route paths and names for the FitKarma application.
abstract final class AppRoutes {
  // Unauthenticated / Onboarding / Dev
  static const String root = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/auth/login';
  static const String otp = '/auth/otp';
  static const String showcase = '/showcase';

  // Authenticated Top-Level Product Areas
  static const String dashboard = '/dashboard';
  static const String nutrition = '/nutrition';
  static const String nutritionLog = '/nutrition/log';
  static const String workouts = '/workouts';
  static const String sleep = '/sleep';
  static const String recovery = '/recovery';
  static const String aiMealAnalyze = '/ai/meal-analyze';
  static const String family = '/family';
  static const String subscriptions = '/subscriptions';
  static const String settings = '/settings';
  static const String dataVault = '/data-vault';

  /// Routes accessible without active authentication.
  static const Set<String> unauthenticatedRoutes = {
    root,
    onboarding,
    login,
    otp,
    showcase,
  };

  /// Returns true if the route is public / does not require authentication.
  static bool isPublic(String? location) {
    if (location == null) return false;
    return unauthenticatedRoutes.contains(location);
  }
}
