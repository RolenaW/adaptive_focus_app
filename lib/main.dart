import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; //imports for flutter material/services

import 'screens/welcome_screen.dart';
import 'screens/navigation_screen.dart';
import 'data/preference_helper.dart'; //imports for screens

Future<void> main() async { //need async code before launching app
  WidgetsFlutterBinding.ensureInitialized();

  final bool isDarkMode = await PreferencesHelper.getIsDarkMode(); //reads saved dark mode perference from local storage

  await SystemChrome.setPreferredOrientations([ //portrait 
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(FocusStudioApp(isDarkMode: isDarkMode)); //launch app with saved theme setting
}

class FocusStudioApp extends StatelessWidget { //root widget
  final bool isDarkMode; //theme perference

  const FocusStudioApp({ //constructor for widget identities and theme
    super.key,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adaptive Focus Studio', //title
      debugShowCheckedModeBanner: false, //remove debug label
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light, //switches theme based on perference
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
      darkTheme: ThemeData( //define dark theme 
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: const WelcomeScreen(),
    );
  }
}