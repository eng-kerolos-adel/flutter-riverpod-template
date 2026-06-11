import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

// ─── Sign Out ─────────────────────────────────────────────────────

class SignOutUseCase {
  const SignOutUseCase(this._repository);
  final AuthRepository _repository;
  Future<Either<Failure, void>> call() => _repository.signOut();
}

// ─── Update Profile ───────────────────────────────────────────────

class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, UserEntity>> call(UpdateProfileParams params) {
    return _repository.updateProfile(
      displayName: params.displayName,
      photoUrl: params.photoUrl,
    );
  }
}

class UpdateProfileParams extends Equatable {
  const UpdateProfileParams({this.displayName, this.photoUrl});

  final String? displayName;
  final String? photoUrl;

  @override
  List<Object?> get props => [displayName, photoUrl];
}

// ─── Send Password Reset ──────────────────────────────────────────

class SendPasswordResetUseCase {
  const SendPasswordResetUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, void>> call(String email) {
    return _repository.sendPasswordResetEmail(email: email);
  }
}

// ─── Update Password ──────────────────────────────────────────────

class UpdatePasswordUseCase {
  const UpdatePasswordUseCase(this._repository);
  final AuthRepository _repository;

  Future<Either<Failure, void>> call(UpdatePasswordParams params) {
    return _repository.updatePassword(
      currentPassword: params.currentPassword,
      newPassword: params.newPassword,
    );
  }
}

class UpdatePasswordParams extends Equatable {
  const UpdatePasswordParams({
    required this.currentPassword,
    required this.newPassword,
  });

  final String currentPassword;
  final String newPassword;

  @override
  List<Object?> get props => [currentPassword, newPassword];
}
