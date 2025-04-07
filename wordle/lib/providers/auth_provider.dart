/// ===============================================================================================
/// File: auth_provider.dart
///
/// Author: Emmanuel Taylor
/// Created: April 3, 2025
/// Modified: April 6, 2025
///
/// Description:
///  - Provides authentication state management for the Wordle app.
///  - Uses [ChangeNotifier] to notify widgets of login/logout state changes.
///  - Persists the JWT token locally using `SharedPreferences` to maintain
///  - session state across app launches.
///
/// Dependencies:
///  - flutter/material.dart: Core Flutter UI toolkit.
///  - shared_preferences: To persist settings across app restarts.
/// ===============================================================================================
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [AuthProvider] is a global provider responsible for:
/// - Tracking if the user is authenticated.
/// - Managing a JWT token.
/// - Persisting and restoring login state using local storage.
class AuthProvider with ChangeNotifier {
  // Stores the JWT token in memory.
  String? _token;

  // Exposed public getters.
  bool get isAuthenticated => _token != null;
  String? get token => _token;

  /// Called on application startup to restore the saved token from local storage.
  /// If a token exists, sets the authentication state accordingly.
  Future<void> loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    notifyListeners();
  }

  /// Saves the provided JWT token in memory and local storage.
  /// This should be triggered after a successful login or signup.
  Future<void> login(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = token;
    await prefs.setString('token', token);
    notifyListeners();
  }

  /// Logs the user out by clearing the token from both memory and local storage.
  /// Notifies the app to update UI.
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = null;
    await prefs.remove('token');
    notifyListeners();
  }
}