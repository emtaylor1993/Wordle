import 'package:flutter/material.dart';

AppBar buildAppBar({
  required BuildContext context, 
  required String title, 
  VoidCallback? onSettingsPressed, 
  VoidCallback? onLogoutPressed,
  List<Widget>? extraActions,
}) {
  return AppBar(
    title: Text(title),
    actions: [
      if (extraActions != null) ...extraActions,
      
      IconButton(
        icon: const Icon(Icons.settings),
        onPressed: onSettingsPressed,
        tooltip: "Settings",
      ),
      IconButton(
        icon: const Icon(Icons.logout),
        onPressed: onLogoutPressed,
        tooltip: "Logout,"
      )
    ],
  );
}
