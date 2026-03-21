import 'package:shared_preferences/shared_preferences.dart'; //import for local key-value

class PreferencesHelper { //helps group all app preferences
  static const String _darkModeKey = 'is_dark_mode'; //exact storage keys used in sharedpreference
  static const String _onboardingSeenKey = 'onboarding_seen';
  static const String _defaultSessionMinutesKey = 'default_session_minutes';

  static Future<bool> getIsDarkMode() async { //opens sharedP, reads dark mode and returns false if nothing is saved (getters)
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  static Future<void> setIsDarkMode(bool value) async { //writes a bool value for local storage (setters)
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  static Future<bool> getOnboardingSeen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingSeenKey) ?? false;
  }

  static Future<void> setOnboardingSeen(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingSeenKey, value);
  }

  static Future<int> getDefaultSessionMinutes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_defaultSessionMinutesKey) ?? 25;
  }

  static Future<void> setDefaultSessionMinutes(int value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_defaultSessionMinutesKey, value);
  }
}