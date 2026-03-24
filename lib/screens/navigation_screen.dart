import 'package:flutter/material.dart';
import 'focus_setup_screen.dart';
import 'active_session_screen.dart';
import 'soundscape_screen.dart';
import 'insights_screen.dart'; //imports

class NavigationScreen extends StatefulWidget { //NavigationScreen class created. StatefulWidget used.
  const NavigationScreen({super.key}); //screen after welcome and let's you switch bewtween tabs

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0; //stores each tab, tracks which is selected

  final List<Widget> _screens = const <Widget>[ //list that stores the pages shown for each tab
    FocusSetupScreen(), //index 0 ^
    ActiveSessionScreen(
      workDuration: 25,
      breakDuration: 5,
    ),
    SoundscapeScreen(),
    InsightsScreen(),
  ];

  final List<NavigationDestination> _destinations = //bottom naviagtion items, the icons and labels
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

  String _getScreenTitle() { //Chnaged: Dynamic update Appbar title for different tabs
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
      appBar: AppBar( //changing depending on tab
        title: Text(_getScreenTitle()),
        centerTitle: true,
      ),
      body: IndexedStack(
        index: _selectedIndex, // controls which screen is visible
        children: _screens,    // ALL screens stay in memory
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped, //when tab pressed, update index
        destinations: _destinations,
      ),
    );
  }
}