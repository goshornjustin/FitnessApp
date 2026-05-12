/// 4-step onboarding wizard for new users to complete their profile.
///
/// Shown automatically by the router when `user.age == 0` or `user.name` is
/// empty. Uses a `PageView` with `NeverScrollableScrollPhysics` so the user
/// can only advance via the "Next" buttons (or go back via the AppBar arrow).
///
/// Pages in order:
/// 1. `_BasicInfoPage` — name, gender, age, weight, height.
/// 2. `_ActivityGoalPage` — activity level and fitness goal (lose/gain weight).
/// 3. `_GoalReasonPage` — reason for the chosen goal.
/// 4. `_SummaryPage` — review inputs, see calculated macros, and save.
///
/// On save, writes the profile to Firestore AND saves macro targets, then
/// navigates to `/`.
library;

import 'package:fitness_app/core/providers/repository_providers.dart';
import 'package:fitness_app/features/authentication/presentation/providers/auth_providers.dart';
import 'package:fitness_app/features/profile/presentation/providers/profile_providers.dart';
import 'package:fitness_app/shared/utils/calculations/calculations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProfileSetupPage extends HookConsumerWidget {
  const ProfileSetupPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageController = usePageController();
    final currentPage = useState(0);

    void nextPage() {
      if (currentPage.value < 3) {
        pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        currentPage.value++;
      }
    }

    void prevPage() {
      if (currentPage.value > 0) {
        pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        currentPage.value--;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Setup (${currentPage.value + 1}/4)'),
        leading: currentPage.value > 0
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: prevPage)
            : null,
      ),
      body: PageView(
        controller: pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _BasicInfoPage(onNext: nextPage),
          _ActivityGoalPage(onNext: nextPage),
          _GoalReasonPage(onNext: nextPage),
          _SummaryPage(),
        ],
      ),
    );
  }
}

