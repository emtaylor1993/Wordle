/// ****************************************************************************************************
/// File: login_screen.dart
///
/// Author: Emmanuel Taylor
/// Created: April 3, 2025
/// Modified: April 4, 2025
///
/// Description: 
///  - User login screen for the Wordle application. Allows entry of user credentials,
///  - authentication against the backend API and persistence of sessions.
/// 
/// Dependencies:
///  - flutter_dotenv: Loads environment variables from a `.env` file.
///  - provider: State management for theming and authentication.
///  - material.dart: Flutter UI framework.
///  - http: Handles network requests to the backend.
///  - shared_preferences: Provides persistent local storage for JWT tokens.
///****************************************************************************************************
library;

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:wordle/screens/puzzle_screen.dart';
import 'package:wordle/utils/navigation_helper.dart';
import '../providers/auth_provider.dart';
import '../screens/signup_screen.dart';
import '../utils/snackbar_helper.dart';

/// [LoginScreen] is a `StatefulWidget` used for login functionality.
/// Displays form fields and manages authentication state.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// [_LoginScreenState] manages the state of the login screen.
class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _hasShownSuccessMessage = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      // Show login success message only once if passed via a route argument.
      if (args != null && args['success'] != null && !_hasShownSuccessMessage) {
        showSnackBar(context, args['success']);
        setState(() {
          _hasShownSuccessMessage = true;
        });
      }
    });
  }

  /// Builds the login UI and shows a success snackbar if redirected after signup.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Login", 
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )
                  ),
                  const SizedBox(height: 24),

                  // Username field.
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: "Username"),
                    validator: (value) => value!.isEmpty ? "Enter a username" : null,
                  ),

                  // Password field.
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password"),
                    validator: (value) => value!.isEmpty ? "Enter a password" : null,
                  ),
                  const SizedBox(height: 24),

                  // Submit button or loading indicator.
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text("Login"),
                    ),
                  const SizedBox(height: 12),

                  // Signup link.
                  TextButton(
                    onPressed: () {
                      navigateWithSlide(context, const SignupScreen());
                    },
                    child: const Text("Don't have an account? Sign up"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Handles login form submission: Calls backend and stores JWT if successful.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final baseUrl = dotenv.env['API_BASE_URL'];
      final uri = Uri.parse("$baseUrl:3000/api/auth/login");
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: '{"username":"$username","password":"$password"}'
      );

      if (response.statusCode == 200) {
        final token = jsonDecode(response.body)['token'];
        if (!mounted) return;
        await Provider.of<AuthProvider>(context, listen: false).login(token);
        if (!mounted) return;
        navigateWithSlideReplace(context, const PuzzleScreen());
      } else {
        final errorMsg = jsonDecode(response.body)['error'];
        if (!mounted) return;
        showSnackBar(context, errorMsg ?? "Login Failed", isError: true);
      }
    } catch (e) {
      showSnackBar(context, "Connection Error", isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}