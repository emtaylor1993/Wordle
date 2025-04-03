/// ****************************************************************************************************
/// File: auth_provider.dart
///
/// Author: Emmanuel Taylor
/// Created: April 3, 2025
/// Modified: April 3, 2025
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

class AuthProvider with ChangeNotifier {
  String? _token;
  bool get isAuthenticated => _token != null;
  String? get token => _token;

  Future<void> loadToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    notifyListeners();
  }

  Future<void> login(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = token;
    await prefs.setString('token', token);
    notifyListeners();
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = null;
    await prefs.remove('token');
    notifyListeners();
  }
}