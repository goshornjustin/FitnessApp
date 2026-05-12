/// Use case: log a completed exercise session for the current user.
///
/// Generates a UUID for the new `Exercise` and delegates to
/// `WorkoutRepository.addExercise`, which writes calories burned and current
/// weight to `workoutHistory/{userId}/dailyData/{YYYY-M-D}`.
library;

import 'package:equatable/equatable.dart';
import 'package:fitness_app/core/errors/failures.dart';
import 'package:fitness_app/core/usecases/usecase.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise.dart';
import 'package:fitness_app/features/workout/domain/repositories/workout_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

class AddExercise implements UseCase<Exercise, AddExerciseParams> {
  const AddExercise(this.repository);

  final WorkoutRepository repository;

  @override
  Future<Either<Failure, Exercise>> call(AddExerciseParams params) {
    final exercise = Exercise(
      id: const Uuid().v4(),
      userId: params.userId,
      name: params.name,
      type: params.type,
      date: params.date,
      caloriesBurned: params.caloriesBurned,
      duration: params.duration,
      weight: params.weight,
      notes: params.notes,
    );
    return repository.addExercise(exercise);
  }
}

class AddExerciseParams extends Equatable {
  const AddExerciseParams({
    required this.userId,
    required this.name,
    required this.type,
    required this.date,
    required this.caloriesBurned,
    this.duration,
    this.weight,
    this.notes,
  });

  final String userId;
  final String name;
  final ExerciseType type;
  final DateTime date;
  final int caloriesBurned;
  final int? duration;
  final double? weight;
  final String? notes;

  @override
  List<Object?> get props => [userId, name, date];
}
