/// Base use-case contract used throughout the domain layer.
///
/// Every use case in the app implements `UseCase<ReturnType, Params>` and
/// exposes a single `call()` method. This keeps business logic isolated from
/// both the UI and data layers, and makes each use case independently testable.
///
/// Example usage:
/// ```dart
/// class SignInWithEmail implements UseCase<User, SignInParams> { ... }
/// final result = await signIn(SignInParams(email: e, password: p));
/// result.fold((failure) => ..., (user) => ...);
/// ```
///
/// When a use case takes no arguments, pass [NoParams] as the `Params` type.
library;

import 'package:equatable/equatable.dart';
import 'package:fitness_app/core/errors/failures.dart';
import 'package:fpdart/fpdart.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}