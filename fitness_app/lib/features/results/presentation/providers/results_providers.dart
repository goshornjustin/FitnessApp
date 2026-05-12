/// Riverpod providers for the results / progress feature.
///
/// - `userGoalsDataProvider` — fetches the user's goal document from the
///   `goals/{userId}` Firestore collection (contains `calorieGoal`,
///   `currentWeight`, `goalWeight`).
/// - `exerciseHistoryDataProvider` — fetches the full
///   `workoutHistory/{userId}/dailyData` subcollection as a raw `QuerySnapshot`
///   so the results page can sum calories burned and list past sessions.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_app/core/providers/external_providers.dart';
import 'package:fitness_app/features/authentication/presentation/providers/auth_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final userGoalsDataProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  final firestore = ref.read(firestoreProvider);
  final doc = await firestore.collection('goals').doc(user.id).get();
  if (!doc.exists || doc.data() == null) return null;
  return doc.data();
});

final exerciseHistoryDataProvider =
    FutureProvider<QuerySnapshot<Map<String, dynamic>>?>((ref) async {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  final firestore = ref.read(firestoreProvider);
  return firestore
      .collection('workoutHistory')
      .doc(user.id)
      .collection('dailyData')
      .get();
});
