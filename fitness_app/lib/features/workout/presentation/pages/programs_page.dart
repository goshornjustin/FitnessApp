/// Workout programs browser page.
///
/// Fetches programs from Firestore via `workoutProgramsProvider`. If the
/// collection is empty, falls back to three hard-coded category cards
/// (Lower Body, Upper Body, Cardio) that each fetch their own Firestore
/// document via `workoutProgramProvider`. Each card expands to show the
/// exercise list with name, instructions, and duration.
///
/// On a Firestore error, `_StaticProgramsList` renders the three categories
/// without any exercise detail.
library;

import 'package:fitness_app/features/workout/presentation/providers/workout_providers.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProgramsPage extends ConsumerWidget {
  const ProgramsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programs = ref.watch(workoutProgramsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Programs')),
      body: programs.when(
        data: (list) {
          if (list.isEmpty) {
            return Column(
              children: [
                _CategoryCard(
                  title: 'Lower Body',
                  subtitle: 'Squats, Lunges & more',
                  color: const Color(0xFFE3F2FD),
                  category: 'lowerBody',
                  ref: ref,
                ),
                _CategoryCard(
                  title: 'Upper Body',
                  subtitle: 'Bench Press, Shoulder Press & more',
                  color: const Color(0xFFF3E5F5),
                  category: 'upperBody',
                  ref: ref,
                ),
                _CategoryCard(
                  title: 'Cardio',
                  subtitle: 'Treadmill, HIIT & more',
                  color: const Color(0xFFE8F5E9),
                  category: 'cardio',
                  ref: ref,
                ),
              ],
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final program = list[i];
              return Card(
                child: ListTile(
                  title: Text(program['title'] as String? ?? program['id'] as String? ?? 'Program'),
                  subtitle: Text(program['description'] as String? ?? ''),
                  trailing: const Icon(Icons.chevron_right),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => _StaticProgramsList(),
      ),
    );
  }
}

class _CategoryCard extends ConsumerWidget {
  const _CategoryCard({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.category,
    required this.ref,
  });

  final String title;
  final String subtitle;
  final Color color;
  final String category;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context, WidgetRef widgetRef) {
    final program = ref.watch(workoutProgramProvider(category));
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: color,
      child: program.when(
        data: (data) => _ProgramTile(
          title: title,
          subtitle: data != null
              ? (data['description'] as String? ?? subtitle)
              : subtitle,
          exercises: data != null
              ? (data['exercises'] as List<dynamic>? ?? [])
              : [],
        ),
        loading: () => ListTile(title: Text(title), subtitle: const LinearProgressIndicator()),
        error: (_, __) => _ProgramTile(title: title, subtitle: subtitle, exercises: const []),
      ),
    );
  }
}

class _ProgramTile extends StatelessWidget {
  const _ProgramTile({
    required this.title,
    required this.subtitle,
    required this.exercises,
  });

  final String title;
  final String subtitle;
  final List exercises;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      children: exercises.map<Widget>((e) {
        final ex = e as Map<String, dynamic>;
        return ListTile(
          dense: true,
          title: Text(ex['name'] as String? ?? ''),
          subtitle: Text(ex['instructions'] as String? ?? ''),
          trailing: Text('${ex['duration'] ?? ''} min'),
        );
      }).toList(),
    );
  }
}

class _StaticProgramsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(child: ListTile(title: Text('Lower Body'), subtitle: Text('Squats, Lunges & more'))),
        Card(child: ListTile(title: Text('Upper Body'), subtitle: Text('Bench Press, Shoulder Press & more'))),
        Card(child: ListTile(title: Text('Cardio'), subtitle: Text('Treadmill, HIIT & more'))),
      ],
    );
  }
}
