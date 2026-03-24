import 'package:flutter/material.dart';

import 'screens/welcome_screen.dart';
import 'data/preference_helper.dart'; //imports for screens

Future<void> main() async { //entry point for app
  WidgetsFlutterBinding.ensureInitialized(); //for shared preferences, ensures flutter is intialized before running async
  final bool isDarkMode = await PreferencesHelper.getDarkMode(); //loads saved theme before app starts
  runApp(FocusStudioApp(isDarkMode: isDarkMode)); //launch app
}

class FocusStudioApp extends StatefulWidget { //root widget, changed to stateful widget
  final bool isDarkMode; 
  const FocusStudioApp({super.key,required this.isDarkMode,}); //construcotr for theme preference

  @override
  State<FocusStudioApp> createState() => _FocusStudioAppState();
  static _FocusStudioAppState? of(BuildContext context) { //allows child widgets to access and update theme
    return context.findAncestorStateOfType<_FocusStudioAppState>();
  }
}
class _FocusStudioAppState extends State<FocusStudioApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode; //initialize theme from saved preference
  }
  void toggleTheme(bool value) async { //function to toggle theme
    setState(() {
      _isDarkMode = value; //update UI instantly
    });
    await PreferencesHelper.setDarkMode(value); //save preference so it persists after app restart
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adaptive Focus Studio', //title
      debugShowCheckedModeBanner: false, //remove debug banner
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light, //choose light or dark mode
      theme: ThemeData( //light theme
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
        darkTheme: ThemeData( //dark theme
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: const WelcomeScreen(), //launches welcome screen
    );
  }
}