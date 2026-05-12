/// Use case: fetch all workout program documents from Firestore.
///
/// Reads the `exercises` collection where each document represents a category
/// (e.g. `lowerBody`, `upperBody`, `cardio`) containing a list of exercises
/// with name, instructions, and duration. Takes [NoParams].
library;

import 'package:fitness_app/core/errors/failures.dart';
import 'package:fitness_app/core/usecases/usecase.dart';
import 'package:fitness_app/features/workout/domain/repositories/workout_repository.dart';
import 'package:fpdart/fpdart.dart';

class GetWorkoutPrograms implements UseCase<List<Map<String, dynamic>>, NoParams> {
  const GetWorkoutPrograms(this.repository);

  final WorkoutRepository repository;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(NoParams params) {
    return repository.getWorkoutPrograms();
  }
}
