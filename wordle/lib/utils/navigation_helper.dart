import 'package:flutter/material.dart';

enum SlideDirection {
  leftToRight,
  rightToLeft,
}

/// Navigates to a new screen with a slide transition.
void navigateWithSlide(BuildContext context, Widget page, {SlideDirection direction = SlideDirection.rightToLeft}) {
  final beginOffset = direction == SlideDirection.rightToLeft ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0);

  Navigator.of(context).push(
    PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween(begin: beginOffset, end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    ),
  );
}

void navigateWithSlideReplace(BuildContext context, Widget destination, {SlideDirection direction = SlideDirection.rightToLeft, Map<String, dynamic>? arguments}) {
  final beginOffset = direction == SlideDirection.rightToLeft ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0);

  Navigator.of(context).pushReplacement(
    PageRouteBuilder(
      settings: RouteSettings(arguments: arguments),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) => destination,
      transitionsBuilder: (_, animation, __, child) {
        final tween = Tween(begin: beginOffset, end: Offset.zero).chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
    ),
  );
}