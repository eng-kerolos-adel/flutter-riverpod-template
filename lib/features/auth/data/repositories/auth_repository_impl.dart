import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';

part 'auth_repository_impl.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(
    firebaseAuth: firebase_auth.FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
    googleSignIn: GoogleSignIn(),
  );
}

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required this.firebaseAuth,
    required this.firestore,
    required this.googleSignIn,
  });

  final firebase_auth.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;
  final GoogleSignIn googleSignIn;

  @override
  Stream<UserEntity?> get authStateChanges {
    return firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      try {
        // Enrich with Firestore data
        final doc = await firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .get();

        if (doc.exists) {
          return UserModel.fromFirestore(doc).toEntity();
        }
        return UserModel.fromFirebaseUser(user).toEntity();
      } catch (e) {
        AppLogger.warning('Failed to fetch user from Firestore', e);
        return UserModel.fromFirebaseUser(user).toEntity();
      }
    });
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;
      await _updateLastSeen(user.uid);
      final model = UserModel.fromFirebaseUser(user);
      return Right(model.toEntity());
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(_mapFirebaseAuthException(e));
    } catch (e, st) {
      AppLogger.error('signInWithEmail error', e, st);
      return Left(UnexpectedFailure(stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user!;

      // Update display name
      await user.updateDisplayName(displayName.trim());
      await user.reload();

      // Create Firestore document
      final model = UserModel.fromFirebaseUser(user).copyWith(
        displayName: displayName.trim(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _createUserDocument(model);

      // Send verification email
      await user.sendEmailVerification();

      return Right(model.toEntity());
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(_mapFirebaseAuthException(e));
    } catch (e, st) {
      AppLogger.error('registerWithEmail error', e, st);
      return Left(UnexpectedFailure(stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return const Left(AuthFailure(message: 'Google sign-in was cancelled'));
      }

      final googleAuth = await googleUser.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user!;

      // Upsert Firestore document
      await _upsertUserDocument(user);

      return Right(UserModel.fromFirebaseUser(user).toEntity());
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(_mapFirebaseAuthException(e));
    } catch (e, st) {
      AppLogger.error('signInWithGoogle error', e, st);
      return Left(UnexpectedFailure(stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithApple() async {
    // TODO: Implement Apple Sign-In
    return const Left(AuthFailure(message: 'Apple Sign-In not yet implemented'));
  }

  @override
  Future<Either<Failure, void>> sendPasswordResetEmail({
    required String email,
  }) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email.trim());
      return const Right(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(_mapFirebaseAuthException(e));
    } catch (e, st) {
      return Left(UnexpectedFailure(stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, void>> confirmPasswordReset({
    required String code,
    required String newPassword,
  }) async {
    try {
      await firebaseAuth.confirmPasswordReset(
        code: code,
        newPassword: newPassword,
      );
      return const Right(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(_mapFirebaseAuthException(e));
    } catch (e, st) {
      return Left(UnexpectedFailure(stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, void>> sendEmailVerification() async {
    try {
      await firebaseAuth.currentUser?.sendEmailVerification();
      return const Right(null);
    } catch (e, st) {
      return Left(UnexpectedFailure(stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await Future.wait([
        firebaseAuth.signOut(),
        googleSignIn.signOut(),
      ]);
      return const Right(null);
    } catch (e, st) {
      return Left(UnexpectedFailure(stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return const Left(UnauthorizedFailure());

      await firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .delete();
      await user.delete();
      return const Right(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(_mapFirebaseAuthException(e));
    } catch (e, st) {
      return Left(UnexpectedFailure(stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) return const Left(UnauthorizedFailure());

      if (displayName != null) await user.updateDisplayName(displayName);
      if (photoUrl != null) await user.updatePhotoURL(photoUrl);
      await user.reload();

      await firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update({
        if (displayName != null) 'displayName': displayName,
        if (photoUrl != null) 'photoUrl': photoUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final updated = firebaseAuth.currentUser!;
      return Right(UserModel.fromFirebaseUser(updated).toEntity());
    } catch (e, st) {
      return Left(UnexpectedFailure(stackTrace: st));
    }
  }

  @override
  Future<Either<Failure, void>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null || user.email == null) {
        return const Left(UnauthorizedFailure());
      }

      // Re-authenticate first
      final cred = firebase_auth.EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
      return const Right(null);
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(_mapFirebaseAuthException(e));
    } catch (e, st) {
      return Left(UnexpectedFailure(stackTrace: st));
    }
  }

  // ─── Helpers ─────────────────────────────────────────────────────

  Future<void> _createUserDocument(UserModel model) async {
    await firestore
        .collection(AppConstants.usersCollection)
        .doc(model.id)
        .set(model.toFirestore());
  }

  Future<void> _upsertUserDocument(firebase_auth.User user) async {
    final ref = firestore
        .collection(AppConstants.usersCollection)
        .doc(user.uid);

    final doc = await ref.get();
    if (!doc.exists) {
      await ref.set(UserModel.fromFirebaseUser(user).toFirestore());
    } else {
      await ref.update({'updatedAt': FieldValue.serverTimestamp()});
    }
  }

  Future<void> _updateLastSeen(String uid) async {
    try {
      await firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update({'updatedAt': FieldValue.serverTimestamp()});
    } catch (_) {
      // Non-critical — don't fail auth for this
    }
  }

  Failure _mapFirebaseAuthException(firebase_auth.FirebaseAuthException e) {
    return switch (e.code) {
      'user-not-found' ||
      'wrong-password' ||
      'invalid-credential' =>
        const InvalidCredentialsFailure(),
      'email-already-in-use' => const EmailAlreadyInUseFailure(),
      'weak-password' => const WeakPasswordFailure(),
      'user-disabled' =>
        const AuthFailure(message: 'This account has been disabled.'),
      'too-many-requests' =>
        const AuthFailure(message: 'Too many attempts. Please try later.'),
      'network-request-failed' => const NetworkFailure(),
      _ => AuthFailure(message: e.message ?? 'Authentication failed.'),
    };
  }
}
