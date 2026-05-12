/// Domain entity representing an authenticated app user.
///
/// This is the pure Dart model used throughout the domain and presentation
/// layers. It has no Firebase or JSON dependencies — those live in
/// `UserModel` (the data layer). The router reads [User.age] and [User.name]
/// to detect an incomplete profile and redirect to `/profile/setup`.
///
/// All weights are stored in kilograms and heights in centimetres.
library;

import 'package:equatable/equatable.dart';

class User extends Equatable {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.age,
    required this.gender,
    required this.weight,
    required this.height,
    required this.activityLevel,
    required this.fitnessGoal,
    required this.goalReason,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String email;
  final int age;
  final String gender;
  final double weight; // in kg
  final double height; // in cm
  final String activityLevel;
  final String fitnessGoal;
  final String goalReason;
  final DateTime createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        age,
        gender,
        weight,
        height,
        activityLevel,
        fitnessGoal,
        goalReason,
        createdAt,
        updatedAt,
      ];

  User copyWith({
    String? id,
    String? name,
    String? email,
    int? age,
    String? gender,
    double? weight,
    double? height,
    String? activityLevel,
    String? fitnessGoal,
    String? goalReason,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      activityLevel: activityLevel ?? this.activityLevel,
      fitnessGoal: fitnessGoal ?? this.fitnessGoal,
      goalReason: goalReason ?? this.goalReason,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}