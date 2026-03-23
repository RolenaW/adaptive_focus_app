import 'package:flutter/material.dart';

import 'screens/welcome_screen.dart';
import 'data/preference_helper.dart'; //imports for screens

Future<void> main() async { //entry point for app
  WidgetsFlutterBinding.ensureInitialized(); //for shared preferences, ensures flutter is intialized before running async
  final bool isDarkMode = await PreferencesHelper.getDarkMode(); //loads saved theme before app starts
  runApp(FocusStudioApp(isDarkMode: isDarkMode)); //launch app
}

class FocusStudioApp extends StatelessWidget { //root widget
  final bool isDarkMode;
  const FocusStudioApp({super.key,required this.isDarkMode,}); //construcotr for theme preference

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adaptive Focus Studio', //title
      debugShowCheckedModeBanner: false, //remove debug banner
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light, //choose light or dark mode
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