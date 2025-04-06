import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import 'snackbar_helper.dart';

Widget buildSettingsSheet(BuildContext context) {
  final settings = Provider.of<SettingsProvider>(context, listen: false);

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SwitchListTile(
          title: const Text("Hard Mode"),
          subtitle: const Text("Must use revealed hints in subsequent guesses"),
          value: settings.hardMode,
          onChanged: (_) {
            settings.toggleHardMode();
            Navigator.pop(context);
          },
        ),
        SwitchListTile(
          title: const Text("High Contrast Mode"),
          subtitle: const Text("Improves color accessibility (coming soon)"),
          value: settings.highContrast,
          onChanged: (_) {
            showSnackBar(context, "High contrast mode coming soon!");
            Navigator.pop(context);
          },
        ),
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