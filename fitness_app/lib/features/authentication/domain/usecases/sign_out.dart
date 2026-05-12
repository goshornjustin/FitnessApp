/// Use case: sign the current user out of Firebase Auth.
///
/// Takes [NoParams] since no arguments are needed. After this succeeds,
/// `authStateProvider` emits `null` and the router redirects to `/auth`.
library;

import 'package:fitness_app/core/errors/failures.dart';
import 'package:fitness_app/core/usecases/usecase.dart';
import 'package:fitness_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:fpdart/fpdart.dart';

class SignOut implements UseCase<void, NoParams> {
  const SignOut(this.repository);

  final AuthRepository repository;

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.signOut();
  }
}