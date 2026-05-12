/// Abstract contract for authentication operations.
///
/// The domain layer depends only on this interface — it never imports Firebase
/// or any concrete implementation. `AuthRepositoryImpl` in the data layer
/// fulfils this contract.
///
/// All methods return `Either<Failure, T>` so callers handle errors
/// explicitly without try/catch. Stream-based methods (e.g. `watchAuthState`)
/// emit new values whenever Firebase Auth state changes, enabling reactive UI.
library;

import 'package:fitness_app/core/errors/failures.dart';
import 'package:fitness_app/features/authentication/domain/entities/user.dart';
import 'package:fpdart/fpdart.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  });

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, User?>> getCurrentUser();

  Stream<Either<Failure, User?>> watchAuthState();

  Future<Either<Failure, void>> resetPassword(String email);

  Future<Either<Failure, User>> updateUserProfile(User user);

  Future<Either<Failure, void>> deleteAccount();
}