/// App environment enum.
enum AppEnvironment {
  development,
  staging,
  production;

  static AppEnvironment fromString(String? value) {
    switch (value?.toLowerCase().trim()) {
      case 'staging':
        return AppEnvironment.staging;
      case 'production':
      case 'prod':
        return AppEnvironment.production;
      case 'development':
      case 'dev':
      default:
        return AppEnvironment.development;
    }
  }
}

/// Security violation exception when forbidden server secrets are introduced.
class SecurityViolationException implements Exception {
  final String message;
  const SecurityViolationException(this.message);

  @override
  String toString() => 'SecurityViolationException: $message';
}

/// Configuration validation exception.
class ConfigValidationException implements Exception {
  final String message;
  const ConfigValidationException(this.message);

  @override
  String toString() => 'ConfigValidationException: $message';
}

/// Strongly-typed, validated client environment configuration.
///
/// Strictly enforces the separation between client-safe public variables and
/// privileged server secrets (Supabase service-role, Razorpay secrets, Groq/WhatsApp credentials).
class AppConfig {
  final AppEnvironment environment;
  final String supabaseUrl;
  final String supabaseAnonKey;
  final String? sentryDsn;

  /// Prohibited server-side secret keys that must NEVER be loaded into client configuration.
  static const List<String> prohibitedServerSecretKeys = [
    'SUPABASE_SERVICE_ROLE_KEY',
    'RAZORPAY_KEY_SECRET',
    'RAZORPAY_WEBHOOK_SECRET',
    'GROQ_API_KEY',
    'WHATSAPP_ACCESS_TOKEN',
    'WHATSAPP_WEBHOOK_VERIFY_TOKEN',
    'SERVICE_ROLE_KEY',
    'SECRET_KEY',
    'PRIVATE_KEY',
  ];

  const AppConfig({
    required this.environment,
    required this.supabaseUrl,
    required this.supabaseAnonKey,
    this.sentryDsn,
  });

  /// Factory loading from compile-time environment flags (`--dart-define`).
  factory AppConfig.fromEnvironment() {
    return AppConfig.fromMap({
      'APP_ENV': const String.fromEnvironment(
        'APP_ENV',
        defaultValue: 'development',
      ),
      'SUPABASE_URL': const String.fromEnvironment(
        'SUPABASE_URL',
        defaultValue: 'https://placeholder.supabase.co',
      ),
      'SUPABASE_ANON_KEY': const String.fromEnvironment(
        'SUPABASE_ANON_KEY',
        defaultValue: 'placeholder-anon-key',
      ),
      'SENTRY_DSN': const String.fromEnvironment(
        'SENTRY_DSN',
        defaultValue: '',
      ),
    });
  }

  /// Factory creating configuration from a raw map, enforcing secret exclusion and validation.
  factory AppConfig.fromMap(Map<String, String> map) {
    // 1. Proactively inspect map keys for prohibited server secrets
    assertNoServerSecrets(map);

    final env = AppEnvironment.fromString(map['APP_ENV']);
    final supabaseUrl = (map['SUPABASE_URL'] ?? '').trim();
    final supabaseAnonKey = (map['SUPABASE_ANON_KEY'] ?? '').trim();
    final sentryDsnRaw = (map['SENTRY_DSN'] ?? '').trim();
    final sentryDsn = sentryDsnRaw.isNotEmpty ? sentryDsnRaw : null;

    final config = AppConfig(
      environment: env,
      supabaseUrl: supabaseUrl,
      supabaseAnonKey: supabaseAnonKey,
      sentryDsn: sentryDsn,
    );

    config.validate();
    return config;
  }

  /// Verifies that no server secrets are present in the provided map.
  static void assertNoServerSecrets(Map<String, String> map) {
    for (final entry in map.entries) {
      final normalizedKey = entry.key.toUpperCase();
      for (final forbidden in prohibitedServerSecretKeys) {
        if (normalizedKey.contains(forbidden)) {
          throw SecurityViolationException(
            'Prohibited server secret "$forbidden" detected in client configuration! '
            'Server secrets must reside exclusively in Supabase Edge Functions or Vault.',
          );
        }
      }
    }
  }

  /// Validates configuration integrity.
  void validate() {
    if (supabaseUrl.isEmpty) {
      throw const ConfigValidationException('SUPABASE_URL cannot be empty.');
    }
    final uri = Uri.tryParse(supabaseUrl);
    if (uri == null || (!uri.hasScheme || !uri.scheme.startsWith('http'))) {
      throw ConfigValidationException(
        'SUPABASE_URL "$supabaseUrl" is not a valid HTTP/HTTPS URL.',
      );
    }
    if (supabaseAnonKey.isEmpty) {
      throw const ConfigValidationException(
        'SUPABASE_ANON_KEY cannot be empty.',
      );
    }
  }
}
