import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

AppBar buildAppBar({required BuildContext context, required String title, List<Widget>? additionalActions}) {
  return AppBar(
    title: Text(title),
    actions: [
      IconButton(
        icon: Icon(
          Provider.of<ThemeProvider>(context).isDarkMode ? Icons.light_mode : Icons.dark_mode,
        ),
        onPressed: () {
          Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
        },
        tooltip: 'Toggle Theme',
      ),
      ...?additionalActions,
    ],
  );
}