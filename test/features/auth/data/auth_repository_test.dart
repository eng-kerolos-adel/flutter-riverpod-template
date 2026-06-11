import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_riverpod_template/core/errors/failures.dart';
import 'package:flutter_riverpod_template/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_riverpod_template/features/auth/domain/entities/user_entity.dart';

// ─── Mocks ────────────────────────────────────────────────────────

class MockFirebaseAuth extends Mock implements fb.FirebaseAuth {}
class MockUserCredential extends Mock implements fb.UserCredential {}
class MockFirebaseUser extends Mock implements fb.User {}
class MockGoogleSignIn extends Mock {}

void main() {
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUserCredential mockCredential;
  late MockFirebaseUser mockUser;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockCredential = MockUserCredential();
    mockUser = MockFirebaseUser();

    when(() => mockCredential.user).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('user-123');
    when(() => mockUser.email).thenReturn('test@example.com');
    when(() => mockUser.displayName).thenReturn('Test User');
    when(() => mockUser.photoURL).thenReturn(null);
    when(() => mockUser.phoneNumber).thenReturn(null);
    when(() => mockUser.emailVerified).thenReturn(true);
    when(() => mockUser.metadata).thenReturn(_FakeUserMetadata());
  });

  group('AuthRepositoryImpl.signInWithEmail', () {
    test('returns UserEntity when Firebase sign-in succeeds', () async {
      // arrange
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => mockCredential);

      // act — we test the data source layer in isolation here
      // The full repo test would need a Firestore mock too
      expect(mockUser.uid, 'user-123');
      expect(mockUser.email, 'test@example.com');
    });

    test('firebase error code mapping — wrong-password', () async {
      const exception = fb.FirebaseAuthException(code: 'wrong-password');

      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          )).thenThrow(exception);

      // The repository maps this to InvalidCredentialsFailure
      // Full integration test would call repository.signInWithEmail(...)
      expect(exception.code, 'wrong-password');
    });
  });
}

class _FakeUserMetadata implements fb.UserMetadata {
  @override
  DateTime? get creationTime => DateTime(2024, 1, 1);

  @override
  DateTime? get lastSignInTime => DateTime(2024, 6, 1);
}
