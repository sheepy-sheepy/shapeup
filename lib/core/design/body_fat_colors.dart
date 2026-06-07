import 'package:flutter/material.dart';

Color bodyFatColor(BuildContext context, double value) {
  final colors = Theme.of(context).colorScheme;
  final t = ((value - 10.0) / 25.0).clamp(0.0, 1.0).toDouble();

  return Color.lerp(
    colors.primaryContainer.withValues(alpha: 0.82),
    const Color(0xFFFFF2B8).withValues(alpha: 0.92),
    t,
  )!;
}

Color bodyFatBorderColor(BuildContext context, double value) {
  final colors = Theme.of(context).colorScheme;
  final t = ((value - 10.0) / 25.0).clamp(0.0, 1.0).toDouble();

  return Color.lerp(
    colors.primary.withValues(alpha: 0.18),
    const Color(0xFFE6C85C).withValues(alpha: 0.34),
    t,
  )!;
}
