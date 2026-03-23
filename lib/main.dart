import 'package:flutter/material.dart';

import 'screens/welcome_screen.dart';
import 'data/preference_helper.dart'; //imports for screens

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); //for shared preferences
  final bool isDarkMode = await PreferencesHelper.getDarkMode(); //loads saved theme before app starts
  runApp(FocusStudioApp(isDarkMode: isDarkMode));
}

class FocusStudioApp extends StatelessWidget { //root widget
  final bool isDarkMode;
  const FocusStudioApp({super.key,required this.isDarkMode,});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adaptive Focus Studio', //title
      debugShowCheckedModeBanner: false, //remove debug label
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light, //choose light or dark mode
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
        darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: const WelcomeScreen(),
    );
  }
}