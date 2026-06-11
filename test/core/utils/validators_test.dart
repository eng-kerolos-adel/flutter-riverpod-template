import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod_template/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('returns null for valid email', () {
      expect(Validators.email('user@example.com'), isNull);
      expect(Validators.email('user.name+tag@sub.domain.co.uk'), isNull);
    });

    test('returns error for empty email', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email(null), isNotNull);
    });

    test('returns error for invalid email format', () {
      expect(Validators.email('notanemail'), isNotNull);
      expect(Validators.email('missing@'), isNotNull);
      expect(Validators.email('@nodomain.com'), isNotNull);
    });
  });

  group('Validators.password', () {
    test('returns null for strong password', () {
      expect(Validators.password('Password123'), isNull);
      expect(Validators.password('SecureP@ss1'), isNull);
    });

    test('returns error for empty password', () {
      expect(Validators.password(''), isNotNull);
      expect(Validators.password(null), isNotNull);
    });

    test('returns error for short password', () {
      expect(Validators.password('Abc1'), isNotNull);
    });

    test('returns error for no uppercase letter', () {
      expect(Validators.password('password123'), isNotNull);
    });

    test('returns error for no digit', () {
      expect(Validators.password('PasswordOnly'), isNotNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('returns null when passwords match', () {
      expect(Validators.confirmPassword('Password123', 'Password123'), isNull);
    });

    test('returns error when passwords do not match', () {
      expect(Validators.confirmPassword('Password123', 'Different1'), isNotNull);
    });

    test('returns error for empty confirm password', () {
      expect(Validators.confirmPassword('', 'Password123'), isNotNull);
      expect(Validators.confirmPassword(null, 'Password123'), isNotNull);
    });
  });

  group('Validators.name', () {
    test('returns null for valid name', () {
      expect(Validators.name('John Doe'), isNull);
      expect(Validators.name('محمد'), isNull); // Arabic name
    });

    test('returns error for empty name', () {
      expect(Validators.name(''), isNotNull);
      expect(Validators.name(null), isNotNull);
    });

    test('returns error for too short name', () {
      expect(Validators.name('A'), isNotNull);
    });
  });

  group('Validators.compose', () {
    test('returns null when all validators pass', () {
      final validator = Validators.compose([
        Validators.email,
        (v) => v != null && v.contains('@') ? null : 'Must have @',
      ]);
      expect(validator('test@example.com'), isNull);
    });

    test('returns first error when a validator fails', () {
      final validator = Validators.compose([
        Validators.email,
        (v) => v != null && v.contains('@') ? null : 'Must have @',
      ]);
      expect(validator('invalid'), isNotNull);
    });
  });
}
