/// Data-layer model for `NutritionEntry` with Firestore serialisation.
///
/// Extends the domain entity and adds `fromFirestore` / `toFirestore` methods.
/// Note that Firestore stores quantity as `count` (integer servings) and
/// macros as integers — fractional values are rounded on write.
/// The `id`, `userId`, `date`, and `mealType` are not stored inside the
/// document itself; they come from the Firestore document path.
library;

import 'package:fitness_app/features/nutrition/domain/entities/nutrition_entry.dart';

class NutritionEntryModel extends NutritionEntry {
  const NutritionEntryModel({
    required super.id,
    required super.userId,
    required super.foodName,
    required super.date,
    required super.mealType,
    required super.quantity,
    required super.calories,
    required super.protein,
    required super.carbs,
    required super.fat,
    super.barcode,
    super.imageUrl,
  });

  factory NutritionEntryModel.fromFirestore(
    Map<String, dynamic> json, {
    required String id,
    required String userId,
    required DateTime date,
    required MealType mealType,
  }) {
    return NutritionEntryModel(
      id: id,
      userId: userId,
      foodName: json['name'] as String? ?? '',
      date: date,
      mealType: mealType,
      quantity: (json['count'] as num? ?? 1).toDouble(),
      calories: (json['calories'] as num? ?? 0).toDouble(),
      protein: (json['protein'] as num? ?? 0).toDouble(),
      carbs: (json['carbs'] as num? ?? 0).toDouble(),
      fat: (json['fat'] as num? ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': foodName,
      'count': quantity.toInt(),
      'calories': calories.toInt(),
      'protein': protein.toInt(),
      'carbs': carbs.toInt(),
      'fat': fat.toInt(),
    };
  }
}
