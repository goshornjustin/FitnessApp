/// Domain entity representing a single logged exercise session.
///
/// Stores the calories burned and optionally duration, sets, reps, weight,
/// and free-text notes. The `date` field doubles as the Firestore document key
/// (formatted as `YYYY-M-D` by the data source).
///
/// [ExerciseType] classifies the workout category and provides a display name.
library;

import 'package:equatable/equatable.dart';

class Exercise extends Equatable {
  const Exercise({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.date,
    required this.caloriesBurned,
    this.duration,
    this.sets,
    this.reps,
    this.weight,
    this.notes,
  });

  final String id;
  final String userId;
  final String name;
  final ExerciseType type;
  final DateTime date;
  final int caloriesBurned;
  final int? duration; // in minutes
  final int? sets;
  final int? reps;
  final double? weight; // in kg
  final String? notes;

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        type,
        date,
        caloriesBurned,
        duration,
        sets,
        reps,
        weight,
        notes,
      ];

  Exercise copyWith({
    String? id,
    String? userId,
    String? name,
    ExerciseType? type,
    DateTime? date,
    int? caloriesBurned,
    int? duration,
    int? sets,
    int? reps,
    double? weight,
    String? notes,
  }) {
    return Exercise(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      date: date ?? this.date,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      duration: duration ?? this.duration,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      notes: notes ?? this.notes,
    );
  }
}

enum ExerciseType {
  cardio,
  strength,
  flexibility,
  sports,
  other;

  String get displayName {
    switch (this) {
      case ExerciseType.cardio:
        return 'Cardio';
      case ExerciseType.strength:
        return 'Strength';
      case ExerciseType.flexibility:
        return 'Flexibility';
      case ExerciseType.sports:
        return 'Sports';
      case ExerciseType.other:
        return 'Other';
    }
  }
}