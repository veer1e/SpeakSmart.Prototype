import 'package:flutter/material.dart';

import '../../../app/routes.dart';
import '../../home/presentation/home_screen.dart';
import '../../practice/presentation/practice_screen.dart';
import '../../progress/presentation/progress_screen.dart';
import '../../profile/presentation/profile_screen.dart';


const _kNavy = Color(0xFF1B3245);

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

  static const _destinations = [
    (Icons.home_rounded,      Icons.home_outlined,      'Home'),
    (Icons.mic_rounded,       Icons.mic_none,           'Practice'),
    (Icons.bar_chart_rounded, Icons.insights_outlined,  'Progress'),
    (Icons.person_rounded,    Icons.person_outline,     'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(bottom: false, child: _pages[_index]),
      bottomNavigationBar: _PillNavBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: _destinations,
      ),
    );
  }
}


class _PillNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<(IconData, IconData, String)> destinations;

  const _PillNavBar({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(18, 8, 18, bottom + 12),
      child: Container(
        height: 68,
        decoration: BoxDecoration(
          color:        _kNavy,
          borderRadius: BorderRadius.circular(40),
          boxShadow: [
            BoxShadow(
              color:      _kNavy.withOpacity(0.35),
              blurRadius: 24,
              offset:     const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(destinations.length, (i) {
            final (activeIcon, idleIcon, label) = destinations[i];
            final isActive = i == selectedIndex;

            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onDestinationSelected(i),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
                      decoration: BoxDecoration(
                        color:        Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(activeIcon, color: Colors.white, size: 22),
                    )
                  else
                    Icon(idleIcon, color: Colors.white.withOpacity(0.5), size: 22),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      color:      isActive ? Colors.white : Colors.white.withOpacity(0.5),
                      fontSize:   10,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}