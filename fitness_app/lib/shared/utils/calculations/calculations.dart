/// Nutrition and calorie calculation utilities used in the profile setup summary.
///
/// These mirror the logic in `CalculateDailyNutrition` use case but use the
/// activity-level strings defined in `UserInfoLists` (e.g. `'Sedentary
/// Lifestyle'`). They are called directly from `_SummaryPage` to preview macro
/// targets before the profile is saved.
///
/// Note: there is intentional overlap between this class and
/// `CalculateDailyNutrition`. If the calculation logic diverges, prefer
/// updating the domain use case and updating this class to match.
class Calculations {
  /// calculates daily value of protein based on given user weight, total calories
  /// and goal.
  /// 10 - 35 % of all calories
  int calculateDvProtein(int calories, String goal) {
    switch (goal) {
      case 'Lose Weight':
        return ((calories * 0.40) / 4).round();

      default:
        return ((calories * 0.30) / 4).round();
    }
  }

  /// calculates daily value of fat based on given user weight, total calories
  /// and goal.
  /// 20 -35 %
  int calculateDvFat(int calories, String goal) {
    switch (goal) {
      case 'Lose Weight':
        return ((calories * 0.20) / 9).round();

      default:
        return ((calories * 0.30) / 9).round();
    }
  }

  /// calculates daily value of carbs based on given user weight, total calories
  /// and goal.
  /// 40 -65 %
  int calculateDvCarbs(int calories, String goal) {
    switch (goal) {
      case 'Lose Weight':
        return ((calories * 0.40) / 4).round();

      default:
        return ((calories * 0.40) / 4).round();
    }
  }

  ///Calculating using the Mifflin-St. Jeor equation
  double mifflinStJeorCalculation(
      String gender, int age, int weight, double height, double activityLevel) {
    switch (gender) {
      case 'Female':
        final bmr =
            ((10 * weight) + (6.25 * height) - (5 * age) - 161) * activityLevel;
        return bmr;

      default:
        final bmr =
            ((10 * weight) + (6.25 * height) - (5 * age) - 5) * activityLevel;
        return bmr;
    }
  }

  ///Calculate calorie intake based on user values and BMR formulas
  int calculateDailyCalorieIntake(int age, String gender, int weight,
      double height, String activityLevel, String goal) {
    double sedentary = 1.2;
    double light = 1.375;
    double moderate = 1.55;
    double active = 1.725;
    double very = 1.9;

    switch (activityLevel) {
      case 'Sedentary Lifestyle':
        final avg1 =
            mifflinStJeorCalculation(gender, age, weight, height, sedentary);

        return caloriesBasedOnGoal(avg1.round(), goal);
      case 'Slighty Active Lifestlye':
        final avg1 =
            mifflinStJeorCalculation(gender, age, weight, height, light);

        return caloriesBasedOnGoal(avg1.round(), goal);
      case 'Moderately Active Lifestyle':
        final avg1 =
            mifflinStJeorCalculation(gender, age, weight, height, moderate);

        return caloriesBasedOnGoal(avg1.round(), goal);
      case 'Active Lifestyle':
        final avg1 =
            mifflinStJeorCalculation(gender, age, weight, height, active);

        return caloriesBasedOnGoal(avg1.round(), goal);
      default:
        final avg1 =
            mifflinStJeorCalculation(gender, age, weight, height, very);

        return caloriesBasedOnGoal(avg1.round(), goal);
    }
  }

  ///Modifies calorie total based on goals given by the user
  int caloriesBasedOnGoal(int calories, String goal) {
    switch (goal) {
      case 'Lose Weight':
        return calories - 500;
      case 'Gain Weight':
        return calories + 500;

      case 'Gain Muscle':
        return calories + 500;

      default:
        return calories;
    }
  }
}
