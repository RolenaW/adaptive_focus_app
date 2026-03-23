import 'package:flutter/material.dart';

import 'screens/welcome_screen.dart';
import 'data/preference_helper.dart'; //imports for screens

void main() { //need async code before launching app
  runApp(FocusStudioApp()); //launch app with saved theme setting
}

class FocusStudioApp extends StatelessWidget { //root widget

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adaptive Focus Studio', //title
      debugShowCheckedModeBanner: false, //remove debug label
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
        appBarTheme: const AppBarTheme( //keeps app clean looking
          centerTitle: true,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme( //ensuring text style is consistent
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const WelcomeScreen(),
    );
  }
}