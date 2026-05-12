/// Use case: stream logged food entries for a specific meal on a given date.
///
/// Returns a `Stream<Either<Failure, List<NutritionEntry>>>` that stays live
/// and emits a new list whenever entries are added or removed in Firestore.
/// Used by `mealEntriesProvider` to keep the diet tab up to date in real time.
library;

import 'package:equatable/equatable.dart';
import 'package:fitness_app/core/errors/failures.dart';
import 'package:fitness_app/features/nutrition/domain/entities/nutrition_entry.dart';
import 'package:fitness_app/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:fpdart/fpdart.dart';

class WatchNutritionEntries {
  const WatchNutritionEntries(this.repository);

  final NutritionRepository repository;

  Stream<Either<Failure, List<NutritionEntry>>> call(WatchNutritionParams params) {
    return repository.watchNutritionEntries(
      userId: params.userId,
      date: params.date,
      mealType: params.mealType,
    );
  }
}

class WatchNutritionParams extends Equatable {
  const WatchNutritionParams({
    required this.userId,
    required this.date,
    required this.mealType,
  });

  final String userId;
  final DateTime date;
  final MealType mealType;

  @override
  List<Object> get props => [userId, date, mealType];
}
