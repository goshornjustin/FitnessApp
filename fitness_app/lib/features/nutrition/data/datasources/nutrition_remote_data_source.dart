/// Firestore + OpenFoodFacts data source for nutrition data.
///
/// Firestore collection layout:
/// - `{mealType}Items/{userId}/{YYYY-M-D}/` — documents per food entry per
///   meal per day (e.g. `breakfastItems/uid/2024-6-1/`).
/// - `userDailyMacros/{userId}/{YYYY-M-D}/totals` — running macro totals for
///   a given day.
/// - `userDailyMacroTotals/{userId}` — the user's target macros.
/// - `usersData/{userId}/recipes/` — user-created recipe documents.
///
/// Food search hits the OpenFoodFacts v3 API and returns per-serving macros.
/// Recipes are serialised/deserialised by the private `_recipeFromFirestore`
/// and `_recipeToFirestore` helpers at the bottom of the file.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_app/core/errors/exceptions.dart';
import 'package:fitness_app/features/nutrition/data/models/nutrition_entry_model.dart';
import 'package:fitness_app/features/nutrition/domain/entities/nutrition_entry.dart';
import 'package:fitness_app/features/nutrition/domain/entities/recipe.dart';
import 'package:fitness_app/features/nutrition/domain/entities/recipe_component.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:uuid/uuid.dart';

abstract class NutritionRemoteDataSource {
  Stream<List<NutritionEntryModel>> watchMealItems({
    required String userId,
    required DateTime date,
    required MealType mealType,
  });

  Future<void> addMealItem(NutritionEntryModel entry);

  Future<void> deleteMealItem({
    required String userId,
    required String entryId,
    required MealType mealType,
    required DateTime date,
  });

  Stream<Map<String, int>?> watchDailyMacros({
    required String userId,
    required DateTime date,
  });

  Future<void> saveDailyMacros({
    required String userId,
    required DateTime date,
    required int calories,
    required int protein,
    required int fat,
    required int carbs,
  });

  Future<void> updateDailyMacros({
    required String userId,
    required DateTime date,
    required int calories,
    required int protein,
    required int fat,
    required int carbs,
  });

  Future<Map<String, int>?> getMacroTargets(String userId);

  Future<void> saveMacroTargets({
    required String userId,
    required int calories,
    required int protein,
    required int fat,
    required int carbs,
  });

  Future<List<Recipe>> getRecipes(String userId);

  Future<void> addRecipe({required String userId, required Recipe recipe});

  Future<void> deleteRecipe({required String userId, required String recipeId});

  Future<List<Map<String, dynamic>>> searchFood(String query);
}

class NutritionRemoteDataSourceImpl implements NutritionRemoteDataSource {
  const NutritionRemoteDataSourceImpl({required this.firestore});

  final FirebaseFirestore firestore;

  String _dateKey(DateTime date) => '${date.year}-${date.month}-${date.day}';

  String _mealCollection(MealType mealType) => '${mealType.name}Items';

