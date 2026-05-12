/// Riverpod providers that instantiate domain-layer use cases.
///
/// Each use case is a thin callable class that delegates to a repository.
/// Providing them via Riverpod means the UI can access them with
/// `ref.read(signInWithEmailProvider)` without knowing anything about
/// which repository implementation is backing them.
///
/// Grouped by feature: Authentication, Nutrition, Workout.
library;

import 'package:fitness_app/core/providers/repository_providers.dart';
import 'package:fitness_app/features/authentication/domain/usecases/sign_in_with_email.dart';
import 'package:fitness_app/features/authentication/domain/usecases/sign_out.dart';
import 'package:fitness_app/features/authentication/domain/usecases/sign_up_with_email.dart';
import 'package:fitness_app/features/nutrition/domain/usecases/add_nutrition_entry.dart';
import 'package:fitness_app/features/nutrition/domain/usecases/calculate_daily_nutrition.dart';
import 'package:fitness_app/features/nutrition/domain/usecases/search_food.dart';
import 'package:fitness_app/features/nutrition/domain/usecases/watch_nutrition_entries.dart';
import 'package:fitness_app/features/workout/domain/usecases/add_exercise.dart';
import 'package:fitness_app/features/workout/domain/usecases/get_exercises.dart';
import 'package:fitness_app/features/workout/domain/usecases/get_workout_programs.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// Authentication Use Cases
final signInWithEmailProvider = Provider<SignInWithEmail>((ref) {
  return SignInWithEmail(ref.read(authRepositoryProvider));
});

final signUpWithEmailProvider = Provider<SignUpWithEmail>((ref) {
  return SignUpWithEmail(ref.read(authRepositoryProvider));
});

final signOutProvider = Provider<SignOut>((ref) {
  return SignOut(ref.read(authRepositoryProvider));
});

// Nutrition Use Cases
final addNutritionEntryProvider = Provider<AddNutritionEntry>((ref) {
  return AddNutritionEntry(ref.read(nutritionRepositoryProvider));
});

final watchNutritionEntriesProvider = Provider<WatchNutritionEntries>((ref) {
  return WatchNutritionEntries(ref.read(nutritionRepositoryProvider));
});

final searchFoodProvider = Provider<SearchFood>((ref) {
  return SearchFood(ref.read(nutritionRepositoryProvider));
});

final calculateDailyNutritionProvider = Provider<CalculateDailyNutrition>((ref) {
  return const CalculateDailyNutrition();
});

// Workout Use Cases
final getWorkoutProgramsProvider = Provider<GetWorkoutPrograms>((ref) {
  return GetWorkoutPrograms(ref.read(workoutRepositoryProvider));
});

final getExercisesProvider = Provider<GetExercises>((ref) {
  return GetExercises(ref.read(workoutRepositoryProvider));
});

final addExerciseProvider = Provider<AddExercise>((ref) {
  return AddExercise(ref.read(workoutRepositoryProvider));
});
