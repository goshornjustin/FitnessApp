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
