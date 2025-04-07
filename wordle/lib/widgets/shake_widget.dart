/// ===============================================================================================
/// File: shake_widget.dart
///
/// Author: Emmanuel Taylor
/// Created: April 5, 2025
/// Last Modified: April 6, 2025
///
/// Description:
///   - A reusable widget that adds a horizontal shake animation to its child.
///   - Commonly used for invalid form input feedback (e.g., wrong word).
///   - Triggered by a boolean flag and calls a callback on animation completion.
///
/// Dependencies:
///   - dart:math: Used for sine-based shake offset.
///   - flutter/material.dart: Core Flutter UI toolkit.
/// ===============================================================================================
library;

import 'dart:math';
import 'package:flutter/material.dart';

/// [ShakeWidget] applies a shaking animation fo its [child] when [trigger] becomes true.
/// 
/// Parameters:
/// - [child]: The widget to shake.
/// - [duration]: Optional custom duration (default is 500ms).
/// - [trigger]: Controls whether the animation should start.
/// - [onAnimationComplete]: Optional callback when the shake animation ends.
class ShakeWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool trigger;
  final VoidCallback? onAnimationComplete;

  const ShakeWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 500),
    required this.trigger,
    this.onAnimationComplete,
  });

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

/// [_ShakeWidgetState] handles the animation logic for shaking a widget horizontally.
/// It listens for changes to the [trigger] flag and plays the shake animation when triggered.
/// The widget uses a [SingleTickerProviderStateMixin] to provide a [vsync] for the animation.
class _ShakeWidgetState extends State<ShakeWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _wasTriggered = false;

  // Maximum horizontal distance to shake.
  static const double shakeMagnitude = 8;

  @override
  void initState() {
    super.initState();

    // Create controller and animation from 0 to 1 over given duration.
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  /// Detects when [trigger] becomes true to start the shake animation.
  @override
  void didUpdateWidget(covariant ShakeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.trigger && !_wasTriggered) {
      _wasTriggered = true;
      _controller.forward(from: 0).whenComplete(() {
        widget.onAnimationComplete?.call();
        _wasTriggered = false;
      });
    }
  }

  /// Disposes of the [AnimationController] when the widget is removed from the widget tree.
  /// Essential for preventing memory leaks and keeping the animation lifecycle clean.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Applies the calculated horizontal shake via [Transform.translate].
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, child) {
        return Transform.translate(
          offset: Offset(_shakeOffset(_animation.value), 0),
          child: child,
        );
      },
      child: widget.child,
    );
  }

  /// Calculates the horizontal offset using a sine wave based on animation progress.
  double _shakeOffset(double animationValue) {
    return sin(animationValue * pi * 10) * shakeMagnitude;
  }
}