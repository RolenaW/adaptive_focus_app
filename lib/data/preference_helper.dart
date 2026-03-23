import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static const String darkModeKey = 'dark_mode';
  static const String defaultWorkDurationKey = 'default_work_duration';
  static const String defaultBreakDurationKey = 'default_break_duration';

  static Future<bool> getDarkMode() async { //reads the saved dark mode value
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(darkModeKey) ?? false;
  }

  static Future<void> setDarkMode(bool value) async { //saves the dark mode setting
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(darkModeKey, value);
  }

  static Future<int> getDefaultWorkDuration() async { //reads saved default work duration
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(defaultWorkDurationKey) ?? 25;
  }

  static Future<void> setDefaultWorkDuration(int value) async { //saves dafult work duration
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(defaultWorkDurationKey, value);
  }

  static Future<int> getDefaultBreakDuration() async { //reads saved deafault break duration
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(defaultBreakDurationKey) ?? 5;
  }

  static Future<void> setDefaultBreakDuration(int value) async { //saves deafult break duration
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(defaultBreakDurationKey, value);
  }
}