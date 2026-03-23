import 'package:flutter/material.dart';
import 'focus_setup_screen.dart';
import 'active_session_screen.dart';
import 'soundscape_screen.dart';
import 'insights_screen.dart';

class NavigationScreen extends StatefulWidget { //NavigationScreen class created. StatefulWidget used.
  const NavigationScreen({super.key});

  @override
  State<NavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0; //stores each tab

  late final List<Widget> _screens = [ //list that stores the pages shown for each tab
    const FocusSetupScreen(), 
    const ActiveSessionScreen(),
    const SoundscapeScreen(),
    const InsightsScreen(),
    const _NavigationPlaceholderScreen(
      title: 'Focus Setup',
      description: 'This is where users will choose mood, task type, energy level and session length.',
      icon: Icons.tune_rounded,
    ),
    const _NavigationPlaceholderScreen(
      title: 'Active Session',
      description: 'This screen will run the Pomodoro timer, focus session and distraction tracking.',
      icon: Icons.timer_outlined,
    ),
    const _NavigationPlaceholderScreen(
      title: 'Soundscape',
      description: 'This is where users will customize sound layers and save audio presets.',
      icon: Icons.graphic_eq_rounded,
    ),
    const _NavigationPlaceholderScreen(
      title: 'Insights',
      description: 'This screen will show productivity trends, focus ratings and session history.',
      icon: Icons.analytics_outlined,
    ),
  ];

  void _onItemTapped(int index) { //letting flutter know to rebuild
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<NavigationDestination> _destinations = const [ //define each tab
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

  @override
  Widget build(BuildContext context) {
    return Scaffold( //main structure
      appBar: AppBar(
        title: const Text('Adaptive Focus Studio'),
        centerTitle: true,
      ),
      body: AnimatedSwitcher( //swaps pages when tab is selected
        duration: const Duration(milliseconds: 250),
        child: _screens[_selectedIndex],
      ),
      bottomNavigationBar: NavigationBar( //bottom UI navigation, tells flutter what tab is active
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        destinations: _destinations,
      ),
    );
  }
}

class _NavigationPlaceholderScreen extends StatelessWidget { //temporary!!
  final String title;
  final String description;
  final IconData icon; //reuseable

  const _NavigationPlaceholderScreen({
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) { //screen layout
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Semantics(
                      label: '$title icon',
                      child: CircleAvatar(
                        radius: 36,
                        child: Icon(
                          icon,
                          size: 36,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'still editing', //edit
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}