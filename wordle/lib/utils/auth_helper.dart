import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import 'navigation_helper.dart';

Future<void> handleLogout(BuildContext context) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text("Are you sure you want to log out?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text("Log Out"),
        ),
      ],
    ),
  );

  if (context.mounted && confirmed == true) {
    Provider.of<AuthProvider>(context, listen: false).logout();

    navigateWithSlideReplace(
      context,
      const LoginScreen(),
      direction: SlideDirection.leftToRight,
      arguments: {'success': 'Logged Out Successfully'},
    );
  }
}