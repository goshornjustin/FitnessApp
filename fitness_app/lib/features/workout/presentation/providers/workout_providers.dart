/// Riverpod providers for the workout / programs feature.
///
/// - `workoutProgramsProvider` — fetches all program documents from the
///   `exercises` collection. Returns an empty list on failure.
/// - `workoutProgramProvider` — family provider that fetches a single program
///   by category string (e.g. `'lowerBody'`).
/// - `exerciseHistoryProvider` — fetches the current user's full exercise log.
/// - `userGoalsProvider` — reads the user's goals document (calorie goal,
///   current weight, goal weight). Note: currently reads from the `exercises`
///   collection with key `'goals'`, which may not match the `goals/{userId}`
///   document used by `userGoalsDataProvider` in the results feature.
library;

import 'package:fitness_app/core/providers/repository_providers.dart';
import 'package:fitness_app/features/authentication/presentation/providers/auth_providers.dart';
import 'package:fitness_app/features/workout/domain/entities/exercise.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final workoutProgramsProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.read(workoutRepositoryProvider);
  final result = await repo.getWorkoutPrograms();
  return result.fold((_) => [], (programs) => programs);
});

final workoutProgramProvider =
    FutureProvider.family<Map<String, dynamic>?, String>((ref, category) async {
  final repo = ref.read(workoutRepositoryProvider);
  final result = await repo.getWorkoutProgram(category);
  return result.fold((_) => null, (program) => program);
});

final exerciseHistoryProvider =
    FutureProvider<List<Exercise>>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repo = ref.read(workoutRepositoryProvider);
  final result = await repo.getExercises(userId: user.id);
  return result.fold((_) => [], (exercises) => exercises);
});

final userGoalsProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  final repo = ref.read(workoutRepositoryProvider);
  final result = await repo.getWorkoutProgram('goals');
  return result.fold((_) => null, (data) => data);
});
