/// ===============================================================================================
/// File: primary_button.dart
///
/// Author: Emmanuel Taylor
/// Created: April 6, 2025
/// Last Modified: April 6, 2025
///
/// Description:
///   - Reusable elevated button used throughout the Wordle app.
///   - Handles loading state, disabled state, and optional icon rendering.
///   - Provides consistent theming and styling for CTA buttons.
///
/// Dependencies:
///  - flutter/material.dart: Core Flutter UI toolkit.
/// ===============================================================================================
library;

import 'package:flutter/material.dart';

/// [PrimaryButton] is a reusable styled button.
/// 
/// Features:
/// - Custom label.
/// - Optional loading spinner.
/// - Optional icon.
/// - Disabled state styling.
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isDisabled;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.icon,
  });

  // Builds UI.
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isDisabled || isLoading ? null : onPressed,

      // Button styling.
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green[900],
        elevation: 4,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1.1),
      ),

      // Button content.
      child: isLoading
        ? SizedBox(
            height: 16,
            width: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
          )
        : icon != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18),
                const SizedBox(width: 8),
                Text(label),
              ],
            )
          : Text(label, style: TextStyle(color: Colors.white,)),
    );
  }
}