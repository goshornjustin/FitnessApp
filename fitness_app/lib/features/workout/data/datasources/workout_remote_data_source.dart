/// Firestore data source for workout programs and exercise history.
///
/// Firestore layout:
/// - `exercises/{category}` — workout program documents (lower/upper/cardio).
///   Each contains a `description` string and an `exercises` array.
/// - `workoutHistory/{userId}/dailyData/{YYYY-M-D}` — one document per
///   session storing `caloriesBurned` and `currentWeight`.
/// - `goals/{userId}` — user goal document with `calorieGoal`, `currentWeight`,
///   `goalWeight`.
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitness_app/core/errors/exceptions.dart';

abstract class WorkoutRemoteDataSource {
  Stream<List<Map<String, dynamic>>> watchExercises({
    required String userId,
    DateTime? date,
  });

  Future<void> addExercise({
    required String userId,
    required DateTime date,
    required double caloriesBurned,
    required double currentWeight,
  });

  Future<List<Map<String, dynamic>>> getWorkoutPrograms();

  Future<Map<String, dynamic>?> getWorkoutProgram(String category);

  Future<List<Map<String, dynamic>>> getExerciseHistory(String userId);

  Future<Map<String, dynamic>?> getUserGoals(String userId);

  Future<void> saveUserGoals({
    required String userId,
    required int calorieGoal,
    required double currentWeight,
    required double goalWeight,
  });

  Future<void> saveExerciseData({
    required String userId,
    required DateTime date,
    required double caloriesBurned,
    required double currentWeight,
  });
}

class WorkoutRemoteDataSourceImpl implements WorkoutRemoteDataSource {
  const WorkoutRemoteDataSourceImpl({required this.firestore});

  final FirebaseFirestore firestore;

  String _dateKey(DateTime date) => '${date.year}-${date.month}-${date.day}';

  @override
  Stream<List<Map<String, dynamic>>> watchExercises({
    required String userId,
    DateTime? date,
  }) {
    return firestore
        .collection('workoutHistory')
        .doc(userId)
        .collection('dailyData')
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => {'id': doc.id, ...doc.data()})
            .toList());
  }

  @override
  Future<void> addExercise({
    required String userId,
    required DateTime date,
    required double caloriesBurned,
    required double currentWeight,
  }) async {
    try {
      await firestore
          .collection('workoutHistory')
          .doc(userId)
          .collection('dailyData')
          .doc(_dateKey(date))
          .set({'caloriesBurned': caloriesBurned, 'currentWeight': currentWeight});
    } catch (e) {
      throw const ServerException();
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getWorkoutPrograms() async {
    try {
      final snap = await firestore.collection('exercises').get();
      return snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      throw const ServerException();
    }
  }

  @override
  Future<Map<String, dynamic>?> getWorkoutProgram(String category) async {
    try {
      final doc = await firestore.collection('exercises').doc(category).get();
      if (!doc.exists || doc.data() == null) return null;
      return {'id': doc.id, ...doc.data()!};
    } catch (e) {
      throw const ServerException();
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getExerciseHistory(String userId) async {
    try {
      final snap = await firestore
          .collection('workoutHistory')
          .doc(userId)
          .collection('dailyData')
          .get();
      return snap.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {
      throw const ServerException();
    }
  }

  @override
  Future<Map<String, dynamic>?> getUserGoals(String userId) async {
    try {
      final doc = await firestore.collection('goals').doc(userId).get();
      if (!doc.exists || doc.data() == null) return null;
      return doc.data();
    } catch (e) {
      throw const ServerException();
    }
  }

  @override
  Future<void> saveUserGoals({
    required String userId,
    required int calorieGoal,
    required double currentWeight,
    required double goalWeight,
  }) async {
    try {
      await firestore.collection('goals').doc(userId).set({
        'calorieGoal': calorieGoal,
        'currentWeight': currentWeight,
        'goalWeight': goalWeight,
      });
    } catch (e) {
      throw const ServerException();
    }
  }

  @override
  Future<void> saveExerciseData({
    required String userId,
    required DateTime date,
    required double caloriesBurned,
    required double currentWeight,
  }) async {
    try {
      await firestore
          .collection('workoutHistory')
          .doc(userId)
          .collection('dailyData')
          .doc(_dateKey(date))
          .set({'caloriesBurned': caloriesBurned, 'currentWeight': currentWeight});
    } catch (e) {
      throw const ServerException();
    }
  }
}
