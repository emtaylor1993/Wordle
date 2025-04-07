/// =====================================================================================================
/// File: login_screen.dart
///
/// Author: Emmanuel Taylor
/// Created: April 3, 2025
/// Modified: April 6, 2025
///
/// Description:
///   - Login screen for the Wordle app.
///   - Allows user to enter credentials and authenticate via backend API.
///   - On success, stores JWT and navigates to puzzle screen.
///   - Shows snackbar on successful signup redirect or errors.
///
/// Dependencies:
///   - dart:convert: Conversion between JSON and other data representations.
///   - flutter/material.dart: Core Flutter UI toolkit.
///   - flutter_dotenv/flutter_dotenv.dart: Loads environment variables from a `.env` file.
///   - http/http.dart:  Handles network requests to backend.
///   - provider/provider.dart: State management for settings and authentication.
///   - wordle/providers/auth_provider.dart: Authentication implementations.
///   - wordle/screens/*: Contains implementation for puzzle screen and signup screen.
///   - wordle/utils/*: Contains implementation for navigation helper and snackbar helper.
///   - wordle/widgets/primary_button.dart: Reusable component PrimaryButton.
/// =====================================================================================================
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:wordle/providers/auth_provider.dart';
import 'package:wordle/screens/puzzle_screen.dart';
import 'package:wordle/screens/signup_screen.dart';
import 'package:wordle/utils/navigation_helper.dart';
import 'package:wordle/utils/snackbar_helper.dart';
import 'package:wordle/widgets/primary_button.dart';

/// [LoginScreen] provides a form for username and password input.
/// Navigates to [PuzzleScreen] upon successful authentication.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// [_LoginScreenState] handles form logic, state, validation, API calls, and navigation.
class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _hasShownSuccessMessage = false;

  // Displays post-signup success message using navigation arguments.
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

  /// Sends login credentials to the backend, saves JWT, and navigates to the main screen.
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

  /// Builds UI.
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

                  /// Username field.
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: "Username"),
                    validator: (value) => value!.isEmpty ? "Enter a username" : null,
                  ),

                  /// Password field.
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password"),
                    validator: (value) => value!.isEmpty ? "Enter a password" : null,
                  ),
                  const SizedBox(height: 24),

                  /// Submit button or loading indicator.
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    PrimaryButton(
                      label: "Login",
                      isLoading: _isLoading,
                      onPressed: _submit,
                    ),
                  const SizedBox(height: 12),

                  /// Navigation to signup.
                  TextButton(
                    onPressed: () {
                      navigateWithSlide(context, const SignupScreen());
                    },
                    child: const Text("Don't have an account? Sign up!", style: TextStyle(fontWeight: FontWeight.bold)),
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