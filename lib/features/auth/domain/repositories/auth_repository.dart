import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

/// The contract that all auth repository implementations must fulfill.
/// Defined in domain — no data layer dependencies.
abstract class AuthRepository {
  /// Returns the currently signed-in user, or null if signed out.
  Stream<UserEntity?> get authStateChanges;

  /// Sign in with email and password.
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  });

  /// Create a new account with email and password.
  Future<Either<Failure, UserEntity>> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  });

  /// Sign in with Google OAuth.
  Future<Either<Failure, UserEntity>> signInWithGoogle();

  /// Sign in with Apple ID.
  Future<Either<Failure, UserEntity>> signInWithApple();

  /// Send a password reset email.
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  });

  /// Confirm password reset with OTP code and new password.
  Future<Either<Failure, void>> confirmPasswordReset({
    required String code,
    required String newPassword,
  });

  /// Send email verification to the current user.
  Future<Either<Failure, void>> sendEmailVerification();

  /// Sign out the current user.
  Future<Either<Failure, void>> signOut();

  /// Delete the current user account.
  Future<Either<Failure, void>> deleteAccount();

  /// Update the current user's profile.
  Future<Either<Failure, UserEntity>> updateProfile({
    String? displayName,
    String? photoUrl,
  });

  /// Change the current user's password.
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  });
}
