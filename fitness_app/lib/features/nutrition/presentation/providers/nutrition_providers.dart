/// Riverpod providers for the nutrition / diet feature.
///
/// - `selectedDateProvider` — the date currently viewed in the diet tab.
///   Changing it causes all meal and macro providers to re-fetch automatically.
/// - `mealEntriesProvider` — family stream of food entries for one meal type
///   on the selected date.
/// - `dailyMacrosProvider` — stream of the user's total consumed macros today.
/// - `macroTargetsProvider` — one-time fetch of the user's personalised macro
///   goals (set during profile setup).
/// - `foodSearchProvider` — family future that queries OpenFoodFacts; returns
///   `[]` immediately when the query string is empty.
/// - `savedRecipesProvider` — fetches the user's saved recipes.
/// - `addEntryProvider` — fire-and-forget action provider for adding an entry.
library;

import 'package:fitness_app/core/providers/repository_providers.dart';
import 'package:fitness_app/features/authentication/presentation/providers/auth_providers.dart';
import 'package:fitness_app/features/nutrition/domain/entities/nutrition_entry.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

// Selected date for the diet tab
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Selected food product from search
final selectedProductProvider = StateProvider<Product?>((ref) => null);

// Watch meal entries for a specific meal on selected date
final mealEntriesProvider =
    StreamProvider.family<List<NutritionEntry>, MealType>((ref, mealType) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  final date = ref.watch(selectedDateProvider);
  final repo = ref.read(nutritionRepositoryProvider);
  return repo
      .watchNutritionEntries(userId: user.id, date: date, mealType: mealType)
      .map((either) => either.fold((_) => [], (entries) => entries));
});

// Watch daily consumed macros
final dailyMacrosProvider = StreamProvider<Map<String, int>?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return const Stream.empty();
  final date = ref.watch(selectedDateProvider);
  final repo = ref.read(nutritionRepositoryProvider);
  return repo
      .watchDailyMacros(userId: user.id, date: date)
      .map((either) => either.fold((_) => null, (macros) => macros));
});

// Fetch macro targets
final macroTargetsProvider = FutureProvider<Map<String, int>?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  final repo = ref.read(nutritionRepositoryProvider);
  final result = await repo.getMacroTargets(user.id);
  return result.fold((_) => null, (targets) => targets);
});

// Food search results
final foodSearchProvider =
    FutureProvider.family<List<Map<String, dynamic>>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final repo = ref.read(nutritionRepositoryProvider);
  final result = await repo.searchFood(query);
  return result.fold((_) => [], (results) => results);
});

// Saved recipes
final savedRecipesProvider = FutureProvider((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return [];
  final repo = ref.read(nutritionRepositoryProvider);
  final result = await repo.getRecipes(user.id);
  return result.fold((_) => [], (recipes) => recipes);
});

// Add nutrition entry action
final addEntryProvider =
    Provider.family<Future<void>, NutritionEntry>((ref, entry) async {
  final repo = ref.read(nutritionRepositoryProvider);
  await repo.addNutritionEntry(entry);
});
