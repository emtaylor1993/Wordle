/// ****************************************************************************************************
/// File: snackbar_helper.dart
///
/// Author: Emmanuel Taylor
/// Created: April 3, 2025
/// Modified: April 4, 2025
///
/// Description: 
///  - Custom floating snackbar component for displaying success or error messages in the 
///    application. It uses a global flag to prevent multiple snackbars from showing up at
///    once. Supports fade in/out animations, tap-to-dismiss, and automatic dismissal.
/// 
/// Dependencies:
///  - material.dart: Flutter UI framework.
///****************************************************************************************************
library;

import 'package:flutter/material.dart';

// Global flag to prevent stacking multiple snackbars simultaneously.
bool _isSnackBarVisible = false;

/// Displays a custom animated floating snackbar.
///
/// [context]: The BuildContext for inserting the overlay.
/// [message]: The text message to show.
/// [isError]: Whether it's an error (red) or success (green) snackbar.
void showSnackBar(BuildContext context, String message, {bool isError = false}) {
  if (_isSnackBarVisible) return;

  final overlay = Overlay.of(context);
  
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) {
      return Positioned(
        top: MediaQuery.of(context).padding.top + 20,
        left: 24,
        right: 24,
        child: _FloatingSnackBar(
          message: message,
          isError: isError,
          backgroundColor: isError ? Colors.redAccent : Colors.green,
          icon: isError ? Icons.error_outline_sharp : Icons.check_circle_sharp,
          onDismiss: () {
            overlayEntry.remove();
            _isSnackBarVisible = false;
          },
        ),
      );
    },
  );

  _isSnackBarVisible = true;
  overlay.insert(overlayEntry);
}

/// Internal widget for rendering the snackbar with animation and dismissal logic.
class _FloatingSnackBar extends StatefulWidget {
  final String message;
  final bool isError;
  final Color backgroundColor;
  final IconData icon;
  final VoidCallback onDismiss;

  const _FloatingSnackBar({
    required this.message,
    required this.isError,
    required this.backgroundColor,
    required this.icon,
    required this.onDismiss,
  });

  @override
  State<_FloatingSnackBar> createState() => _FloatingSnackBarState();
}

class _FloatingSnackBarState extends State<_FloatingSnackBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the fade-in/out controller.
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    
    // Starts the fade-in animation.
    _controller.forward();

    // Auto dismiss after 2 seconds.
    Future.delayed(const Duration(seconds: 2), _dismiss);
  }

  /// Handles fade-out animation and calls the dismiss callback.
  void _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Builds the snackbar UI with icon and animated fade.
  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: GestureDetector(
        onTap: _dismiss,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          color: widget.backgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(widget.icon, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}