/// Global string and numeric constants used throughout the app.
///
/// Split into two classes:
/// - [AppConstants] — collection names, storage keys, API base URLs, and
///   default goal values (e.g. 2 000 cal/day, 10 000 steps).
/// - [ValidationConstants] — min/max bounds for user input (password length,
///   weight range, age range, etc.).
///
/// Add new constants here rather than hard-coding magic values in widgets or
/// data sources.
class AppConstants {
  static const String appName = 'Fitness App';
  
  // Firebase Collection Names
  static const String usersCollection = 'users';
  static const String recipesCollection = 'recipes';
  static const String workoutsCollection = 'workouts';
  static const String exercisesCollection = 'exercises';
  static const String nutritionCollection = 'nutrition';
  
  // Local Storage Keys
  static const String userIdKey = 'user_id';
  static const String userDataKey = 'user_data';
  static const String nutritionDataKey = 'nutrition_data';
  
  // API Constants
  static const String openFoodFactsBaseUrl = 'https://world.openfoodfacts.org/api/v0';
  
  // Health Data Types
  static const String stepsHealthType = 'steps';
  static const String caloriesHealthType = 'calories';
  static const String weightHealthType = 'weight';
  
  // Default Values
  static const int defaultDailyCalories = 2000;
  static const double defaultWaterIntake = 2.0; // liters
  static const int defaultStepsGoal = 10000;
}

/// Bounds used to validate user-supplied profile and auth data.
///
/// Used in form validation logic to ensure inputs are within acceptable
/// physical and security ranges before being sent to Firebase.
class ValidationConstants {
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;
  static const double minWeight = 30.0; // kg
  static const double maxWeight = 300.0; // kg
  static const double minHeight = 100.0; // cm
  static const double maxHeight = 250.0; // cm
  static const int minAge = 13;
  static const int maxAge = 120;
}