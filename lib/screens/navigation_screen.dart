import 'package:flutter/material.dart';
import 'focus_setup_screen.dart';
import 'active_session_screen.dart';
import 'soundscape_screen.dart';
import 'insights_screen.dart';

class NavigationScreen extends StatefulWidget { //NavigationScreen class created. StatefulWidget used.
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0; //stores each tab

  final List<Widget> _screens = const <Widget>[ //list that stores the pages shown for each tab
    FocusSetupScreen(),
    ActiveSessionScreen(),
    SoundscapeScreen(),
    InsightsScreen(),
  ];

  final List<NavigationDestination> _destinations = //bottom naviagtion items
      const <NavigationDestination>[
    NavigationDestination(
      icon: Icon(Icons.tune_outlined),
      selectedIcon: Icon(Icons.tune_rounded),
      label: 'Setup',
    ),
    NavigationDestination(
      icon: Icon(Icons.timer_outlined),
      selectedIcon: Icon(Icons.timer),
      label: 'Session',
    ),
    NavigationDestination(
      icon: Icon(Icons.graphic_eq_outlined),
      selectedIcon: Icon(Icons.graphic_eq_rounded),
      label: 'Soundscape',
    ),
    NavigationDestination(
      icon: Icon(Icons.insights_outlined),
      selectedIcon: Icon(Icons.insights),
      label: 'Insights',
    ),
  ];

  void _onItemTapped(int index) { //letting flutter know to rebuild
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getScreenTitle() { //Chnaged: Dynamic update for AppBar title 
    switch (_selectedIndex) {
      case 0:
        return 'Focus Setup';
      case 1:
        return 'Active Session';
      case 2:
        return 'Soundscape Studio';
      case 3:
        return 'Insights & Tracker';
      default:
        return 'Adaptive Focus Studio';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getScreenTitle()),
        centerTitle: true,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: KeyedSubtree(
          key: ValueKey<int>(_selectedIndex),
          child: _screens[_selectedIndex],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: _destinations,
      ),
    );
  }
}