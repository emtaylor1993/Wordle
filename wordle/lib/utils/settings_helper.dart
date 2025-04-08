/// ======================================================================================================
/// File: settings_helper.dart
///
/// Author: Emmanuel Taylor
/// Created: April 4, 2025
/// Modified: April 7, 2025
///
/// Description:
///   - Builds a reusable modal settings sheet for toggling user preferences.
///   - Toggles include hard mode, high contrast mode, and theme switching.
/// 
/// Dependencies:
///   - flutter/material.dart: Core Flutter UI toolkit.
///   - provider/provider.dart: State management for settings and authentication.
///   - wordle/providers/settings_provider.dart: Source of settings state and logic.
/// ======================================================================================================
library;

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:wordle/providers/auth_provider.dart';
import 'package:wordle/providers/settings_provider.dart';
import 'package:wordle/utils/snackbar_helper.dart';

/// Displays the bottom modal sheet settings panel used across the app.
/// 
/// Provides switches to:
/// - Enable/disable hard mode.
/// - Toggle high contrast mode.
/// - Switch between light and dark themes.
/// 
/// Automatically closes the sheet after any toggle action.
/// 
/// Parameters:
/// - [context]: The current build context where the modal is shown.
/// - [isGameActive]: If true, disables toggling hard mode to preserve gameplay.
Widget buildSettingsSheet(BuildContext context, {bool isGameActive = false}) {
  // Access the global settings provider without listening for changes in this widget.
  final settings = Provider.of<SettingsProvider>(context, listen: false);
  final baseUrl = dotenv.env['API_BASE_URL'];

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        // Toggle: Hard Mode.
        SwitchListTile(
          title: const Text("Hard Mode"),
          subtitle: const Text("Must use revealed hints in subsequent guesses"),
          value: settings.hardMode,
          onChanged: (_) async {     
            if (isGameActive) {
              showSnackBar(context, "Cannot Toggle Hard Mode During Active Game", isError: true);
              return;
            }

            final newValue = !settings.hardMode;
            settings.toggleHardMode();

            final token = Provider.of<AuthProvider>(context, listen: false).token;
            final uri = Uri.parse("$baseUrl:3000/api/auth/settings");

            try {
              final res = await http.patch(
                uri,
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $token',
                },
                body: jsonEncode({'hardMode': newValue}),
              );

              if (!context.mounted) return;
              
              if (res.statusCode == 200) {
                showSnackBar(context, "Hard Mode ${newValue ? 'Enabled' : 'Disabled'}");
              } else {
                showSnackBar(context, "Failed to Sync With Backend", isError: true);
              }
            } catch (e) {
              debugPrint("[SETTINGS_HELPER] Hard Mode Synchronization Error: $e");
              showSnackBar(context, "Network Error", isError: true);
            }

            Navigator.pop(context);
          },
        ),

        // Toggle: High Contrast.
        SwitchListTile(
          title: const Text("High Contrast Mode"),
          subtitle: const Text("Improves color accessibility"),
          value: settings.highContrast,
          onChanged: (_) {
            settings.toggleHighContrast();
            Navigator.pop(context);
          },
        ),

        // Toggle: Theme Mode.
        SwitchListTile(
          title: const Text("Dark Theme"),
          value: settings.isDarkMode,
          onChanged: (_) {
            settings.toggleTheme();
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}