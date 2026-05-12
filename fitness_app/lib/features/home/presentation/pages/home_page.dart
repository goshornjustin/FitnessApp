/// Main shell page with bottom tab navigation.
///
/// [HomePage] uses a `DefaultTabController` with three tabs:
/// 1. Programs — workout programs browser
/// 2. Diet — daily nutrition tracker
/// 3. Results — progress and health metrics
///
/// The bottom nav bar height is adjusted for iOS to account for the home
/// indicator safe area.
library;

import 'dart:io';

import 'package:fitness_app/features/nutrition/presentation/pages/diet_page.dart';
import 'package:fitness_app/features/results/presentation/pages/results_page.dart';
import 'package:fitness_app/features/workout/presentation/pages/programs_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        body: const TabBarView(
          children: [
            ProgramsPage(),
            DietPage(),
            ResultsPage(),
          ],
        ),
        bottomNavigationBar: SizedBox(
          height: Platform.isIOS ? 85 : 65,
          child: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.list)),
              Tab(icon: Icon(Icons.food_bank)),
              Tab(icon: FaIcon(FontAwesomeIcons.award)),
            ],
            labelPadding: EdgeInsets.all(5),
            unselectedLabelColor: Colors.black,
            labelColor: Colors.amber,
            indicatorWeight: 2,
          ),
        ),
      ),
    );
  }
}
