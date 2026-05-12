/// Concrete implementation of `NutritionRepository`.
///
/// Delegates all calls to `NutritionRemoteDataSource` and maps
/// `ServerException` to `ServerFailure`. There is currently no local cache
/// fallback — all reads go to Firestore.
///
/// `addNutritionEntry` generates a UUID if the entry's `id` is empty,
/// which is the normal path when adding new items from the UI.
library;

import 'package:fitness_app/core/errors/exceptions.dart';
import 'package:fitness_app/core/errors/failures.dart';
import 'package:fitness_app/features/nutrition/data/datasources/nutrition_remote_data_source.dart';
import 'package:fitness_app/features/nutrition/data/models/nutrition_entry_model.dart';
import 'package:fitness_app/features/nutrition/domain/entities/nutrition_entry.dart';
import 'package:fitness_app/features/nutrition/domain/entities/recipe.dart';
import 'package:fitness_app/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

class NutritionRepositoryImpl implements NutritionRepository {
  const NutritionRepositoryImpl({required this.remoteDataSource});

  final NutritionRemoteDataSource remoteDataSource;

  @override
  Future<Either<Failure, List<NutritionEntry>>> getNutritionEntries({
    required String userId,
    required DateTime date,
  }) async {
    try {
      final results = await Future.wait(MealType.values.map((meal) => remoteDataSource
          .watchMealItems(userId: userId, date: date, mealType: meal)
          .first));
      return Right(results.expand((list) => list).toList());
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addNutritionEntry(NutritionEntry entry) async {
    try {
      final model = NutritionEntryModel(
        id: entry.id.isEmpty ? const Uuid().v4() : entry.id,
        userId: entry.userId,
        foodName: entry.foodName,
        date: entry.date,
        mealType: entry.mealType,
        quantity: entry.quantity,
        calories: entry.calories,
        protein: entry.protein,
        carbs: entry.carbs,
        fat: entry.fat,
        barcode: entry.barcode,
        imageUrl: entry.imageUrl,
      );
      await remoteDataSource.addMealItem(model);
      return const Right(null);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteNutritionEntry({
    required String userId,
    required String entryId,
    required MealType mealType,
    required DateTime date,
  }) async {
    try {
      await remoteDataSource.deleteMealItem(
        userId: userId, entryId: entryId, mealType: mealType, date: date,
      );
      return const Right(null);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Stream<Either<Failure, List<NutritionEntry>>> watchNutritionEntries({
    required String userId,
    required DateTime date,
    required MealType mealType,
  }) {
    try {
      return remoteDataSource
          .watchMealItems(userId: userId, date: date, mealType: mealType)
          .map<Either<Failure, List<NutritionEntry>>>((entries) => Right(entries));
    } on ServerException {
      return Stream.value(const Left(ServerFailure()));
    }
  }

  @override
  Stream<Either<Failure, Map<String, int>?>> watchDailyMacros({
    required String userId,
    required DateTime date,
  }) {
    try {
      return remoteDataSource
          .watchDailyMacros(userId: userId, date: date)
          .map<Either<Failure, Map<String, int>?>>((macros) => Right(macros));
    } on ServerException {
      return Stream.value(const Left(ServerFailure()));
    }
  }

  @override
  Future<Either<Failure, void>> saveDailyMacros({
    required String userId,
    required DateTime date,
    required int calories,
    required int protein,
    required int fat,
    required int carbs,
  }) async {
    try {
      await remoteDataSource.saveDailyMacros(
        userId: userId, date: date, calories: calories, protein: protein, fat: fat, carbs: carbs,
      );
      return const Right(null);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> updateDailyMacros({
    required String userId,
    required DateTime date,
    required int calories,
    required int protein,
    required int fat,
    required int carbs,
  }) async {
    try {
      await remoteDataSource.updateDailyMacros(
        userId: userId, date: date, calories: calories, protein: protein, fat: fat, carbs: carbs,
      );
      return const Right(null);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, int>?>> getMacroTargets(String userId) async {
    try {
      final targets = await remoteDataSource.getMacroTargets(userId);
      return Right(targets);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> saveMacroTargets({
    required String userId,
    required int calories,
    required int protein,
    required int fat,
    required int carbs,
  }) async {
    try {
      await remoteDataSource.saveMacroTargets(
        userId: userId, calories: calories, protein: protein, fat: fat, carbs: carbs,
      );
      return const Right(null);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Recipe>>> getRecipes(String userId) async {
    try {
      final recipes = await remoteDataSource.getRecipes(userId);
      return Right(recipes);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> addRecipe(Recipe recipe) async {
    try {
      await remoteDataSource.addRecipe(userId: recipe.createdBy, recipe: recipe);
      return const Right(null);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> deleteRecipe({
    required String userId,
    required String recipeId,
  }) async {
    try {
      await remoteDataSource.deleteRecipe(userId: userId, recipeId: recipeId);
      return const Right(null);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> searchFood(String query) async {
    try {
      final results = await remoteDataSource.searchFood(query);
      return Right(results);
    } on ServerException {
      return const Left(ServerFailure());
    }
  }
}
