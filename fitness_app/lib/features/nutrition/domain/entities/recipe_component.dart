/// Domain entity for a single ingredient within a `Recipe`.
///
/// `quantity` is a free-form string (e.g. `"1 cup"`, `"200g"`) rather than a
/// numeric value to accommodate varied measurement formats. Macro fields are
/// optional because not all ingredients have known nutrition data.
library;

import 'package:equatable/equatable.dart';

class RecipeComponent extends Equatable {
  const RecipeComponent({
    required this.name,
    required this.quantity,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
  });

  final String name;
  final String quantity; // e.g., "1 cup", "200g"
  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fat;

  @override
  List<Object?> get props => [
        name,
        quantity,
        calories,
        protein,
        carbs,
        fat,
      ];

  RecipeComponent copyWith({
    String? name,
    String? quantity,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
  }) {
    return RecipeComponent(
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      carbs: carbs ?? this.carbs,
      fat: fat ?? this.fat,
    );
  }
}