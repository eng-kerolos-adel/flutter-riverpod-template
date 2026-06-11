import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod_template/core/errors/failures.dart';

void main() {
  group('Failure equality', () {
    test('NetworkFailure instances are equal', () {
      const a = NetworkFailure();
      const b = NetworkFailure();
      expect(a, equals(b));
    });

    test('ServerFailure with same code and status are equal', () {
      const a = ServerFailure(message: 'Error', statusCode: 500);
      const b = ServerFailure(message: 'Error', statusCode: 500);
      expect(a, equals(b));
    });

    test('ServerFailure with different status codes are not equal', () {
      const a = ServerFailure(message: 'Error', statusCode: 500);
      const b = ServerFailure(message: 'Error', statusCode: 503);
      expect(a, isNot(equals(b)));
    });

    test('ValidationFailure includes field in props', () {
      const a = ValidationFailure(message: 'Required', field: 'email');
      const b = ValidationFailure(message: 'Required', field: 'password');
      expect(a, isNot(equals(b)));
    });

    test('Different failure types are not equal', () {
      const a = NetworkFailure();
      const b = UnexpectedFailure();
      expect(a, isNot(equals(b)));
    });
  });

  group('Failure messages', () {
    test('NetworkFailure has default message', () {
      const f = NetworkFailure();
      expect(f.message, isNotEmpty);
    });

    test('AuthFailure carries custom message', () {
      const f = AuthFailure(message: 'Custom auth error');
      expect(f.message, 'Custom auth error');
    });
  });
}