  @override
  Stream<List<NutritionEntryModel>> watchMealItems({
    required String userId,
    required DateTime date,
    required MealType mealType,
  }) {
    return firestore
        .collection(_mealCollection(mealType))
        .doc(userId)
        .collection(_dateKey(date))
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NutritionEntryModel.fromFirestore(
                  doc.data(),
                  id: doc.id,
                  userId: userId,
                  date: date,
                  mealType: mealType,
                ))
            .toList());
  }

  @override
  Future<void> addMealItem(NutritionEntryModel entry) async {
    try {
      await firestore
          .collection(_mealCollection(entry.mealType))
          .doc(entry.userId)
          .collection(_dateKey(entry.date))
          .doc()
          .set(entry.toFirestore());
    } catch (e) {
      throw const ServerException();
    }
  }

  @override
  Future<void> deleteMealItem({
    required String userId,
    required String entryId,
    required MealType mealType,
    required DateTime date,
  }) async {
    try {
      await firestore
          .collection(_mealCollection(mealType))
          .doc(userId)
          .collection(_dateKey(date))
          .doc(entryId)
          .delete();
    } catch (e) {
      throw const ServerException();
    }
  }

  @override
  Stream<Map<String, int>?> watchDailyMacros({
    required String userId,
    required DateTime date,
  }) {
    return firestore
        .collection('userDailyMacros')
        .doc(userId)
        .collection(_dateKey(date))
        .doc('totals')
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      final data = doc.data()!;
      return {
        'calories': (data['calories'] as num? ?? 0).toInt(),
        'protein': (data['protein'] as num? ?? 0).toInt(),
        'fat': (data['fat'] as num? ?? 0).toInt(),
        'carbs': (data['carbs'] as num? ?? 0).toInt(),
      };
    });
  }

  @override
  Future<void> saveDailyMacros({
    required String userId,
    required DateTime date,
    required int calories,
    required int protein,
    required int fat,
    required int carbs,
  }) async {
    try {
      await firestore
          .collection('userDailyMacros')
          .doc(userId)
          .collection(_dateKey(date))
          .doc('totals')
          .set({'calories': calories, 'protein': protein, 'fat': fat, 'carbs': carbs});
    } catch (e) {
      throw const ServerException();
    }
  }

  @override
  Future<void> updateDailyMacros({
    required String userId,
    required DateTime date,
    required int calories,
    required int protein,
    required int fat,
    required int carbs,
  }) async {
    try {
      await firestore
          .collection('userDailyMacros')
          .doc(userId)
          .collection(_dateKey(date))
          .doc('totals')
          .update({'calories': calories, 'protein': protein, 'fat': fat, 'carbs': carbs});
    } catch (e) {
      // If update fails (doc doesn't exist), try set
      await saveDailyMacros(
        userId: userId, date: date, calories: calories, protein: protein, fat: fat, carbs: carbs,
      );
    }
  }

  @override
  Future<Map<String, int>?> getMacroTargets(String userId) async {
    try {
      final doc = await firestore.collection('userDailyMacroTotals').doc(userId).get();
      if (!doc.exists || doc.data() == null) return null;
      final data = doc.data()!;
      return {
        'calories': (data['calories'] as num? ?? 0).toInt(),
        'protein': (data['protein'] as num? ?? 0).toInt(),
        'fat': (data['fat'] as num? ?? 0).toInt(),
        'carbs': (data['carbs'] as num? ?? 0).toInt(),
      };
    } catch (e) {
      throw const ServerException();
    }
  }

  @override
  Future<void> saveMacroTargets({
    required String userId,
    required int calories,
    required int protein,
    required int fat,
    required int carbs,
  }) async {
    try {
      await firestore
          .collection('userDailyMacroTotals')
          .doc(userId)
          .set({'calories': calories, 'protein': protein, 'fat': fat, 'carbs': carbs});
    } catch (e) {
      throw const ServerException();
    }
  }

  @override
  Future<List<Recipe>> getRecipes(String userId) async {
    try {
      final snapshot = await firestore
          .collection('usersData')
          .doc(userId)
          .collection('recipes')
          .get();
      return snapshot.docs.map((doc) => _recipeFromFirestore(doc.id, doc.data())).toList();
    } catch (e) {
      throw const ServerException();
    }
  }

  @override
  Future<void> addRecipe({required String userId, required Recipe recipe}) async {
    try {
      await firestore
          .collection('usersData')
          .doc(userId)
          .collection('recipes')
          .doc(recipe.id)
          .set(_recipeToFirestore(recipe));
    } catch (e) {
      throw const ServerException();
    }
  }

  @override
  Future<void> deleteRecipe({required String userId, required String recipeId}) async {
    try {
      await firestore
          .collection('usersData')
          .doc(userId)
          .collection('recipes')
          .doc(recipeId)
          .delete();
    } catch (e) {
      throw const ServerException();
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchFood(String query) async {
    try {
      const user = User(userId: '', password: '');
      final config = ProductSearchQueryConfiguration(
        parametersList: [SearchTerms(terms: [query])],
        version: ProductQueryVersion.v3,
        country: OpenFoodFactsCountry.USA,
        language: OpenFoodFactsLanguage.ENGLISH,
      );
      final result = await OpenFoodAPIClient.searchProducts(user, config);
      if (result.products == null) return [];
      return result.products!
          .map((p) => {
                'id': p.barcode ?? const Uuid().v4(),
                'name': p.productName ?? '',
                'calories': p.nutriments?.getValue(Nutrient.energyKCal, PerSize.serving) ?? 0.0,
                'protein': p.nutriments?.getValue(Nutrient.proteins, PerSize.serving) ?? 0.0,
                'fat': p.nutriments?.getValue(Nutrient.fat, PerSize.serving) ?? 0.0,
                'carbs': p.nutriments?.getValue(Nutrient.carbohydrates, PerSize.serving) ?? 0.0,
                'imageUrl': p.imageFrontUrl ?? '',
                'servingSize': p.servingSize ?? '',
                'product': p,
              })
          .toList();
    } catch (e) {
      throw const ServerException();
    }
  }

  Recipe _recipeFromFirestore(String id, Map<String, dynamic> data) {
    final componentsList = (data['components'] as List<dynamic>? ?? [])
        .map((c) => RecipeComponent(
              name: c['name'] as String? ?? '',
              quantity: c['quantity'] as String? ?? '',
              calories: (c['calories'] as num?)?.toDouble(),
              protein: (c['protein'] as num?)?.toDouble(),
              carbs: (c['carbs'] as num?)?.toDouble(),
              fat: (c['fat'] as num?)?.toDouble(),
            ))
        .toList();

    return Recipe(
      id: id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      cookingTime: (data['cookingTime'] as num? ?? 0).toInt(),
      components: componentsList,
      steps: (data['steps'] as List<dynamic>? ?? []).cast<String>(),
      createdBy: data['createdBy'] as String? ?? '',
      createdAt: data['createdAt'] != null
          ? DateTime.tryParse(data['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> _recipeToFirestore(Recipe recipe) {
    return {
      'title': recipe.title,
      'description': recipe.description,
      'imageUrl': recipe.imageUrl,
      'cookingTime': recipe.cookingTime,
      'components': recipe.components
          .map((c) => {
                'name': c.name,
                'quantity': c.quantity,
                'calories': c.calories,
                'protein': c.protein,
                'carbs': c.carbs,
                'fat': c.fat,
              })
          .toList(),
      'steps': recipe.steps,
      'createdBy': recipe.createdBy,
      'createdAt': recipe.createdAt.toIso8601String(),
    };
  }
}
