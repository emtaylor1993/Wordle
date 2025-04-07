/// ======================================================================================================
/// File: navigation_helper.dart
///
/// Author: Emmanuel Taylor
/// Created: April 4, 2025
/// Modified: April 6, 2025
///
/// Description:
///   - Defines reusable navigation utilities to provide consistent slide transition animations
///     when navigating between screens in the app.
/// 
/// Features:
///   - Slide left-to-right or right-to-left transitions.
///   - Replace or push navigation with optional argument passing.
///   - Ability to clear the entire navigation stack.
///
/// Dependencies:
///   - flutter/material.dart: Core Flutter UI toolkit.
/// ======================================================================================================
library;

import 'package:flutter/material.dart';

/// Emumerated type representing the slide transition direction.
enum SlideDirection {
  leftToRight,
  rightToLeft,
}

/// Pushes a new screen onto the navigation stack with a horizontal slide animation.
/// 
/// Parameters:
/// - [context]: The current build context.
/// - [page]: The widget/screen to navigate to.
/// - [direction]: The direction of the slide transition (default: right-to-left).
void navigateWithSlide(BuildContext context, Widget page, {SlideDirection direction = SlideDirection.rightToLeft}) {
  // Define initial offset based on direction.
  final beginOffset = direction == SlideDirection.rightToLeft ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0);

  Navigator.of(context).push(
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {

        // Create a tween with a smooth easing curve.
        final tween = Tween(begin: beginOffset, end: Offset.zero).chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    ),
  );
}

/// Replaces the current screen with a new screen using a slide transition. Supports passing
/// arguments and optionally clearing the entire navigation stack.
/// 
/// Parameters:
/// - [context]: The current build context.
/// - [destination]: The widget to navigate to.
/// - [direction]: The slide animation direction (default: right-to-left).
/// - [arguments]: Optional arguments passed via RouteSettings.
/// - [clearStack]: If true, clears all previous screens from the stack.
void navigateWithSlideReplace(BuildContext context, Widget destination, {SlideDirection direction = SlideDirection.rightToLeft, Map<String, dynamic>? arguments, bool clearStack = false}) {
  final beginOffset = direction == SlideDirection.rightToLeft ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0);

  final route = PageRouteBuilder(
    settings: RouteSettings(arguments: arguments),
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (_, __, ___) => destination,
    transitionsBuilder: (_, animation, __, child) {
      final tween = Tween(begin: beginOffset, end: Offset.zero).chain(CurveTween(curve: Curves.easeInOut));
      return SlideTransition(position: animation.drive(tween), child: child);
    }
  );

  if (clearStack) {
    // Completely replace the navigation stack with this route.
    Navigator.of(context).pushAndRemoveUntil(route, (route) => false); 
  } else {
    // Replace the top route only.
    Navigator.of(context).pushReplacement(route);
  }
}