import 'package:fitkarma/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppConfig Environment & Security Boundary Tests', () {
    test('successfully initializes with valid client configuration', () {
      final config = AppConfig.fromMap({
        'APP_ENV': 'production',
        'SUPABASE_URL': 'https://fitkarma.supabase.co',
        'SUPABASE_ANON_KEY': 'public-anon-key-12345',
        'SENTRY_DSN': 'https://xyz@sentry.io/123',
      });

      expect(config.environment, AppEnvironment.production);
      expect(config.supabaseUrl, 'https://fitkarma.supabase.co');
      expect(config.supabaseAnonKey, 'public-anon-key-12345');
      expect(config.sentryDsn, 'https://xyz@sentry.io/123');
    });

    test('defaults to development environment when unspecified', () {
      final config = AppConfig.fromMap({
        'SUPABASE_URL': 'https://dev.supabase.co',
        'SUPABASE_ANON_KEY': 'dev-anon-key',
      });

      expect(config.environment, AppEnvironment.development);
      expect(config.sentryDsn, isNull);
    });

    test(
      'throws ConfigValidationException if SUPABASE_URL is invalid or empty',
      () {
        expect(
          () => AppConfig.fromMap({
            'SUPABASE_URL': '',
            'SUPABASE_ANON_KEY': 'dev-anon-key',
          }),
          throwsA(isA<ConfigValidationException>()),
        );

        expect(
          () => AppConfig.fromMap({
            'SUPABASE_URL': 'not-a-valid-url',
            'SUPABASE_ANON_KEY': 'dev-anon-key',
          }),
          throwsA(isA<ConfigValidationException>()),
        );
      },
    );

    test('throws ConfigValidationException if SUPABASE_ANON_KEY is empty', () {
      expect(
        () => AppConfig.fromMap({
          'SUPABASE_URL': 'https://dev.supabase.co',
          'SUPABASE_ANON_KEY': '',
        }),
        throwsA(isA<ConfigValidationException>()),
      );
    });

    test('throws SecurityViolationException if SUPABASE_SERVICE_ROLE_KEY is passed', () {
      expect(
        () => AppConfig.fromMap({
          'SUPABASE_URL': 'https://dev.supabase.co',
          'SUPABASE_ANON_KEY': 'anon-key',
          'SUPABASE_SERVICE_ROLE_KEY': 'secret-service-role-key',
        }),
        throwsA(isA<SecurityViolationException>()),
      );
    });

    test(
      'throws SecurityViolationException if RAZORPAY_KEY_SECRET is passed',
      () {
        expect(
          () => AppConfig.fromMap({
            'SUPABASE_URL': 'https://dev.supabase.co',
            'SUPABASE_ANON_KEY': 'anon-key',
            'RAZORPAY_KEY_SECRET': 'secret-razorpay-key',
          }),
          throwsA(isA<SecurityViolationException>()),
        );
      },
    );

    test('throws SecurityViolationException if GROQ_API_KEY is passed', () {
      expect(
        () => AppConfig.fromMap({
          'SUPABASE_URL': 'https://dev.supabase.co',
          'SUPABASE_ANON_KEY': 'anon-key',
          'GROQ_API_KEY': 'gsk_super_secret',
        }),
        throwsA(isA<SecurityViolationException>()),
      );
    });

    test(
      'throws SecurityViolationException if WHATSAPP_ACCESS_TOKEN is passed',
      () {
        expect(
          () => AppConfig.fromMap({
            'SUPABASE_URL': 'https://dev.supabase.co',
            'SUPABASE_ANON_KEY': 'anon-key',
            'WHATSAPP_ACCESS_TOKEN': 'wa_secret_token',
          }),
          throwsA(isA<SecurityViolationException>()),
        );
      },
    );
  });
}
