/// ===============================================================================================
/// File: main.dart
///
/// Author: Emmanuel Taylor
/// Created: April 3, 2025
/// Modified: April 7, 2025
///
/// Description: 
///  - Entry point for the Wordle Flutter application. Loads environment variables and 
///  - sets up providers for the global application state. Configures dynamic theme
///  - switching and conditional naigation based on authentication status.
/// 
/// Dependencies:
///  - flutter/material.dart: Core Flutter UI toolkit.
///  - flutter_dotenv/flutter_dotenv.dart: Loads environment variables from a `.env` file.
///  - provider/provider.dart: State management for settings and authentication.
///  - wordle/providers/*: Settings and authentication implementations.
///  - wordle/screens/*: Contains application screens.
/// ===============================================================================================
library;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:wordle/providers/auth_provider.dart';
import 'package:wordle/providers/settings_provider.dart';
import 'package:wordle/screens/login_screen.dart';
import 'package:wordle/screens/profile_screen.dart';
import 'package:wordle/screens/puzzle_screen.dart';
import 'package:wordle/screens/signup_screen.dart';
import 'package:wordle/screens/statistics_screen.dart';

/// Main entry point for the Wordle application. Loads environment variables from `.env`
/// file and initalizes application-wide state providers.
/// - `SettingsProvider`: Dark mode, accessibility, etc.
/// - `AuthProvider`: JWT login/session tracking.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
    debugPrint("[MAIN] .env File Loaded Successfully");    
  } catch (e) {
    debugPrint("[MAIN] Failed to load .env file: $e");
  }

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

/// [WordleApp] is the root widget for the Wordle application.
/// 
/// - Determines theme based on `SettingsProvider`.
/// - Decides initial screen based on `AuthProvider` (Login vs. Puzzle).
/// - Registers named routes for navigation.
class WordleApp extends StatelessWidget {
  const WordleApp({super.key});

  // Builds UI.
  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wordle Game',

      // Uses dark or light theme based on user settings.
      themeMode: settingsProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),

      // If authenticated, go straight to the puzzle screen.
      home: authProvider.isAuthenticated ? const PuzzleScreen() : const LoginScreen(),
      
      // Define named routes for screen transitions.
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/puzzle': (context) => const PuzzleScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/stats': (context) => const StatisticsScreen(),
      },
    );
  }
}