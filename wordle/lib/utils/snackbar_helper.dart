/// ======================================================================================================
/// File: snackbar_helper.dart
///
/// Author: Emmanuel Taylor
/// Created: April 3, 2025
/// Modified: April 6, 2025
///
/// Description:
///   - Custom floating snackbar widget for displaying error and success messages globally.
///   - Uses fade-in/out animations, tap-to-dismiss behavior, and auto-dismissal.
///   - Prevents multiple snackbars from overlapping using a global visibility flag.
///
/// Dependencies:
///   - flutter/material.dart: Core Flutter UI toolkit.
/// ======================================================================================================
library;

import 'package:flutter/material.dart';

/// Prevents showing multiple snackbars simulatenously.
bool _isSnackBarVisible = false;

/// Displays a custom animated floating snackbar.
/// 
/// This helper uses [OverlayEntry] instead of ScaffoldMessenger to allow
/// persistent, globally available snackbars regardless of the widget tree.
/// 
/// Parameters:
/// - [context]: BuildContext for overlay insertion.
/// - [message]: Text to display in the snackbar.
/// - [isError]: True to show red error styling, false for green success styling.
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

/// [_FloatingSnackBar] is an internal widget that renders the snackbar itself with 
/// animation and dismissal.
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

/// [_FloatingSnackBarState] is a state class that handles fade-in, fade-out, tap-to-dismiss, 
/// and timed dismissal from the screen.
class _FloatingSnackBarState extends State<_FloatingSnackBar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize fade animation controller.
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Defines the fade animation curve.
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    
    // Triggers the fade animation.
    _controller.forward();

    // Automatically dismiss the message after 2 seconds.
    Future.delayed(const Duration(seconds: 2), _dismiss);
  }

  /// Handles the fade-out animation and cleanup.
  void _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();

    // Calls back to parent to remove the OverlayEntry.
    widget.onDismiss();
  }

  /// Cleanup animation resources.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Builds UI.
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