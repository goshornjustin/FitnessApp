/// App entry point.
///
/// Initializes all services in order before launching the widget tree:
/// 1. Firebase (Auth + Firestore)
/// 2. OpenFoodFacts user agent (required by the API)
/// 3. Hive (local storage) + adapter registration
///
/// The entire app is wrapped in [ProviderScope] so every Riverpod provider
/// is accessible from any widget in the tree.
library;

import 'package:firebase_core/firebase_core.dart';
import 'package:fitness_app/app.dart';
import 'package:fitness_app/data/local/hive_registrar.g.dart';
import 'package:fitness_app/data/off_functions/off_functions.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize OpenFoodFacts
  OffFunctions offFunctions = OffFunctions();
  offFunctions.setUserAgent();

  // Initialize Hive for local storage
  await Hive.initFlutter();
  Hive.registerAdapters();

  runApp(
    const ProviderScope(
      child: MainApp(),
    ),
  );
}
