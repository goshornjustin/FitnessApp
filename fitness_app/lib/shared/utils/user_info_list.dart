/// Static data lists used to populate dropdowns and radio groups in the UI.
///
/// Centralises the allowed values for gender, age, activity level, fitness
/// goal, and goal reason so they stay consistent between the profile setup
/// wizard and any other forms that collect the same fields.
///
/// Activity level strings here must match the switch cases in `Calculations`
/// and `CalculateDailyNutrition` — changing a string in one place requires
/// updating it in both.
class UserInfoLists {
  static const List<String> _genderValues = ['Female', 'Male'];

  static const List<int> _ageValues = [
    18,
    19,
    20,
    21,
    22,
    23,
    24,
    25,
    26,
    27,
    28,
    29,
    30,
    31,
    32,
    33,
    34,
    35,
    36,
    37,
    38,
    39,
    40,
    41,
    42,
    43,
    44,
    45,
    46,
    47,
    48,
    49,
    50,
    51,
    52,
    53,
    54,
    55,
    56,
    57,
    58,
    59,
    60,
    61,
    62,
    63,
    64,
    65,
    66,
    67,
    68,
    69,
    70,
    71,
    72,
    73,
    74,
    75,
    76,
    77,
    78,
    79,
    80,
    81,
    82,
    83,
    84,
    85,
    86,
    87,
    88,
    89,
    90
  ];

  static const List<String> _activityLevels = [
    'Sedentary Lifestyle',
    'Slighty Active Lifestlye',
    'Moderately Active Lifestyle',
    'Active Lifestyle',
    'Very Active Lifestyle'
  ];

  static const List<String> _activityDescriptionLevels = [
    'little or no exercise',
    'Exercise 1-3 times/week',
    'Exercise 4-5 times/week',
    'Daily exercise or intense exercise 3-4 times/week',
    'Intense exercise 6-7 times/week',
  ];

  static const List<String> _goalValues = [
    'Lose Weight',
    'Gain Weight',
  ];

  static const List<String> _loseWeightGoalReasonValues = [
    'Lack of time',
    'Did not enjoy healtier food',
    'Difficult to make food choices',
    'Social eating and events',
    'Food cravings',
    'Lack of progress',
    'Healthy food does not taste good',
    'Healthy food is too expensive',
    'Cooking is too hard/time consuming',
  ];

  static const List<String> _gainWeightGoalReasonValues = [
    'Competitive sport performance',
    'Gain muscle for general fitness',
    'I am underweight',
    'My healthcare provider suggested it',
    'Other',
  ];

  List<int> getAgeList() {
    return _ageValues;
  }

  List<String> getGenderList() {
    return _genderValues;
  }

  List<String> getActivityList() {
    return _activityLevels;
  }

  List<String> getActivityDescriptionList() {
    return _activityDescriptionLevels;
  }

  List<String> getGoalsList() {
    return _goalValues;
  }

  List<String> getGainWeightGoalReasons() {
    return _gainWeightGoalReasonValues;
  }

  List<String> getLoseWeightGoalReasons() {
    return _loseWeightGoalReasonValues;
  }
}