class _BasicInfoPage extends HookConsumerWidget {
  const _BasicInfoPage({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(profileSetupProvider.notifier);
    final setup = ref.watch(profileSetupProvider);
    final nameController = useTextEditingController(text: setup.name);

    const genders = ['Male', 'Female'];
    const ages = [18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
      31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45,
      46, 47, 48, 49, 50, 55, 60, 65, 70, 75, 80];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Let's start with some basic info.",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Name / Nickname',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => notifier.update((s) => s.copyWith(name: v)),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: setup.gender.isEmpty ? null : setup.gender,
            decoration: const InputDecoration(
              labelText: 'Gender',
              border: OutlineInputBorder(),
            ),
            items: genders
                .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                .toList(),
            onChanged: (v) => notifier.update((s) => s.copyWith(gender: v)),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            value: setup.age == 0 ? null : setup.age,
            decoration: const InputDecoration(
              labelText: 'Age',
              border: OutlineInputBorder(),
            ),
            items: ages
                .map((a) => DropdownMenuItem(value: a, child: Text('$a')))
                .toList(),
            onChanged: (v) => notifier.update((s) => s.copyWith(age: v)),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Weight (kg)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => notifier
                    .update((s) => s.copyWith(weightKg: double.tryParse(v) ?? s.weightKg)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Height (cm)',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => notifier
                    .update((s) => s.copyWith(heightCm: double.tryParse(v) ?? s.heightCm)),
              ),
            ),
          ]),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: setup.name.isNotEmpty && setup.gender.isNotEmpty && setup.age > 0
                  ? onNext
                  : null,
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityGoalPage extends HookConsumerWidget {
  const _ActivityGoalPage({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(profileSetupProvider.notifier);
    final setup = ref.watch(profileSetupProvider);

    const activities = [
      'Sedentary Lifestyle',
      'Slighty Active Lifestlye',
      'Moderately Active Lifestyle',
      'Active Lifestyle',
      'Very Active Lifestyle',
    ];
    const goals = ['Lose Weight', 'Gain Weight'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Activity & Goal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          const Text('What is your baseline activity level?'),
          const SizedBox(height: 8),
          ...activities.asMap().entries.map((e) => RadioListTile<String>(
                title: Text(e.value),
                value: e.value,
                groupValue: setup.activityLevel,
                onChanged: (v) => notifier.update((s) => s.copyWith(activityLevel: v)),
              )),
          const SizedBox(height: 16),
          const Text('What is your goal?'),
          const SizedBox(height: 8),
          ...goals.map((g) => RadioListTile<String>(
                title: Text(g),
                value: g,
                groupValue: setup.fitnessGoal,
                onChanged: (v) => notifier.update((s) => s.copyWith(fitnessGoal: v)),
              )),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed:
                  setup.activityLevel.isNotEmpty && setup.fitnessGoal.isNotEmpty ? onNext : null,
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalReasonPage extends HookConsumerWidget {
  const _GoalReasonPage({required this.onNext});
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(profileSetupProvider.notifier);
    final setup = ref.watch(profileSetupProvider);

    final loseReasons = [
      'Lack of time', 'Did not enjoy healthier food', 'Difficult to make food choices',
      'Social eating and events', 'Food cravings', 'Lack of progress',
    ];
    final gainReasons = [
      'Competitive sport performance', 'Gain muscle for general fitness',
      'I am underweight', 'My healthcare provider suggested it', 'Other',
    ];
    final reasons = setup.fitnessGoal == 'Lose Weight' ? loseReasons : gainReasons;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('What is your main reason?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...reasons.map((r) => RadioListTile<String>(
                title: Text(r),
                value: r,
                groupValue: setup.goalReason,
                onChanged: (v) => notifier.update((s) => s.copyWith(goalReason: v)),
              )),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: setup.goalReason.isNotEmpty ? onNext : null,
              child: const Text('Next'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryPage extends ConsumerWidget {
  const _SummaryPage();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final setup = ref.watch(profileSetupProvider);
    final isLoading = ref.watch(profileLoadingProvider);

    final calc = Calculations();
    final calories = calc.calculateDailyCalorieIntake(
      setup.age, setup.gender, setup.weightKg.round(),
      setup.heightCm, setup.activityLevel, setup.fitnessGoal,
    );
    final protein = calc.calculateDvProtein(calories, setup.fitnessGoal);
    final fat = calc.calculateDvFat(calories, setup.fitnessGoal);
    final carbs = calc.calculateDvCarbs(calories, setup.fitnessGoal);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _InfoRow('Name', setup.name),
          _InfoRow('Age', '${setup.age}'),
          _InfoRow('Gender', setup.gender),
          _InfoRow('Weight', '${setup.weightKg} kg'),
          _InfoRow('Height', '${setup.heightCm} cm'),
          _InfoRow('Activity', setup.activityLevel),
          _InfoRow('Goal', setup.fitnessGoal),
          _InfoRow('Reason', setup.goalReason),
          const Divider(height: 32),
          const Text('Recommended Daily Macros',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _MacroChip('Calories', '$calories'),
            _MacroChip('Protein', '${protein}g'),
            _MacroChip('Fat', '${fat}g'),
            _MacroChip('Carbs', '${carbs}g'),
          ]),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      ref.read(profileLoadingProvider.notifier).state = true;
                      try {
                        await ref.read(saveProfileProvider(setup));
                        // Also save macro targets
                        final nutritionRepo =
                            ref.read(nutritionRepositoryProvider);
                        final user = ref.read(currentUserProvider);
                        if (user != null) {
                          await nutritionRepo.saveMacroTargets(
                            userId: user.id,
                            calories: calories,
                            protein: protein,
                            fat: fat,
                            carbs: carbs,
                          );
                        }
                        if (context.mounted) context.go('/');
                      } finally {
                        ref.read(profileLoadingProvider.notifier).state = false;
                      }
                    },
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Save & Continue'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  const _MacroChip(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}
