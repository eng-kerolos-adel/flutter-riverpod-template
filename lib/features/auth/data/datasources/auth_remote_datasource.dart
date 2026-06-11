import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart' as app_ex;
import '../models/user_model.dart';

/// Handles all Firebase Auth + Firestore calls.
/// Raw Firebase calls live here — the repository converts results to domain types.
abstract class AuthRemoteDataSource {
  Stream<UserModel?> get authStateChanges;
  Future<UserModel> signInWithEmail({required String email, required String password});
  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  });
  Future<UserModel> signInWithGoogle();
  Future<void> sendPasswordResetEmail({required String email});
  Future<void> signOut();
  Future<UserModel> updateProfile({String? displayName, String? photoUrl});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  final fb.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  @override
  Stream<UserModel?> get authStateChanges {
    return firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      final doc = await firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();
      if (doc.exists) return UserModel.fromFirestore(doc);
      return UserModel.fromFirebaseUser(user);
    });
  }

  @override
  Future<UserModel> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return UserModel.fromFirebaseUser(credential.user!);
    } on fb.FirebaseAuthException catch (e) {
      throw app_ex.FirebaseAuthException(
        message: e.message ?? 'Auth failed',
        firebaseCode: e.code,
      );
    }
  }

  @override
  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user!.updateDisplayName(displayName);
      await credential.user!.reload();

      final model = UserModel.fromFirebaseUser(firebaseAuth.currentUser!).copyWith(
        displayName: displayName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await firestore
          .collection(AppConstants.usersCollection)
          .doc(model.id)
          .set(model.toFirestore());

      await firebaseAuth.currentUser!.sendEmailVerification();
      return model;
    } on fb.FirebaseAuthException catch (e) {
      throw app_ex.FirebaseAuthException(
        message: e.message ?? 'Registration failed',
        firebaseCode: e.code,
      );
    }
  }

  @override
  Future<UserModel> signInWithGoogle() async {
    // Implemented in repository — requires google_sign_in package
    throw UnimplementedError('Implement Google Sign-In in repository');
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on fb.FirebaseAuthException catch (e) {
      throw app_ex.FirebaseAuthException(
        message: e.message ?? 'Failed to send reset email',
        firebaseCode: e.code,
      );
    }
  }

  @override
  Future<void> signOut() => firebaseAuth.signOut();

  @override
  Future<UserModel> updateProfile({String? displayName, String? photoUrl}) async {
    final user = firebaseAuth.currentUser;
    if (user == null) throw const app_ex.UnauthorizedException();

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

    return UserModel.fromFirebaseUser(firebaseAuth.currentUser!);
  }
}
