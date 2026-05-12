/// Read-only profile page showing the user's body stats and fitness goals.
///
/// Displays the current user from `currentUserProvider`. If the user is null
/// (loading), shows a spinner. Includes a "Sign Out" action in the app bar
/// that calls `profileSignOutProvider`.
library;

import 'package:fitness_app/features/authentication/presentation/providers/auth_providers.dart';
import 'package:fitness_app/features/profile/presentation/providers/profile_providers.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          TextButton(
            onPressed: () => ref.read(profileSignOutProvider),
            child: const Text('Sign Out'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: CircleAvatar(
              radius: 48,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                style: const TextStyle(fontSize: 36),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(user.name, style: Theme.of(context).textTheme.headlineSmall),
          ),
          Center(child: Text(user.email, style: Theme.of(context).textTheme.bodySmall)),
          const SizedBox(height: 24),
          _Section('Body Stats', [
            _Row('Age', '${user.age}'),
            _Row('Gender', user.gender),
            _Row('Weight', '${user.weight} kg'),
            _Row('Height', '${user.height} cm'),
          ]),
          const SizedBox(height: 16),
          _Section('Goals', [
            _Row('Activity Level', user.activityLevel),
            _Row('Fitness Goal', user.fitnessGoal),
            _Row('Reason', user.goalReason),
          ]),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.title, this.rows);
  final String title;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const Divider(),
            ...rows,
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value);
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
          Text(value.isEmpty ? '—' : value),
        ],
      ),
    );
  }
}
