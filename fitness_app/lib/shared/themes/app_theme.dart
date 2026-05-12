/// App-wide Material 3 theme configuration.
///
/// The seed colour is an orange-red (`#FF6E40`). All colour roles
/// (primary, secondary, surface, etc.) are derived from this seed by Flutter's
/// `ColorScheme.fromSeed`. To change the app's colour palette, update the
/// `seedColor` here.
library;

import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData appTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color.fromARGB(255, 255, 110, 64),
    ),
  );
}