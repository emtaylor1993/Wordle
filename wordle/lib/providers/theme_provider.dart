/// ****************************************************************************************************
/// File: theme_provider.dart
///
/// Author: Emmanuel Taylor
/// Created: April 3, 2025
/// Modified: April 3, 2025
///
/// Description: 
///  - Manages light/dark theme preferences using local storage through Shared Preferences.
/// 
/// Dependencies:
///  - shared_preferences: Provides persistent local storage for JWT tokens.
///  - material.dart: Flutter UI framework.
///****************************************************************************************************
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  ThemeMode get currentTheme => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }
}