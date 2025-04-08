/// ===============================================================================================
/// File: signup_screen.dart
///
/// Author: Emmanuel Taylor
/// Created: April 3, 2025
/// Modified: April 6, 2025
///
/// Description:
///  - Signup screen for the Wordle app. Allows users to create accounts by submitting
///  - credentials to the backend, which returns a JWT token on success.
///  - Handles loading UI state, form validation, and user feedback.
///
/// Dependencies:
///  - dart:convert: Conversion between JSON and other data representations.
///  - flutter/material.dart: Core Flutter UI toolkit.
///  - flutter_dotenv/flutter_dotenv.dart: Loads environment variables from a `.env` file.
///  - http/http.dart: Handles network requests to backend.
///  - provider/provider.dart: State management for settings and authentication.
///  - wordle/providers/auth_provider.dart: Authentication implementations.
///  - wordle/screens/login_screen.dart: Implementation of Login Screen.
///  - wordle/utils/*: Implementations for navigation and snackbar helpers.
///  - wordle/widgets/primary_button.dart: Implementation for the primary button.
/// ===============================================================================================
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:wordle/providers/auth_provider.dart';
import 'package:wordle/providers/settings_provider.dart';
import 'package:wordle/screens/login_screen.dart';
import 'package:wordle/utils/navigation_helper.dart';
import 'package:wordle/utils/snackbar_helper.dart';
import 'package:wordle/widgets/primary_button.dart';

/// [SignupScreen] is a `StatefulWidget` that allows users to register 
/// a new account.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

/// [_SignupScreenState] manages the form, loading state, and API request logic.
class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;

  /// Validates the form, sends a signup request to the backend, and handles the response.
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final baseUrl = dotenv.env['API_BASE_URL'];
      final uri = Uri.parse("$baseUrl:3000/api/auth/signup");
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final token = jsonDecode(response.body)['token'];

        if (!mounted) return;
        await Provider.of<AuthProvider>(context, listen: false).login(token);
        if (!mounted) return;
        await Provider.of<SettingsProvider>(context, listen: false).getHardModeFromBackend();
        if (!mounted) return;
        navigateWithSlideReplace(
          context, 
          const LoginScreen(), 
          direction: SlideDirection.leftToRight,
          arguments: {'success': 'Signup Successful!'}
        );
      } else {
        final errorMsg = jsonDecode(response.body)['error'];
        if (!mounted) return;
        showSnackBar(context, errorMsg ?? "Login Failed", isError: true);
      }
    } catch (e) {
      debugPrint("[SIGNUP] Connection Error: $e");
      showSnackBar(context, "Connection Error", isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Renders UI.
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

                  // Title.
                  Text(
                    "Sign Up", 
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )
                  ),
                  const SizedBox(height: 24),

                  // Username Field.
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: "Username"),
                    validator: (value) => value!.isEmpty ? "Enter a username" : null,
                  ),
                  const SizedBox(height: 16),

                  // Password Field.
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password"),
                    validator: (value) => value!.isEmpty ? "Enter a password" : null,
                  ),
                  const SizedBox(height: 24),

                  // Create account button or spinner.
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    PrimaryButton(
                      label: "Create Account",
                      isLoading: _isLoading,
                      onPressed: _submit,
                    ),
                  const SizedBox(height: 12),

                  // Navigation to the Login Page.
                  TextButton(
                    onPressed: () {
                      navigateWithSlideReplace(context, const LoginScreen(), direction: SlideDirection.leftToRight);
                    },
                    child: const Text("Already have an account? Log in!", style: TextStyle(fontWeight: FontWeight.bold)),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}