/// Root widget of the application.
///
/// Reads [routerProvider] to obtain the fully configured router (including
/// auth-redirect logic) and passes it to `MaterialApp.router`. Theme and
/// navigation are the only concerns here — all business logic lives in
/// features and providers.
library;

import 'package:fitness_app/core/providers/app_providers.dart';
import 'package:fitness_app/shared/themes/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      title: 'Fitness App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.appTheme,
      routerConfig: router,
    );
  }
}
