/// Use case: search the OpenFoodFacts database by product name.
///
/// Returns a list of raw maps, each containing `name`, `calories`, `protein`,
/// `fat`, `carbs`, `imageUrl`, `servingSize`, and the raw `product` object.
/// Results are already normalised to per-serving values by the data source.
library;

import 'package:equatable/equatable.dart';
import 'package:fitness_app/core/errors/failures.dart';
import 'package:fitness_app/core/usecases/usecase.dart';
import 'package:fitness_app/features/nutrition/domain/repositories/nutrition_repository.dart';
import 'package:fpdart/fpdart.dart';

class SearchFood implements UseCase<List<Map<String, dynamic>>, SearchFoodParams> {
  const SearchFood(this.repository);

  final NutritionRepository repository;

  @override
  Future<Either<Failure, List<Map<String, dynamic>>>> call(SearchFoodParams params) {
    return repository.searchFood(params.query);
  }
}

class SearchFoodParams extends Equatable {
  const SearchFoodParams(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}
