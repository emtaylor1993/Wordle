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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
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

  final String? baseUrl = dotenv.env['API_BASE_URL'];

  /// Constructor: Automatically loads settings from local storage.
  SettingsProvider() {
    _loadSettings();
  }

  /// Loads persisted settings from `SharedPreferences` on application startup.
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    // Loads from SharedPreferences first as a fallback.
    _hardMode = prefs.getBool('hardMode') ?? false;
    _highContrast = prefs.getBool('highContrast') ?? false;
    _isDarkMode = prefs.getBool('isDarkMode') ?? true;
    notifyListeners();

    // Fetch fresh hard mode setting from backend if token exists.
    await getHardModeFromBackend();
  }

  /// Fetches hard mode setting from backend to update the state if different.
  Future<void> getHardModeFromBackend() async {
    debugPrint("[SettingsProvider] Fetching hard mode from backend...");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      if (token != null) {
        final res = await http.get(
          Uri.parse("$baseUrl:3000/api/auth/settings/hard-mode"),
          headers: {'Authorization': 'Bearer $token'},
        );

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          _hardMode = data['hardMode'] == true;
          debugPrint("[SettingsProvider] Updated hardMode: $_hardMode");
          await prefs.setBool('hardMode', _hardMode);
          notifyListeners();
        } else {
          debugPrint("[SettingsProvider] Failed to fetch. Status: ${res.statusCode}");
        }
      } else {
        debugPrint("[SettingsProvider] No token found, skipping fetch.");
      }
    } catch (e) {
      debugPrint("[SettingsProvider] getHardModeFromBackend error: $e");
    }
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