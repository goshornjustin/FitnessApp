/// Abstract contract for workout and exercise data operations.
///
/// Three concerns:
/// 1. **Exercise history** — CRUD + real-time stream of logged exercise
///    sessions for a user, keyed by date.
/// 2. **Workout programs** — read-only fetch of curated program documents
///    from the `exercises` Firestore collection, grouped by category
///    (e.g. `lowerBody`, `upperBody`, `cardio`).
/// 3. **Health data** — stubs for step count and calories burned from the
///    platform health API (currently returns 0; implemented directly in
///    `ResultsPage` using the `health` package).
library;

import 'package:fitness_app/core/errors/failures.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise.dart';
import 'package:fpdart/fpdart.dart';

abstract class WorkoutRepository {
  // Exercises
  Future<Either<Failure, List<Exercise>>> getExercises({
    required String userId,
    DateTime? date,
  });

  Future<Either<Failure, Exercise>> addExercise(Exercise exercise);

  Future<Either<Failure, Exercise>> updateExercise(Exercise exercise);

  Future<Either<Failure, void>> deleteExercise(String exerciseId);

  Stream<Either<Failure, List<Exercise>>> watchExercises({
    required String userId,
    DateTime? date,
  });

  // Workout Programs
  Future<Either<Failure, List<Map<String, dynamic>>>> getWorkoutPrograms();

  Future<Either<Failure, Map<String, dynamic>>> getWorkoutProgram(
    String programId,
  );

  // Health Data Integration
  Future<Either<Failure, int>> getTodaySteps();

  Future<Either<Failure, double>> getTodayCaloriesBurned();

  Future<Either<Failure, List<Map<String, dynamic>>>> getHealthData({
    required DateTime startDate,
    required DateTime endDate,
  });
}