import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static const String _darkModeKey = 'dark_mode';
  static const String _defaultWorkDurationKey = 'default_work_duration';
  static const String _defaultBreakDurationKey = 'default_break_duration';

  static Future<bool> getDarkMode() async { //reads the saved dark mode value
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_darkModeKey) ?? false;
  }

  static Future<void> setDarkMode(bool value) async { //saves the dark mode setting
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value);
  }

  static Future<int> getDefaultWorkDuration() async { //reads saved default work duration
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_defaultWorkDurationKey) ?? 25;
  }

  static Future<void> setDefaultWorkDuration(int value) async { //saves dafult work duration
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_defaultWorkDurationKey, value);
  }

  static Future<int> getDefaultBreakDuration() async { //reads saved deafault break duration
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_defaultBreakDurationKey) ?? 5;
  }

  static Future<void> setDefaultBreakDuration(int value) async { //saves deafult break duration
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_defaultBreakDurationKey, value);
  }
}