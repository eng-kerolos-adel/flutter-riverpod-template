import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/errors/failures.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/sign_in_with_email.dart';

part 'auth_provider.g.dart';

// ─── Auth State Stream ─────────────────────────────────────────────

@riverpod
Stream<UserEntity?> authState(AuthStateRef ref) {
  final repository = ref.watch(authRepositoryProvider);
  return repository.authStateChanges;
}

// ─── Current User ─────────────────────────────────────────────────

@riverpod
UserEntity? currentUser(CurrentUserRef ref) {
  return ref.watch(authStateProvider).valueOrNull;
}

// ─── Auth Notifier (actions) ───────────────────────────────────────

@riverpod
class AuthNotifier extends _$AuthNotifier {
  late AuthRepository _repository;

  @override
  AsyncValue<void> build() {
    _repository = ref.watch(authRepositoryProvider);
    return const AsyncData(null);
  }

  Future<Either<Failure, UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    final useCase = SignInWithEmailUseCase(_repository);
    final result = await useCase(SignInParams(email: email, password: password));
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (_) => state = const AsyncData(null),
    );
    return result;
  }

  Future<Either<Failure, UserEntity>> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncLoading();
    final result = await _repository.registerWithEmail(
      email: email,
      password: password,
      displayName: displayName,
    );
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (_) => state = const AsyncData(null),
    );
    return result;
  }

  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    state = const AsyncLoading();
    final result = await _repository.signInWithGoogle();
    result.fold(
      (failure) => state = AsyncError(failure, StackTrace.current),
      (_) => state = const AsyncData(null),
    );
    return result;
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    await _repository.signOut();
    state = const AsyncData(null);
  }

  Future<Either<Failure, void>> sendPasswordResetEmail(String email) {
    return _repository.sendPasswordResetEmail(email: email);
  }

  void clearError() {
    state = const AsyncData(null);
  }
}
