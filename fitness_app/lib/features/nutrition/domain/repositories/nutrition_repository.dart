/// Abstract contract for all nutrition data operations.
///
/// Covers four concerns:
/// 1. **Meal entries** — add, delete, one-time fetch, and real-time stream of
///    logged food items per user/date/meal type.
/// 2. **Daily macro totals** — real-time stream and save/update of the running
///    calorie/macro sum consumed on a given date.
/// 3. **Macro targets** — the user's personalised daily goals (calculated from
///    their profile and stored in Firestore).
/// 4. **Recipes** — CRUD for user-created recipes.
/// 5. **Food search** — queries the OpenFoodFacts API and returns raw maps
///    containing name, calories, macros, and image URL.
library;

import 'package:fitness_app/core/errors/failures.dart';
import 'package:fitness_app/features/nutrition/domain/entities/nutrition_entry.dart';
import 'package:fitness_app/features/nutrition/domain/entities/recipe.dart';
import 'package:fpdart/fpdart.dart';

abstract class NutritionRepository {
  // Meal entries
  Future<Either<Failure, List<NutritionEntry>>> getNutritionEntries({
    required String userId,
    required DateTime date,
  });

  Future<Either<Failure, void>> addNutritionEntry(NutritionEntry entry);

  Future<Either<Failure, void>> deleteNutritionEntry({
    required String userId,
    required String entryId,
    required MealType mealType,
    required DateTime date,
  });

  Stream<Either<Failure, List<NutritionEntry>>> watchNutritionEntries({
    required String userId,
    required DateTime date,
    required MealType mealType,
  });

  // Daily macro totals (consumed today)
  Stream<Either<Failure, Map<String, int>?>> watchDailyMacros({
    required String userId,
    required DateTime date,
  });

  Future<Either<Failure, void>> saveDailyMacros({
    required String userId,
    required DateTime date,
    required int calories,
    required int protein,
    required int fat,
    required int carbs,
  });

  Future<Either<Failure, void>> updateDailyMacros({
    required String userId,
    required DateTime date,
    required int calories,
    required int protein,
    required int fat,
    required int carbs,
  });

  // Macro targets (calculated from user profile)
  Future<Either<Failure, Map<String, int>?>> getMacroTargets(String userId);

  Future<Either<Failure, void>> saveMacroTargets({
    required String userId,
    required int calories,
    required int protein,
    required int fat,
    required int carbs,
  });

  // Recipes
  Future<Either<Failure, List<Recipe>>> getRecipes(String userId);

  Future<Either<Failure, void>> addRecipe(Recipe recipe);

  Future<Either<Failure, void>> deleteRecipe({
    required String userId,
    required String recipeId,
  });

  // Food search (OpenFoodFacts)
  Future<Either<Failure, List<Map<String, dynamic>>>> searchFood(String query);
}
