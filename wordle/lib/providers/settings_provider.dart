import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  bool _hardMode = false;
  bool _highContrast = false;
  bool _isDarkMode = false;

  bool get hardMode => _hardMode;
  bool get highContrast => _highContrast;
  bool get isDarkMode => _isDarkMode;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _hardMode = prefs.getBool('hardMode') ?? false;
    _highContrast = prefs.getBool('highContrast') ?? false;
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  Future<void> toggleHardMode() async {
    _hardMode = !_hardMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hardMode', _hardMode);
    notifyListeners();
  }

  Future<void> toggleHighContrast() async {
    _highContrast = !_highContrast;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('highContrast', _highContrast);
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }
}