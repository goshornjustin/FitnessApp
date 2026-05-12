/// Splash screen shown while the app resolves initial auth state.
///
/// Displayed at `/splash` by the router while `authStateProvider` is loading.
/// Once auth state resolves the router redirects automatically — this widget
/// never needs to trigger navigation itself.
///
/// Note: `shared/utils/splash_screen.dart` is an older duplicate of this
/// widget. Prefer this version (`shared/widgets/splash_screen.dart`).
library;

import 'package:flutter/material.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: 250,
            width: MediaQuery.of(context).size.width - 20,
            child: Image.asset(
              'assets/images/bumper_plate.jpg',
              fit: BoxFit.fill,
            ),
          ),
          const Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        ],
      ),
    );
  }
}