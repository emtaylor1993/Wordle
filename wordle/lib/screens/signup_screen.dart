/// ****************************************************************************************************
/// File: signup_screen.dart
///
/// Author: Emmanuel Taylor
/// Created: April 3, 2025
/// Modified: April 4, 2025
///
/// Description: 
///  - Signup sreen for the Wordle app. Allows users to create accounts, submit credentials to
///  - the backend to recieve a token for authentication.
/// 
/// Dependencies:
///  - flutter_dotenv: Loads environment variables from a `.env` file.
///  - provider: State management for theming and authentication.
///  - material.dart: Flutter UI framework.
///  - http: Handles network requests to the backend.
///  - dart:convert: Used for JSON decoding.
///****************************************************************************************************
library;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:wordle/utils/navigation_helper.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/app_bar.dart';

/// [SignupScreen] is a `StatefulWidget` used for signup functionality.
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

/// [_SignupScreenState] manages the state of the signup screen.
class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  bool _isLoading = false;

  // Renders UI.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(
        context: context,
        title: "",
      ),
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
                    "Sign Up", 
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    )
                  ),                  const SizedBox(height: 24),
                  TextFormField(
                    controller: _usernameController,
                    decoration: const InputDecoration(labelText: "Username"),
                    validator: (value) => value!.isEmpty ? "Enter a username" : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: "Password"),
                    validator: (value) => value!.isEmpty ? "Enter a password" : null,
                  ),
                  const SizedBox(height: 24),
                  if (_isLoading)
                    const CircularProgressIndicator()
                  else
                    ElevatedButton(
                      onPressed: _submit,
                      child: const Text("Create Account"),
                    ),
                  const SizedBox(height: 12),
                  TextButton(
                    onPressed: () {
                      navigateWithSlideReplace(context, const LoginScreen(), direction: SlideDirection.leftToRight);
                    },
                    child: const Text("Already have an account? Log in"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Handles the form submission and signup logic. It validates the form input, sends a
  /// request to the backend, stores a token on success and displays error messages via
  /// snackbar.
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
      showSnackBar(context, "Connection Error", isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}