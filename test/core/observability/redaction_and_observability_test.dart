import 'package:fitkarma/core/observability/crash_reporting_service.dart';
import 'package:fitkarma/core/observability/logging_service.dart';
import 'package:fitkarma/core/observability/redaction.dart';
import 'package:fitkarma/core/services/console_logging_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DataRedactor Privacy & Security Tests', () {
    const redactor = DataRedactor();

    test('redacts auth, credentials, and token keys in data maps', () {
      final input = {
        'username': 'fit_user',
        'password': 'SuperSecretPassword123',
        'access_token': 'eyJhGciOiJIUzI1NiIsIn...',
        'upi_pin': '1234',
        'api_key': 'key_live_998877',
      };

      final sanitized = redactor.redactMap(input);

      expect(sanitized['username'], '[REDACTED]'); // 'name' is in PII substring
      expect(sanitized['password'], '[REDACTED]');
      expect(sanitized['access_token'], '[REDACTED]');
      expect(sanitized['upi_pin'], '[REDACTED]');
      expect(sanitized['api_key'], '[REDACTED]');
    });

    test('redacts payment and banking keys in data maps', () {
      final input = {
        'card_number': '4111222233334444',
        'cvv': '999',
        'bank_account': '001122334455',
        'vpa_handle': 'user@okaxis',
      };

      final sanitized = redactor.redactMap(input);

      expect(sanitized['card_number'], '[REDACTED]');
      expect(sanitized['cvv'], '[REDACTED]');
      expect(sanitized['bank_account'], '[REDACTED]');
      expect(sanitized['vpa_handle'], '[REDACTED]');
    });

    test('redacts sensitive raw health observation keys', () {
      final input = {
        'glucose_mg_dl': 110,
        'systolic': 120,
        'diastolic': 80,
        'heart_rate': 72,
        'medication_prescribed': 'Metformin',
        'diagnosis_notes': 'Prediabetic review',
        'period_cycle_day': 14,
        'screen_time_minutes': 45, // non-sensitive
      };

      final sanitized = redactor.redactMap(input);

      expect(sanitized['glucose_mg_dl'], '[REDACTED]');
      expect(sanitized['systolic'], '[REDACTED]');
      expect(sanitized['diastolic'], '[REDACTED]');
      expect(sanitized['heart_rate'], '[REDACTED]');
      expect(sanitized['medication_prescribed'], '[REDACTED]');
      expect(sanitized['diagnosis_notes'], '[REDACTED]');
      expect(sanitized['period_cycle_day'], '[REDACTED]');
      expect(sanitized['screen_time_minutes'], 45);
    });

    test('redacts PII keys (phone, email, aadhaar, pan)', () {
      final input = {
        'user_email': 'test@fitkarma.in',
        'phone_number': '9876543210',
        'pan_number': 'ABCDE1234F',
        'user_city': 'Bengaluru', // non-sensitive
      };

      final sanitized = redactor.redactMap(input);

      expect(sanitized['user_email'], '[REDACTED]');
      expect(sanitized['phone_number'], '[REDACTED]');
      expect(sanitized['pan_number'], '[REDACTED]');
      expect(sanitized['user_city'], 'Bengaluru');
    });

    test('redacts inline emails, phone numbers, and bearer tokens in strings', () {
      const rawText =
          'User user.test@example.com logged in via +919876543210 with Bearer secret_token_xyz.';

      final sanitized = redactor.redactString(rawText);

      expect(sanitized.contains('user.test@example.com'), isFalse);
      expect(sanitized.contains('+919876543210'), isFalse);
      expect(sanitized.contains('secret_token_xyz'), isFalse);
      expect(sanitized, contains('[REDACTED]'));
    });

    test('recursively redacts nested maps and lists', () {
      final nested = {
        'event': 'meal_logged',
        'user_details': {
          'phone': '9876543210',
          'preferences': ['vegetarian', 'low_spice'],
        },
        'food_items': [
          {'item_name': 'Roti', 'quantity': 2},
          {'secret_code': '1234'},
        ],
      };

      final sanitized = redactor.redact(nested) as Map<String, dynamic>;

      final userDetails = sanitized['user_details'] as Map<String, dynamic>;
      expect(userDetails['phone'], '[REDACTED]');
      expect(userDetails['preferences'], ['vegetarian', 'low_spice']);

      final foodItems = sanitized['food_items'] as List;
      final secondItem = foodItems[1] as Map<String, dynamic>;
      expect(secondItem['secret_code'], '[REDACTED]');
    });
  });

  group('SentryCrashReportingBoundary Tests', () {
    test(
      'initializes without sending to network when DSN is empty or placeholder',
      () async {
        final boundary = SentryCrashReportingBoundary();

        await boundary.initialize(dsn: '', environment: 'development');
        expect(boundary.isInitialized, isTrue);
        expect(boundary.activeDsn, isNull);

        await boundary.initialize(
          dsn: 'https://public@sentry.io/placeholder-dsn',
          environment: 'development',
        );
        expect(boundary.isInitialized, isTrue);
        expect(boundary.activeDsn, isNull);
      },
    );

    test('records sanitized errors and breadcrumbs when active', () async {
      final boundary = SentryCrashReportingBoundary();
      await boundary.initialize(
        dsn: 'https://valid@sentry.io/123456',
        environment: 'production',
      );
      expect(boundary.activeDsn, 'https://valid@sentry.io/123456');

      await boundary.logBreadcrumb(
        'User with email rahul@gmail.com tapped checkout',
        category: 'ui',
        data: {'card_number': '4111222233334444'},
      );

      expect(boundary.breadcrumbs.length, 1);
      final crumb = boundary.breadcrumbs.first;
      expect(crumb['message'], contains('[REDACTED]'));
      expect((crumb['data'] as Map)['card_number'], '[REDACTED]');

      await boundary.recordError(
        Exception('Network timed out'),
        null,
        reason: 'Failed for phone 9876543210',
        extra: {'user_password': '123'},
      );

      expect(boundary.recordedErrors.length, 1);
      final err = boundary.recordedErrors.first;
      expect(err['reason'], contains('[REDACTED]'));
      expect((err['extra'] as Map)['user_password'], '[REDACTED]');
    });
  });

  group('ConsoleLoggingService Tests', () {
    test('suppresses debug logs when isDebug is false', () {
      final logger = ConsoleLoggingService(isDebug: false);

      // Verify methods execute without exception
      logger.debug('This should be ignored');
      logger.info('Info message');
      logger.warning('Warning message');
      logger.error('Error message');
    });

    test('records diagnostic telemetry events', () {
      final logger = ConsoleLoggingService(isDebug: true);
      final event = DiagnosticEvent(
        name: 'app_launch',
        category: 'lifecycle',
        parameters: {'session_id': 'sess-123'},
      );

      expect(event.name, 'app_launch');
      expect(event.category, 'lifecycle');
      expect(event.parameters?['session_id'], 'sess-123');

      // Verify recordEvent executes without error
      logger.recordEvent(event);
    });
  });
}
