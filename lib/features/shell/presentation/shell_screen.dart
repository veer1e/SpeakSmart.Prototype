import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../home/presentation/home_screen.dart';
import '../../practice/presentation/practice_screen.dart';
import '../../progress/presentation/progress_screen.dart';
import '../../profile/presentation/profile_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;

  final _pages = const [
    HomeScreen(),
    PracticeScreen(),
    ProgressScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.mic_none), label: 'Practice'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), label: 'Progress'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
      floatingActionButton: (_index == 0)
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.pushNamed(context, Routes.practice),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Quick Start'),
            )
          : null,
    );
  }
}
