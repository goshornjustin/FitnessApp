/// Use case: derive personalised daily macro targets from a user's profile.
///
/// Uses the Mifflin-St Jeor equation to calculate BMR, applies an activity
/// multiplier to get TDEE, then adjusts for the fitness goal (±500 kcal).
/// Macros are split as: protein at 1.8g/kg bodyweight, fat at 27.5% of
/// calories, carbs filling the remainder.
///
/// Returns a `NutritionGoals` object containing the recommended daily
/// calories, protein, carbs, fat, plus the raw BMR and TDEE values.
/// This is a pure calculation with no I/O — it always succeeds.
library;

import 'package:equatable/equatable.dart';
import 'package:fitness_app/core/errors/failures.dart';
import 'package:fitness_app/core/usecases/usecase.dart';
import 'package:fitness_app/features/authentication/domain/entities/user.dart';
import 'package:fpdart/fpdart.dart';

class CalculateDailyNutrition implements UseCase<NutritionGoals, CalculateNutritionParams> {
  const CalculateDailyNutrition();

  @override
  Future<Either<Failure, NutritionGoals>> call(CalculateNutritionParams params) async {
    try {
      final user = params.user;
      
      // Calculate BMR using Mifflin-St Jeor Equation
      double bmr;
      if (user.gender.toLowerCase() == 'male') {
        bmr = (10 * user.weight) + (6.25 * user.height) - (5 * user.age) + 5;
      } else {
        bmr = (10 * user.weight) + (6.25 * user.height) - (5 * user.age) - 161;
      }

      // Apply activity factor
      double activityFactor;
      switch (user.activityLevel.toLowerCase()) {
        case 'sedentary':
          activityFactor = 1.2;
          break;
        case 'lightly active':
          activityFactor = 1.375;
          break;
        case 'moderately active':
          activityFactor = 1.55;
          break;
        case 'very active':
          activityFactor = 1.725;
          break;
        case 'extremely active':
          activityFactor = 1.9;
          break;
        default:
          activityFactor = 1.2;
      }

      double tdee = bmr * activityFactor;

      // Adjust for fitness goal
      double calorieGoal;
      switch (user.fitnessGoal.toLowerCase()) {
        case 'lose weight':
          calorieGoal = tdee - 500; // 500 calorie deficit
          break;
        case 'gain weight':
          calorieGoal = tdee + 500; // 500 calorie surplus
          break;
        case 'maintain weight':
        default:
          calorieGoal = tdee;
          break;
      }

      // Calculate macronutrient distribution
      // Protein: 1.6-2.2g per kg of body weight
      double proteinGrams = user.weight * 1.8;
      
      // Fat: 25-30% of total calories
      double fatCalories = calorieGoal * 0.275;
      double fatGrams = fatCalories / 9; // 9 calories per gram of fat
      
      // Carbs: remaining calories
      double proteinCalories = proteinGrams * 4; // 4 calories per gram of protein
      double carbCalories = calorieGoal - proteinCalories - fatCalories;
      double carbGrams = carbCalories / 4; // 4 calories per gram of carbs

      return Right(NutritionGoals(
        dailyCalories: calorieGoal.round(),
        proteinGrams: proteinGrams.round(),
        carbGrams: carbGrams.round(),
        fatGrams: fatGrams.round(),
        bmr: bmr.round(),
        tdee: tdee.round(),
      ));
    } catch (e) {
      return const Left(ServerFailure());
    }
  }
}

class CalculateNutritionParams extends Equatable {
  const CalculateNutritionParams({
    required this.user,
  });

  final User user;

  @override
  List<Object> get props => [user];
}

class NutritionGoals extends Equatable {
  const NutritionGoals({
    required this.dailyCalories,
    required this.proteinGrams,
    required this.carbGrams,
    required this.fatGrams,
    required this.bmr,
    required this.tdee,
  });

  final int dailyCalories;
  final int proteinGrams;
  final int carbGrams;
  final int fatGrams;
  final int bmr; // Basal Metabolic Rate
  final int tdee; // Total Daily Energy Expenditure

  @override
  List<Object> get props => [
        dailyCalories,
        proteinGrams,
        carbGrams,
        fatGrams,
        bmr,
        tdee,
      ];
}