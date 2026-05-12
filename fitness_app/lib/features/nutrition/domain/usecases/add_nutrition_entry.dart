/// Use case: log a food item to a specific meal on a given date.
///
/// `AddNutritionEntryParams` builds the `NutritionEntry` internally and
/// generates a UUID for `id`, so callers only need to supply the food data.
/// After calling this, also call `updateDailyMacros` on the repository to
/// keep the running daily totals in sync (see `AddFoodPage` for the pattern).
library;

import 'package:equatable/equatable.dart';
import 'package:fitness_app/core/errors/failures.dart';
import 'package:fitness_app/core/usecases/usecase.dart';
import 'package:fitness_app/features/nutrition/domain/entities/nutrition_entry.dart';
import 'package:fitness_app/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';

class AddNutritionEntry implements UseCase<void, AddNutritionEntryParams> {
  const AddNutritionEntry(this.repository);

  final NutritionRepository repository;

  @override
  Future<Either<Failure, void>> call(AddNutritionEntryParams params) {
    return repository.addNutritionEntry(params.entry);
  }
}

class AddNutritionEntryParams extends Equatable {
  AddNutritionEntryParams({
    required this.userId,
    required this.foodName,
    required this.date,
    required this.mealType,
    required this.quantity,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.barcode,
    this.imageUrl,
  }) : entry = NutritionEntry(
          id: const Uuid().v4(),
          userId: userId,
          foodName: foodName,
          date: date,
          mealType: mealType,
          quantity: quantity,
          calories: calories,
          protein: protein,
          carbs: carbs,
          fat: fat,
          barcode: barcode,
          imageUrl: imageUrl,
        );

  final String userId;
  final String foodName;
  final DateTime date;
  final MealType mealType;
  final double quantity;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final String? barcode;
  final String? imageUrl;
  final NutritionEntry entry;

  @override
  List<Object?> get props => [userId, foodName, date, mealType];
}
