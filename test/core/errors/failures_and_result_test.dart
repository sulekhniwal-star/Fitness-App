import 'package:fitkarma/core/errors/failures.dart';
import 'package:fitkarma/core/errors/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppFailure Taxonomy & Serialization Tests', () {
    test('all failure classes map to the documented FK-xxxx error codes', () {
      expect(const AuthFailure().code, 'FK-1001');
      expect(const AuthZFailure().code, 'FK-1002');
      expect(const ValidationFailure().code, 'FK-2001');
      expect(const OfflineFailure().code, 'FK-3001');
      expect(const SyncFailure().code, 'FK-3002');
      expect(const ConflictFailure().code, 'FK-3003');
      expect(const AiFailure().code, 'FK-4001');
      expect(const AiConfidenceFailure().code, 'FK-4002');
      expect(const PaymentFailure().code, 'FK-5001');
      expect(const PaymentVerificationFailure().code, 'FK-5002');
      expect(const PaymentMandateFailure().code, 'FK-5003');
      expect(const PaymentDuplicateFailure().code, 'FK-5004');
      expect(const ExternalServiceFailure().code, 'FK-6001');
      expect(const PrivacyFailure().code, 'FK-7001');
      expect(const InternalFailure().code, 'FK-9999');
    });

    test('retryable flag conforms to domain recovery rules', () {
      expect(const OfflineFailure().retryable, isTrue);
      expect(const SyncFailure().retryable, isTrue);
      expect(const ExternalServiceFailure().retryable, isTrue);
      expect(const AiFailure().retryable, isTrue);

      expect(const AuthFailure().retryable, isFalse);
      expect(const ValidationFailure().retryable, isFalse);
      expect(const ConflictFailure().retryable, isFalse);
      expect(const PaymentFailure().retryable, isFalse);
      expect(const PrivacyFailure().retryable, isFalse);
    });

    test('toJson produces envelope adhering to Brain/error_handling.md', () {
      const failure = ValidationFailure(
        message: 'Invalid phone number format.',
        requestId: 'req-12345',
      );

      final json = failure.toJson();
      expect(json, {
        'code': 'FK-2001',
        'message': 'Invalid phone number format.',
        'retryable': false,
        'request_id': 'req-12345',
      });
    });

    test(
      'fromJson deserializes known error codes into specific failure classes',
      () {
        final f1 = AppFailure.fromJson({
          'code': 'FK-1001',
          'message': 'Session expired.',
          'request_id': 'req-1',
        });
        expect(f1, isA<AuthFailure>());
        expect(f1.code, 'FK-1001');
        expect(f1.requestId, 'req-1');

        final f2 = AppFailure.fromJson({
          'code': 'FK-3001',
          'message': 'Offline mode active.',
        });
        expect(f2, isA<OfflineFailure>());
        expect(f2.retryable, isTrue);

        final f3 = AppFailure.fromJson({
          'code': 'FK-5002',
          'message': 'Verification pending.',
        });
        expect(f3, isA<PaymentVerificationFailure>());

        final f4 = AppFailure.fromJson({
          'code': 'FK-UNKNOWN',
          'message': 'Custom internal error.',
        });
        expect(f4, isA<InternalFailure>());
      },
    );

    test('sanitizeUserMessage redacts stack traces, database internals and credentials', () {
      const rawStackTrace =
          'Unhandled exception: Null check operator used on null\n#0 main (package:fitkarma/main.dart:10)';
      expect(
        AppFailure.sanitizeUserMessage(rawStackTrace),
        'An unexpected internal error occurred. Please try again.',
      );

      const rawSqlError =
          'Postgres error: violates foreign key constraint on table users';
      expect(
        AppFailure.sanitizeUserMessage(rawSqlError),
        'The requested operation could not be completed.',
      );

      const rawSecretLeak = 'Failed to connect: secret_key=sk_live_99881122';
      expect(
        AppFailure.sanitizeUserMessage(rawSecretLeak),
        'A security validation error occurred.',
      );
    });
  });

  group('Result<T> Functional Container Tests', () {
    test('Result.success holds data and behaves correctly', () {
      const result = Result<int>.success(42);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.dataOrNull, 42);
      expect(result.failureOrNull, isNull);

      final mapped = result.map((d) => d * 2);
      expect(mapped.dataOrNull, 84);

      final flatMapped = result.flatMap((d) => Result.success('Value: $d'));
      expect(flatMapped.dataOrNull, 'Value: 42');

      final unwrapped = result.getOrElse((_) => 0);
      expect(unwrapped, 42);

      final whenResult = result.when(
        success: (d) => 'Success with $d',
        failure: (f) => 'Failed with ${f.code}',
      );
      expect(whenResult, 'Success with 42');
    });

    test('Result.failure holds failure and handles transformations safely', () {
      const failure = ValidationFailure(message: 'Invalid weight.');
      const result = Result<int>.failure(failure);

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.dataOrNull, isNull);
      expect(result.failureOrNull, failure);

      final mapped = result.map((d) => d * 2);
      expect(mapped.isFailure, isTrue);
      expect(mapped.failureOrNull, failure);

      final flatMapped = result.flatMap((d) => Result.success('Val $d'));
      expect(flatMapped.isFailure, isTrue);
      expect(flatMapped.failureOrNull, failure);

      final fallbackValue = result.getOrElse((_) => 999);
      expect(fallbackValue, 999);

      final whenResult = result.when(
        success: (d) => 'Success with $d',
        failure: (f) => 'Failed with ${f.code}',
      );
      expect(whenResult, 'Failed with FK-2001');
    });
  });
}
