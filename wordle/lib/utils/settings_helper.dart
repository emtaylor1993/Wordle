/// ======================================================================================================
/// File: settings_helper.dart
///
/// Author: Emmanuel Taylor
/// Created: April 4, 2025
/// Modified: April 6, 2025
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordle/providers/settings_provider.dart';

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
Widget buildSettingsSheet(BuildContext context) {
  // Access the global settings provider without listening for changes in this widget.
  final settings = Provider.of<SettingsProvider>(context, listen: false);

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
          onChanged: (_) {
            settings.toggleHardMode();
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