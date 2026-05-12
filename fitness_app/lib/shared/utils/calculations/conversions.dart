/// Unit conversion helpers for weight and height.
///
/// The domain layer stores all values in metric (kg, cm). Use these helpers
/// when displaying imperial units to the user or accepting imperial input.
class UnitConversions {
  /// converts imperial pounds to metric kilograms
  /// 1 lbs = 0.45359237 kg
  int convertToKGs(int weight) {
    const double x = 2.205;
    double toKGs = weight / x;
    return toKGs.round();
  }

  /// converts metric kilograms
  /// 1 kg = 2.2046226218 lbs
  int convertToLbs(double weight) {
    const double x = 2.2046226218;
    double toLbs = weight * x;
    return toLbs.round();
  }

  /// converts feet and inches to centimeters
  ///  1 foot = 30.48 cms
  /// 1 inch = 2.54 cms
  int convertToCMs(int feet, int inches) {
    const double x = 30.48;
    const double y = 2.54;
    double feetToCms = feet * x;
    double inchesToCms = inches * y;
    double toCMs = feetToCms + inchesToCms;
    return toCMs.round();
  }

  double convertPercentToDecimal(int p) {
    return (p / 100);
  }
}
