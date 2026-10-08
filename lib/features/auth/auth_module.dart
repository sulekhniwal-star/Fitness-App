/// Auth feature module boundary.
///
/// Encapsulates phone OTP authentication, Google OAuth, session lifecycle,
/// and auth token injection into the Supabase client.
abstract final class AuthModule {
  static const String featureName = 'auth';
}
