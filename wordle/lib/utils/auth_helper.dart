/// ======================================================================================================
/// File: auth_helper.dart
///
/// Author: Emmanuel Taylor
/// Created: April 4, 2025
/// Modified: April 6, 2025
///
/// Description:
///   - Contains authentication utility functions for user session management.
///   - Provides a reusable `handleLogout` method that shows a confirmation dialog, logs the user out,
///     and navigates back to the login screen.
/// 
/// Dependencies:
///   - flutter/material.dart: Core Flutter UI toolkit.
///   - provider/provider.dart: State management for settings and authentication.
///   - wordle/providers/auth_provider.dart: Authentication state handling.
///   - wordle/screens/login_screen.dart: Logout destination.
///   - wordle/utils/navigation_helper.dart: Custom slide transition navigator.
///   - wordle/widgets/primary_button.dart: Custom styled action button for logout.
/// ======================================================================================================
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordle/providers/auth_provider.dart';
import 'package:wordle/screens/login_screen.dart';
import 'package:wordle/utils/navigation_helper.dart';
import 'package:wordle/widgets/primary_button.dart';

/// Displays a logout confirmation dialog and, if confirmed:
/// - Calls the logout method on the [AuthProvider].
/// - Navigates back to the login screen using a custom slide transition.
/// 
/// Shows an [AlertDialog] with Cancel and Logout actions. Logout is styled with
/// [PrimaryButton]
/// 
/// Parameters:
/// - [context]: The current [BuildContext] for showing dialog and navigation.
Future<void> handleLogout(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Are you sure you want to log out?"),
      actions: [

        // Cancel button simply closes the dialog without logging out.
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.1)),
        ),

        // Logout button returns true to trigger the logout logic below.
        PrimaryButton(
          label: "Logout",
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );

  // If the user confirmed and the context is still valid, perform the logout.
  if (context.mounted && confirmed == true) {
    // Clear authentication state via the provider.
    Provider.of<AuthProvider>(context, listen: false).logout();

    // Redirect the user back to the login screen with a left-to-right slide.
    navigateWithSlideReplace(
      context,
      const LoginScreen(),
      direction: SlideDirection.leftToRight,
      arguments: {'success': 'Logged Out Successfully'},
    );
  }
}