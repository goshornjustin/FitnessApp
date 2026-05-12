/// Modal bottom sheet for searching and logging a food item.
///
/// Shown when the user taps "Add {Meal}" in `DietPage`. Flow:
/// 1. User types a query → `foodSearchProvider` hits OpenFoodFacts.
/// 2. User taps a result → product detail + serving input appears.
/// 3. User taps "Add Item" → entry is written to Firestore and daily macro
///    totals are updated atomically using `updateDailyMacros`.
///
/// Requires `mealType`, `date`, and `userId` from the calling widget.
library;

import 'package:fitness_app/core/providers/repository_providers.dart';
import 'package:fitness_app/features/nutrition/domain/entities/nutrition_entry.dart';
import 'package:fitness_app/features/nutrition/presentation/providers/nutrition_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:uuid/uuid.dart';

class AddFoodPage extends HookConsumerWidget {
  const AddFoodPage({
    super.key,
    required this.mealType,
    required this.date,
    required this.userId,
  });

  final MealType mealType;
  final DateTime date;
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final query = useState('');
    final selectedProduct = useState<Map<String, dynamic>?>(null);
    final servings = useTextEditingController(text: '1');

    final searchResults = ref.watch(foodSearchProvider(query.value));

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Add to ${mealType.displayName}',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            if (selectedProduct.value == null) ...[
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search food...',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => query.value = searchController.text.trim(),
                  ),
                ),
                onSubmitted: (v) => query.value = v.trim(),
              ),
              const SizedBox(height: 8),
              if (query.value.isNotEmpty)
                searchResults.when(
                  data: (results) => SizedBox(
                    height: 250,
                    child: results.isEmpty
                        ? const Center(child: Text('No results found.'))
                        : ListView.builder(
                            itemCount: results.length,
                            itemBuilder: (_, i) {
                              final item = results[i];
                              return ListTile(
                                title: Text(item['name'] as String? ?? ''),
                                subtitle: Text(
                                    '${(item['calories'] as num).toStringAsFixed(0)} kcal/serving'),
                                onTap: () => selectedProduct.value = item,
                              );
                            },
                          ),
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const Text('Search failed.'),
                ),
            ] else ...[
              // Selected product detail
              ListTile(
                title: Text(selectedProduct.value!['name'] as String? ?? ''),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => selectedProduct.value = null,
                ),
              ),
              Row(children: [
                const Text('Servings: '),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: servings,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final product = selectedProduct.value!;
                    final count = double.tryParse(servings.text) ?? 1;
                    final calories = (product['calories'] as num).toDouble() * count;
                    final protein = (product['protein'] as num).toDouble() * count;
                    final fat = (product['fat'] as num).toDouble() * count;
                    final carbs = (product['carbs'] as num).toDouble() * count;

                    final entry = NutritionEntry(
                      id: const Uuid().v4(),
                      userId: userId,
                      foodName: product['name'] as String? ?? '',
                      date: date,
                      mealType: mealType,
                      quantity: count,
                      calories: calories,
                      protein: protein,
                      carbs: carbs,
                      fat: fat,
                      imageUrl: product['imageUrl'] as String?,
                    );

                    final repo = ref.read(nutritionRepositoryProvider);
                    await repo.addNutritionEntry(entry);

                    // Update daily macros
                    final dailyMacros = ref.read(dailyMacrosProvider).valueOrNull;
                    final newCalories = (dailyMacros?['calories'] ?? 0) + calories.round();
                    final newProtein = (dailyMacros?['protein'] ?? 0) + protein.round();
                    final newFat = (dailyMacros?['fat'] ?? 0) + fat.round();
                    final newCarbs = (dailyMacros?['carbs'] ?? 0) + carbs.round();

                    await repo.updateDailyMacros(
                      userId: userId,
                      date: date,
                      calories: newCalories,
                      protein: newProtein,
                      fat: newFat,
                      carbs: newCarbs,
                    );

                    if (context.mounted) context.pop();
                  },
                  child: const Text('Add Item'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
