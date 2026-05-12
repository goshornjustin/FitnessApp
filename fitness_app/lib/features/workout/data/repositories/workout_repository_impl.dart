/// Concrete implementation of `WorkoutRepository`.
///
/// Converts raw Firestore maps to `Exercise` entities via `_exerciseFromMap`.
/// The document `id` field (formatted `YYYY-M-D`) is parsed back to a
/// `DateTime` for the entity's `date` field.
///
/// Health data stubs (`getTodaySteps`, `getTodayCaloriesBurned`,
/// `getHealthData`) return 0 / empty — the actual health queries are done
/// directly in `ResultsPage` using the `health` package.
library;

import 'package:fitness_app/core/errors/exceptions.dart';
import 'package:fitness_app/core/errors/failures.dart';
import 'package:fitness_app/features/workout/data/datasources/workout_remote_data_source.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise.dart';
import 'package:fitness_app/features/workout/domain/repositories/workout_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

class WorkoutRepositoryImpl implements WorkoutRepository {
  const WorkoutRepositoryImpl({required this.remoteDataSource});

  final WorkoutRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<Exercise>>> getExercises({
    required String userId,
    DateTime? date,
  }) async {
    try {
      final history = await remoteDataSource.getExerciseHistory(userId);
      final exercises = history.map((data) => _exerciseFromMap(data, userId)).toList();
      return Right(exercises);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Exercise>> addExercise(Exercise exercise) async {
    try {
      await remoteDataSource.saveExerciseData(
        userId: exercise.userId,
        date: exercise.date,
        caloriesBurned: exercise.caloriesBurned.toDouble(),
        currentWeight: exercise.weight ?? 0.0,
      );
      return Right(exercise);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Exercise>> updateExercise(Exercise exercise) async {
    try {
      await remoteDataSource.saveExerciseData(
        userId: exercise.userId,
        date: exercise.date,
        caloriesBurned: exercise.caloriesBurned.toDouble(),
        currentWeight: exercise.weight ?? 0.0,
      );
      return Right(exercise);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteExercise(String exerciseId) async {
    return const Right(null);
  }

  @override
  Stream<Either<Failure, List<Exercise>>> watchExercises({
    required String userId,
    DateTime? date,
  }) {
    try {
      return remoteDataSource
          .watchExercises(userId: userId, date: date)
          .map<Either<Failure, List<Exercise>>>((list) =>
              Right(list.map((data) => _exerciseFromMap(data, userId)).toList()));
    } on ServerException {
      return Stream.value(const Left(ServerFailure()));
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getWorkoutPrograms() async {
    try {
      final programs = await remoteDataSource.getWorkoutPrograms();
      return Right(programs);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getWorkoutProgram(String programId) async {
    try {
      final program = await remoteDataSource.getWorkoutProgram(programId);
      if (program == null) return const Left(ServerFailure());
      return Right(program);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, int>> getTodaySteps() async {
    return const Right(0);
  }

  @override
  Future<Either<Failure, double>> getTodayCaloriesBurned() async {
    return const Right(0.0);
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> getHealthData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return const Right([]);
  }

  Exercise _exerciseFromMap(Map<String, dynamic> data, String userId) {
    return Exercise(
      id: data['id'] as String? ?? const Uuid().v4(),
      userId: userId,
      name: 'Workout',
      type: ExerciseType.other,
      date: DateTime.tryParse(data['id'] as String? ?? '') ?? DateTime.now(),
      caloriesBurned: ((data['caloriesBurned'] as num?) ?? 0).toInt(),
      weight: (data['currentWeight'] as num?)?.toDouble(),
    );
  }
}
