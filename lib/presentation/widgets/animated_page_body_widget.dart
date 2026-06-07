import 'package:flutter/material.dart';

import 'package:shapeup/core/design/theme.dart';

class AnimatedPageBodyWidget extends StatelessWidget {
  const AnimatedPageBodyWidget({
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
