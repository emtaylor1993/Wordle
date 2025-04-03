import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordle/providers/auth_provider.dart';
import 'package:wordle/screens/login_screen.dart';
import 'package:wordle/screens/signup_screen.dart';
import 'package:wordle/screens/puzzle_screen.dart';
// import 'package:wordle/screens/profile_screen.dart';

void main() {
  runApp(const WordleApp());
}

class WordleApp extends StatelessWidget {
  const WordleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider()..loadToken(),
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Wordle Game',
            theme: ThemeData.dark(),
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