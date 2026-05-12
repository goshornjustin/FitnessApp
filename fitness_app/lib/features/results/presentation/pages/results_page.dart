/// Results / progress page showing steps, calories burned, and workout history.
///
/// On init, requests Health permissions and fetches today's step count from
/// the platform health API (iOS HealthKit / Android Health Connect).
/// Displays:
/// - Steps card — live step count for the last 24 hours.
/// - Calories burned card — summed from `exerciseHistoryDataProvider`, shown
///   as a progress bar against the user's calorie goal.
/// - Current goal card — the user's fitness goal string from their profile.
/// - Workout history list — each past session with date and calories burned.
library;

import 'dart:io';

import 'package:fitness_app/features/authentication/presentation/providers/auth_providers.dart';
import 'package:fitness_app/features/results/presentation/providers/results_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';
import 'package:health/health.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

class ResultsPage extends ConsumerStatefulWidget {
  const ResultsPage({super.key});

  @override
  ConsumerState<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends ConsumerState<ResultsPage> {
  final Health _health = Health();
  int _steps = 0;

  @override
  void initState() {
    super.initState();
    _initHealth();
  }

  void _initHealth() async {
    try {
      _health.configure();
      if (Platform.isAndroid) {
        if (await Permission.activityRecognition.isGranted) {
          _fetchSteps();
        } else {
          await Permission.activityRecognition.request();
          _fetchSteps();
        }
      } else {
        final hasPerms = await _health.hasPermissions([HealthDataType.STEPS]);
        if (hasPerms != true) {
          await _health.requestAuthorization([HealthDataType.STEPS],
              permissions: [HealthDataAccess.READ]);
        }
        _fetchSteps();
      }
    } catch (_) {}
  }

  void _fetchSteps() async {
    try {
      final now = DateTime.now();
      final steps = await _health.getTotalStepsInInterval(
          now.subtract(const Duration(hours: 24)), now);
      if (mounted) setState(() => _steps = steps ?? 0);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final goalsAsync = ref.watch(userGoalsDataProvider);
    final exerciseAsync = ref.watch(exerciseHistoryDataProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Results')),
      body: goalsAsync.when(
        data: (goals) {
          final calorieGoal =
              goals != null ? (goals['calorieGoal'] as num?)?.toDouble() ?? 0 : 0.0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Steps card
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.directions_walk, color: Colors.blue),
                    title: const Text('Steps Today'),
                    trailing: Text('$_steps',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 16),
                // Calories burned
                if (calorieGoal > 0)
                  exerciseAsync.when(
                    data: (snap) {
                      double totalBurned = 0;
                      if (snap != null) {
                        for (final doc in snap.docs) {
                          totalBurned +=
                              (doc.data()['caloriesBurned'] as num? ?? 0)
                                  .toDouble();
                        }
                      }
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Calories Burned',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${totalBurned.toStringAsFixed(0)} cal',
                                      style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w900)),
                                  Text('of ${calorieGoal.toStringAsFixed(0)} cal'),
                                ],
                              ),
                              const SizedBox(height: 8),
                              FAProgressBar(
                                currentValue: totalBurned,
                                maxValue: calorieGoal,
                                progressColor: Colors.deepPurpleAccent,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                const SizedBox(height: 16),
                // Goal card
                if (user != null && user.fitnessGoal.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Current Goal',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 8),
                          Text(user.fitnessGoal,
                              style: const TextStyle(
                                  fontSize: 18, color: Colors.black54)),
                        ],
                      ),
                    ),
                  ),
                // Workout history
                if (exerciseAsync.hasValue &&
                    (exerciseAsync.value?.docs.isNotEmpty ?? false)) ...[
                  const SizedBox(height: 16),
                  const Text('Workout History',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  ...exerciseAsync.value!.docs.map((doc) => Card(
                        child: ListTile(
                          title: Text('Date: ${doc.id}'),
                          subtitle: Text(
                              'Weight: ${doc.data()['currentWeight']} kg'),
                          trailing: Text(
                              '${doc.data()['caloriesBurned']} cal burned'),
                        ),
                      )),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
