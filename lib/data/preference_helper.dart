import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper { //manages user saved preferences
  static const String _darkModeKey = 'dark_mode';
  static const String _defaultWorkDurationKey = 'default_work_duration';
  static const String _defaultBreakDurationKey = 'default_break_duration';

  static Future<bool> getDarkMode() async { //reads: the saved dark mode value
    final SharedPreferences prefs = await SharedPreferences.getInstance(); //get access to local storage
    return prefs.getBool(_darkModeKey) ?? false; //return if saved or false if nothing saved 
  }

  static Future<void> setDarkMode(bool value) async { //writes: saves the dark mode setting
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_darkModeKey, value); //save value using key
  }

  static Future<int> getDefaultWorkDuration() async { //reads saved default work duration
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_defaultWorkDurationKey) ?? 25; //return saved or deafult
  }

  static Future<void> setDefaultWorkDuration(int value) async { //saves dafult work duration
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_defaultWorkDurationKey, value);
  }

  static Future<int> getDefaultBreakDuration() async { //reads saved deafault break duration
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_defaultBreakDurationKey) ?? 5; //default is 5 if nothing saved 
  }

  static Future<void> setDefaultBreakDuration(int value) async { //saves deafult break duration
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_defaultBreakDurationKey, value);
  }
}