/// Domain entity representing a user-created recipe.
///
/// A [Recipe] is composed of [RecipeComponent] items (ingredients with
/// optional macro data), a list of step strings, and metadata such as
/// cooking time and the ID of the user who created it.
///
/// Stored per-user in Firestore under `usersData/{userId}/recipes`.
library;

import 'package:equatable/equatable.dart';
import 'package:fitness_app/features/nutrition/domain/entities/recipe_component.dart';

class Recipe extends Equatable {
  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.cookingTime,
    required this.components,
    required this.steps,
    required this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final int cookingTime; // in minutes
  final List<RecipeComponent> components;
  final List<String> steps;
  final String createdBy; // user ID
  final DateTime createdAt;

  @override
  List<Object> get props => [
        id,
        title,
        description,
        imageUrl,
        cookingTime,
        components,
        steps,
        createdBy,
        createdAt,
      ];

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    int? cookingTime,
    List<RecipeComponent>? components,
    List<String>? steps,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      cookingTime: cookingTime ?? this.cookingTime,
      components: components ?? this.components,
      steps: steps ?? this.steps,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}