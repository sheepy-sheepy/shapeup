import 'package:flutter/material.dart';

import 'package:shapeup/core/design/theme.dart';

class AnimatedProgressBarWidget extends StatelessWidget {
  const AnimatedProgressBarWidget({
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
