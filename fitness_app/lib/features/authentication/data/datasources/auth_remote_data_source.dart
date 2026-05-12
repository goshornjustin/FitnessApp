/// Firebase-backed authentication data source.
///
/// `AuthRemoteDataSource` is the abstract interface; `AuthRemoteDataSourceImpl`
/// is the Firebase implementation. Repositories depend on the interface, not
/// the implementation, so it can be swapped out (e.g. in tests).
///
/// Responsibilities:
/// - Sign in / sign up / sign out via Firebase Auth.
/// - Read and write user profile documents in the `users` Firestore collection.
/// - Stream auth state changes so the UI reacts without polling.
/// - Send password-reset emails and delete accounts.
///
/// Throws typed exceptions from `core/errors/exceptions.dart` — never raw
/// Firebase exceptions — so the repository layer can map them to `Failure`.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:fitness_app/core/errors/exceptions.dart';
import 'package:fitness_app/features/authentication/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  });

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Stream<UserModel?> watchAuthState();

  Future<void> resetPassword(String email);

  Future<UserModel> updateUserProfile(UserModel user);

  Future<void> deleteAccount();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.firestore,
  });

  final firebase_auth.FirebaseAuth firebaseAuth;
  final FirebaseFirestore firestore;

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final result = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) {
        throw const AuthException('User not found');
      }

      return await _getUserFromFirestore(result.user!.uid);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Authentication failed');
    } catch (e) {
      throw const AuthException('Authentication failed');
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final result = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user == null) {
        throw const AuthException('Failed to create user');
      }

      // Create initial user profile
      final user = UserModel(
        id: result.user!.uid,
        name: name,
        email: email,
        age: 0,
        gender: '',
        weight: 0.0,
        height: 0.0,
        activityLevel: '',
        fitnessGoal: '',
        goalReason: '',
        createdAt: DateTime.now(),
      );

      await _saveUserToFirestore(user);
      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Failed to create account');
    } catch (e) {
      throw const AuthException('Failed to create account');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuth.signOut();
    } catch (e) {
      throw const AuthException('Failed to sign out');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final firebaseUser = firebaseAuth.currentUser;
      if (firebaseUser == null) return null;

      return await _getUserFromFirestore(firebaseUser.uid);
    } catch (e) {
      return null;
    }
  }

  @override
  Stream<UserModel?> watchAuthState() {
    return firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) return null;
      
      try {
        return await _getUserFromFirestore(firebaseUser.uid);
      } catch (e) {
        return null;
      }
    });
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Failed to send password reset email');
    } catch (e) {
      throw const AuthException('Failed to send password reset email');
    }
  }

  @override
  Future<UserModel> updateUserProfile(UserModel user) async {
    try {
      await _saveUserToFirestore(user.copyWith(updatedAt: DateTime.now()) as UserModel);
      return user;
    } catch (e) {
      throw const AuthException('Failed to update profile');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) throw const AuthException('No user logged in');

      // Delete user document from Firestore
      await firestore.collection('users').doc(user.uid).delete();
      
      // Delete Firebase Auth account
      await user.delete();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Failed to delete account');
    } catch (e) {
      throw const AuthException('Failed to delete account');
    }
  }

  Future<UserModel> _getUserFromFirestore(String uid) async {
    try {
      final doc = await firestore.collection('users').doc(uid).get();
      
      if (!doc.exists) {
        throw const AuthException('User profile not found');
      }

      return UserModel.fromJson(doc.data()!);
    } catch (e) {
      throw const AuthException('Failed to get user profile');
    }
  }

  Future<void> _saveUserToFirestore(UserModel user) async {
    try {
      await firestore.collection('users').doc(user.id).set(user.toJson());
    } catch (e) {
      throw const AuthException('Failed to save user profile');
    }
  }
}