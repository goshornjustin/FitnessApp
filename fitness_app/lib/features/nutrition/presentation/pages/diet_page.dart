/// Daily diet tracking page.
///
/// Shows a tabbed view (Breakfast / Lunch / Dinner / Snacks) with a date
/// navigator at the top and a macro summary bar below it. Each tab is a
/// `_MealTabView` that streams entries from Firestore in real time.
///
/// Tapping "Add {Meal}" opens `AddFoodPage` in a modal bottom sheet.
/// The macro bar compares consumed macros (`dailyMacrosProvider`) against the
/// user's personalised targets (`macroTargetsProvider`).
library;

import 'package:fitness_app/features/authentication/presentation/providers/auth_providers.dart';
import 'package:fitness_app/features/nutrition/domain/entities/nutrition_entry.dart';
import 'package:fitness_app/features/nutrition/presentation/pages/add_food_page.dart';
import 'package:fitness_app/features/nutrition/presentation/providers/nutrition_providers.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DietPage extends ConsumerWidget {
  const DietPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final macroTargets = ref.watch(macroTargetsProvider);
    final dailyMacros = ref.watch(dailyMacrosProvider);
    final selectedDate = ref.watch(selectedDateProvider);

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Daily Diet'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Breakfast'),
              Tab(text: 'Lunch'),
              Tab(text: 'Dinner'),
              Tab(text: 'Snacks'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Date selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () => ref.read(selectedDateProvider.notifier).state =
                        selectedDate.subtract(const Duration(days: 1)),
                  ),
                  Text(
                    '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: () => ref.read(selectedDateProvider.notifier).state =
                        selectedDate.add(const Duration(days: 1)),
                  ),
                ],
              ),
            ),
            // Macro summary bar
            macroTargets.when(
              data: (targets) => _MacroBar(targets: targets, dailyMacros: dailyMacros),
              loading: () => const SizedBox(height: 48, child: LinearProgressIndicator()),
              error: (_, __) => const SizedBox.shrink(),
            ),
            // Meal tabs
            const Expanded(
              child: TabBarView(
                children: [
                  _MealTabView(mealType: MealType.breakfast),
                  _MealTabView(mealType: MealType.lunch),
                  _MealTabView(mealType: MealType.dinner),
                  _MealTabView(mealType: MealType.snack),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroBar extends ConsumerWidget {
  const _MacroBar({required this.targets, required this.dailyMacros});
  final Map<String, int>? targets;
  final AsyncValue<Map<String, int>?> dailyMacros;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final consumed = dailyMacros.valueOrNull;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MacroCol('Calories',
              consumed?['calories'] ?? 0, targets?['calories'] ?? 0),
          _MacroCol('Protein',
              consumed?['protein'] ?? 0, targets?['protein'] ?? 0),
          _MacroCol('Fat', consumed?['fat'] ?? 0, targets?['fat'] ?? 0),
          _MacroCol('Carbs', consumed?['carbs'] ?? 0, targets?['carbs'] ?? 0),
        ],
      ),
    );
  }
}

class _MacroCol extends StatelessWidget {
  const _MacroCol(this.label, this.consumed, this.target);
  final String label;
  final int consumed;
  final int target;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        Text('$consumed', style: const TextStyle(fontWeight: FontWeight.bold)),
        if (target > 0)
          Text('/ $target', style: const TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}

class _MealTabView extends ConsumerWidget {
  const _MealTabView({required this.mealType});
  final MealType mealType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(mealEntriesProvider(mealType));
    final user = ref.watch(currentUserProvider);
    final date = ref.watch(selectedDateProvider);

    return entries.when(
      data: (items) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: Text('Add ${mealType.displayName}'),
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => AddFoodPage(
                    mealType: mealType,
                    date: date,
                    userId: user?.id ?? '',
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('No items added yet.'))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final entry = items[i];
                      return ListTile(
                        title: Text(entry.foodName),
                        subtitle: Text('${entry.quantity.toInt()} serving(s)'),
                        trailing: Text('${entry.calories.toInt()} cal'),
                      );
                    },
                  ),
          ),
        ],
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}
