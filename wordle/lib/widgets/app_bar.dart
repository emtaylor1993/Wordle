/// ===============================================================================================
/// File: app_bar.dart
///
/// Author: Emmanuel Taylor
/// Created: April 3, 2025
/// Modified: April 6, 2025
///
/// Description: 
///  - Provides a reusable, consistent [AppBar] across the Wordle application. It includes
///  - support for a customizable title, optional extra actions, and built-in settings and
///  - logout actions.
/// 
/// Dependencies:
///  - flutter/material.dart: Core Flutter UI toolkit.
/// ===============================================================================================
library;

import 'package:flutter/material.dart';

/// Builds a style [AppBar] widget with configurable title, extra actions, and default
/// settings and logout icons.
/// 
/// Parameters:
/// - [context]: BuildContext required for navigation and theming.
/// - [title]: Title string displayed in the center of the AppBar.
/// - [onSettingsPressed]: Callback for the settings button. Show a bottom modal sheet.
/// - [onLogoutPressed]: Callback for the logout button. Triggers logout logic.
/// - [extraActions]: Optional list of additional actions.
AppBar buildAppBar({
  required BuildContext context, 
  required String title, 
  VoidCallback? onSettingsPressed, 
  VoidCallback? onLogoutPressed,
  List<Widget>? extraActions,
}) {
  return AppBar(
    title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
    actions: [
      // Adds custom actions passed in by the screen (if any).
      if (extraActions != null) ...extraActions,
      
      // Default settings button.
      IconButton(
        icon: const Icon(Icons.settings),
        onPressed: onSettingsPressed,
        tooltip: "Settings",
      ),

      // Default logout button.
      IconButton(
        icon: const Icon(Icons.logout),
        onPressed: onLogoutPressed,
        tooltip: "Logout",
      )
    ],
  );
}
