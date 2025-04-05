/// ****************************************************************************************************
/// File: theme_provider.dart
///
/// Author: Emmanuel Taylor
/// Created: April 3, 2025
/// Modified: April 4, 2025
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

/// [ThemeProvider] is a `ChangeNotifier` class that handles dark/light theme mode.
/// It retrieves and persists the user's theme preference.
class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;
  ThemeMode get currentTheme => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// Loads theme preference when the provider is initialized.
  ThemeProvider() {
    _loadTheme();
  }

  /// Retrieves the saved theme mode from `SharedPreferences`.
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  /// Toggles between light and dark mode and persists the preference.
  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
  }
}