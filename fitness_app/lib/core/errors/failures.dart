/// Domain-layer error types returned by repositories via `Either<Failure, T>`.
///
/// Repositories catch raw exceptions (from `exceptions.dart`) and map them to
/// the appropriate `Failure` subclass. Presentation-layer code pattern-matches
/// on these to decide what to show the user — it never sees raw exceptions.
///
/// Failure hierarchy:
/// - [ServerFailure] — Firestore or backend call failed
/// - [CacheFailure] — local Hive storage read/write failed
/// - [NetworkFailure] — device has no internet connection
/// - [AuthFailure] — Firebase Auth rejected the request (e.g. wrong password)
/// - [ValidationFailure] — user-supplied data failed validation rules
library;

import 'package:equatable/equatable.dart';

/// Base class for all domain-layer failures.
///
/// Extend this to add new failure types. Always add the failure's
/// distinguishing fields to [props] so equality works correctly.
abstract class Failure extends Equatable {
  const Failure();
  
  @override
  List<Object> get props => [];
}

class ServerFailure extends Failure {
  const ServerFailure();
}

class CacheFailure extends Failure {
  const CacheFailure();
}

class NetworkFailure extends Failure {
  const NetworkFailure();
}

class AuthFailure extends Failure {
  final String message;
  
  const AuthFailure(this.message);
  
  @override
  List<Object> get props => [message];
}

class ValidationFailure extends Failure {
  final String message;
  
  const ValidationFailure(this.message);
  
  @override
  List<Object> get props => [message];
}