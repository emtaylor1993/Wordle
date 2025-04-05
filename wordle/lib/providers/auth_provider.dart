/// ****************************************************************************************************
/// File: auth_provider.dart
///
/// Author: Emmanuel Taylor
/// Created: April 3, 2025
/// Modified: April 4, 2025
///
/// Description: 
///  - Authentication state management using `ChangeNotifier` and persistent storage.
/// 
/// Dependencies:
///  - shared_preferences: Provides persistent local storage for JWT tokens.
///  - material.dart: Flutter UI framework.
///****************************************************************************************************
library;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// [AuthProvider] manages login state and persists the JWT token using `SharedPreferences`.
/// It exposes helper methods to login, logout, and load tokens from storage.
class AuthProvider with ChangeNotifier {
  String? _token;
  bool get isAuthenticated => _token != null;
  String? get token => _token;

  /// Loads the JWT token from shared preferences and notifies listeners.
  Future<void> loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    notifyListeners();
  }

  /// Saves the JWT token to shared preferences and updates the internal state.
  /// Called upon successful login or signup.
  Future<void> login(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = token;
    await prefs.setString('token', token);
    notifyListeners();
  }

  /// Clears the JWT token from memory and shared preferences.
  /// Called when the user logs out.
  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = null;
    await prefs.remove('token');
    notifyListeners();
  }
}