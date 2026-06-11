import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod_template/features/auth/domain/entities/user_entity.dart';

void main() {
  group('UserEntity', () {
    const user = UserEntity(
      id: '1',
      email: 'john.doe@example.com',
      displayName: 'John Doe',
      isEmailVerified: true,
    );

    test('initials — two words returns first letters', () {
      expect(user.initials, 'JD');
    });

    test('initials — single name returns first letter', () {
      const single = UserEntity(id: '2', email: 'a@b.com', displayName: 'Madonna');
      expect(single.initials, 'M');
    });

    test('initials — no display name falls back to email first letter', () {
      const noName = UserEntity(id: '3', email: 'xyz@example.com');
      expect(noName.initials, 'X');
    });

    test('firstName returns first word', () {
      expect(user.firstName, 'John');
    });

    test('lastName returns last word', () {
      expect(user.lastName, 'Doe');
    });

    test('copyWith produces new entity with updated fields', () {
      final updated = user.copyWith(displayName: 'Jane Doe');
      expect(updated.displayName, 'Jane Doe');
      expect(updated.id, user.id); // unchanged
      expect(updated.email, user.email); // unchanged
    });

    test('equatable — same values are equal', () {
      const a = UserEntity(id: '1', email: 'a@b.com');
      const b = UserEntity(id: '1', email: 'a@b.com');
      expect(a, equals(b));
    });

    test('equatable — different ids are not equal', () {
      const a = UserEntity(id: '1', email: 'a@b.com');
      const b = UserEntity(id: '2', email: 'a@b.com');
      expect(a, isNot(equals(b)));
    });
  });
}
