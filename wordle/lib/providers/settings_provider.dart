/// ===============================================================================================
/// File: settings_provider.dart
///
/// Author: Emmanuel Taylor
/// Created: April 3, 2025
/// Modified: April 6, 2025
///
/// Description:
///  - Provides global application settings such as dark mode, hard mode, and high contrast mode.
///  - Persists these settings locally using `SharedPreferences`.
///  - Notifies listeners when any setting changes to rebuild dependent widgets.
///
/// Dependencies:
///  - material.dart: Core Flutter UI toolkit.
///  - shared_preferences: To persist settings across app restarts.
/// ===============================================================================================
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [SettingsProvider] manages toggles like theme, hard mode, and accessibility settings.
/// 
/// This provider ensures settings are both reactive and persistent across sessions
/// using `SharedPreferences`. It exposes getts for reading values and asynchronous methods
/// for updating and storing them.
class SettingsProvider extends ChangeNotifier {
  // Internal State.
  bool _hardMode = false;
  bool _highContrast = false;
  bool _isDarkMode = true;

  // Public getters for consumers.
  bool get hardMode => _hardMode;
  bool get highContrast => _highContrast;
  bool get isDarkMode => _isDarkMode;

  /// Constructor: Automatically loads settings from local storage.
  SettingsProvider() {
    _loadSettings();
  }

  /// Loads persisted settings from `SharedPreferences` on application startup.
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _hardMode = prefs.getBool('hardMode') ?? false;
    _highContrast = prefs.getBool('highContrast') ?? false;
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    notifyListeners();
  }

  /// Toggles hard mode settings and stores the change.
  Future<void> toggleHardMode() async {
    _hardMode = !_hardMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hardMode', _hardMode);
    notifyListeners();
  }

  /// Toggles high contrast settings and stores the change.
  Future<void> toggleHighContrast() async {
    _highContrast = !_highContrast;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('highContrast', _highContrast);
    notifyListeners();
  }

  /// Toggles theme between dark and light and persists the preference.
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }
}