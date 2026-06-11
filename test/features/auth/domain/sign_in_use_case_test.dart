import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_riverpod_template/core/errors/failures.dart';
import 'package:flutter_riverpod_template/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_riverpod_template/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod_template/features/auth/domain/usecases/sign_in_with_email.dart';

// ─── Mocks ────────────────────────────────────────────────────────

class MockAuthRepository extends Mock implements AuthRepository {}

// ─── Helpers ──────────────────────────────────────────────────────

const tUser = UserEntity(
  id: 'user-123',
  email: 'test@example.com',
  displayName: 'Test User',
  isEmailVerified: true,
);

const tParams = SignInParams(
  email: 'test@example.com',
  password: 'Password123',
);

void main() {
  late SignInWithEmailUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = SignInWithEmailUseCase(mockRepository);
  });

  group('SignInWithEmailUseCase', () {
    test('returns UserEntity on successful sign-in', () async {
      // arrange
      when(() => mockRepository.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Right(tUser));

      // act
      final result = await useCase(tParams);

      // assert
      expect(result, const Right<Failure, UserEntity>(tUser));
      verify(() => mockRepository.signInWithEmail(
            email: tParams.email,
            password: tParams.password,
          )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('returns InvalidCredentialsFailure on wrong credentials', () async {
      // arrange
      when(() => mockRepository.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Left(InvalidCredentialsFailure()));

      // act
      final result = await useCase(tParams);

      // assert
      expect(result, const Left<Failure, UserEntity>(InvalidCredentialsFailure()));
    });

    test('returns NetworkFailure on network error', () async {
      // arrange
      when(() => mockRepository.signInWithEmail(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => const Left(NetworkFailure()));

      // act
      final result = await useCase(tParams);

      // assert
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Expected Left but got Right'),
      );
    });
  });

  group('SignInParams', () {
    test('equatable — same values are equal', () {
      const a = SignInParams(email: 'a@b.com', password: '12345678');
      const b = SignInParams(email: 'a@b.com', password: '12345678');
      expect(a, equals(b));
    });

    test('equatable — different values are not equal', () {
      const a = SignInParams(email: 'a@b.com', password: '12345678');
      const b = SignInParams(email: 'c@d.com', password: '12345678');
      expect(a, isNot(equals(b)));
    });
  });
}
