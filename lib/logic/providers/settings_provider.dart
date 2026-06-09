import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  // important: this is for toggles
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeMode get themeMode =>
      _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  // for toggles
  bool _soundEnabled = true;
  bool get soundEnabled => _soundEnabled;

  bool _hapticEnabled = true;
  bool get hapticEnabled => _hapticEnabled;

  // some static UI texts (real data)
  String get accountEditTitle => "Edit Profile";
  String get darkModeTitle => "Dark Mode";
  String get lightModeTitle => "Light Mode";

  String get darkModeSubtitle => "Dark theme is enabled";
  String get lightModeSubtitle => "Light theme is enabled";

  String get soundTitle => "Sound Effects";
  String get soundSubtitle => "Play sounds during sessions";

  String get hapticTitle => "Haptic Feedback";
  String get hapticSubtitle => "Vibration on interactions";

  String get privacyTitle => "Privacy Policy";
  String get supportTitle => "Contact Support";

  String get signOutTitle => "Sign Out";
  String get deleteTitle => "Delete Account";

  String get signOutDialogTitle => "Sign Out";
  String get signOutDialogText => "You can log in again anytime.";

  String get deleteDialogTitle => "Delete Account";
  String get deleteDialogText => "This action cannot be undone.";

  String get cancelText => "Cancel";

  // for real data
  String get supportEmail => "edulearn.support@gmail.com";

  String get privacyPolicy =>
      "Your data is stored locally using secure SQLite storage.";

  // for init
  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _isDarkMode = prefs.getBool('darkMode') ?? false;
    _soundEnabled = prefs.getBool('sound') ?? true;
    _hapticEnabled = prefs.getBool('haptic') ?? true;

    notifyListeners();
  }

  // some actions included in here
  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('sound', value);
    notifyListeners();
  }

  Future<void> setHapticEnabled(bool value) async {
    _hapticEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('haptic', value);
    notifyListeners();
  }
}