/// Use case: sign an existing user in with email and password.
///
/// Delegates to `AuthRepository.signInWithEmailAndPassword`. On success
/// returns the [User] entity; on failure returns an `AuthFailure` or
/// `NetworkFailure`.
///
/// [SignInParams] carries the credentials. Pass it directly to `call()`:
/// ```dart
/// final result = await signIn(SignInParams(email: e, password: p));
/// ```
library;

import 'package:equatable/equatable.dart';
import 'package:fitness_app/core/errors/failures.dart';
import 'package:fitness_app/core/usecases/usecase.dart';
import 'package:fitness_app/features/authentication/domain/entities/user.dart';
import 'package:fitness_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class SignInWithEmail implements UseCase<User, SignInParams> {
  const SignInWithEmail(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, User>> call(SignInParams params) async {
    return await repository.signInWithEmailAndPassword(
      email: params.email,
      password: params.password,
    );
  }
}

class SignInParams extends Equatable {
  const SignInParams({
    required this.email,
    required this.password,
  });

  final String email;
  final String password;

  @override
  List<Object> get props => [email, password];
}