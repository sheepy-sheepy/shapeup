import 'package:flutter/material.dart';

import '../../core/design.dart';

class AnimatedProgressBar extends StatelessWidget {
  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.minHeight = 8,
    this.backgroundColor,
    this.color,
  });

  final double value;
  final double minHeight;
  final Color? backgroundColor;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final target = value.clamp(0.0, 1.0).toDouble();

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: target),
      duration: AppMotion.medium,
      curve: Curves.easeOutCubic,
      builder: (context, animatedValue, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: minHeight,
            value: animatedValue,
            backgroundColor: backgroundColor,
            color: color,
          ),
        );
      },
    );
  }
}

class AnimatedPageBody extends StatelessWidget {
  const AnimatedPageBody({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(
        milliseconds: AppMotion.slow.inMilliseconds + delay.inMilliseconds,
      ),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        final opacity = value.clamp(0.0, 1.0).toDouble();
        return Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(0, (1 - opacity) * 14),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}