/// ****************************************************************************************************
/// File: main.dart
///
/// Author: Emmanuel Taylor
/// Created: April 3, 2025
/// Modified: April 3, 2025
///
/// Description: 
///  - Entry point for the Wordle application. Initializes environment variables, theme
///  - theme settings, and routing logic with provider-based state management.
/// 
/// Dependencies:
///  - flutter_dotenv: Loads environment variables from a `.env` file.
///  - provider: State management for theming and authentication.
///  - material.dart: Flutter UI framework.
///****************************************************************************************************
library;

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'package:wordle/providers/auth_provider.dart';
import 'package:wordle/screens/login_screen.dart';
import 'package:wordle/screens/signup_screen.dart';
import 'package:wordle/screens/puzzle_screen.dart';
// import 'package:wordle/screens/profile_screen.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  // runApp(const WordleApp());
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const WordleApp(),
    ),
  );
}

class WordleApp extends StatelessWidget {
  const WordleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..loadToken(),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Wordle Game',
            themeMode: themeProvider.currentTheme,
            theme: ThemeData.light(useMaterial3: true),
            darkTheme: ThemeData.dark(useMaterial3: true),
            home: authProvider.isAuthenticated ? const PuzzleScreen() : const LoginScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/signup': (context) => const SignupScreen(),
              '/puzzle': (context) => const PuzzleScreen(),
              // '/profile': (context) => const ProfileScreen(),
            },
          );
        },
      ),
    );
  }
}