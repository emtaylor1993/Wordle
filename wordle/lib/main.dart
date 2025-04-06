/// ****************************************************************************************************
/// File: main.dart
///
/// Author: Emmanuel Taylor
/// Created: April 3, 2025
/// Modified: April 4, 2025
///
/// Description: 
///  - Entry point for the Wordle application. Initializes environment variables, theme
///  - theme settings, and routing logic with provider-based state management.
/// 
/// Dependencies:
///  - flutter_dotenv: Loads environment variables from a `.env` file.
///  - provider: State management for theming and authentication.
///  - material.dart: Flutter UI framework.
///  - screens: Screens for the application.
///****************************************************************************************************
library;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:wordle/providers/settings_provider.dart';
import 'package:wordle/providers/auth_provider.dart';
import 'package:wordle/screens/login_screen.dart';
import 'package:wordle/screens/signup_screen.dart';
import 'package:wordle/screens/puzzle_screen.dart';
import 'package:wordle/screens/profile_screen.dart';

/// Main entry point for the application. Loads .env variable sand initializes 
/// the application with Provider state management.
Future<void> main() async {
  await dotenv.load(fileName: ".env");
  // runApp(const WordleApp());
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()..loadToken()),
      ],
      child: const WordleApp(),
    ),
  );
}

/// Root widget for the Wordle Application. Handles application-wide theme configuration
/// and routing based on authentication state.
class WordleApp extends StatelessWidget {
  const WordleApp({super.key});

  // Builds UI.
  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wordle Game',
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: authProvider.isAuthenticated ? const PuzzleScreen() : const LoginScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/puzzle': (context) => const PuzzleScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}