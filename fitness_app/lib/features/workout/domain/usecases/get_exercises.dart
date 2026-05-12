/// Use case: fetch the exercise history for a user, optionally filtered by date.
///
/// Returns the full `workoutHistory/{userId}/dailyData` subcollection as a list
/// of `Exercise` entities. When `date` is null, all sessions are returned.
library;

import 'package:equatable/equatable.dart';
import 'package:fitness_app/core/errors/failures.dart';
import 'package:fitness_app/core/usecases/usecase.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise.dart';
import 'package:fitness_app/features/workout/domain/repositories/workout_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetExercises implements UseCase<List<Exercise>, GetExercisesParams> {
  const GetExercises(this.repository);

  final WorkoutRepository repository;

  @override
  Future<Either<Failure, List<Exercise>>> call(GetExercisesParams params) {
    return repository.getExercises(userId: params.userId, date: params.date);
  }
}

class GetExercisesParams extends Equatable {
  const GetExercisesParams({required this.userId, this.date});

  final String userId;
  final DateTime? date;

  @override
  List<Object?> get props => [userId, date];
}
