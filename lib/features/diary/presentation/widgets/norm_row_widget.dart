import 'package:flutter/material.dart';

import 'package:shapeup/core/design/theme.dart';
import 'package:shapeup/presentation/widgets/animated_progress_bar_widget.dart';

class NormRowWidget extends StatelessWidget {
  const NormRowWidget({
    super.key,
    required this.label,
    required this.consumed,
    required this.norm,
    required this.unit,
    this.fractionDigits = 2,
  });

  final String label;
  final double consumed;
  final double norm;
  final String unit;
  final int fractionDigits;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final diff = norm - consumed;
    final exceeded = diff < 0;
    final absDiff = diff.abs();
    final progress = norm <= 0 ? 0.0 : (consumed / norm).clamp(0.0, 1.0);
    final valueStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Text(
                '${consumed.toStringAsFixed(fractionDigits)} / '
                '${norm.toStringAsFixed(fractionDigits)} $unit',
                style: valueStyle,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          AnimatedProgressBarWidget(
            value: progress,
            backgroundColor: colorScheme.surfaceContainerHighest,
            color: exceeded ? colorScheme.error : colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            exceeded
                ? 'Превышено на ${absDiff.toStringAsFixed(fractionDigits)} $unit'
                : 'Осталось ${absDiff.toStringAsFixed(fractionDigits)} $unit',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: exceeded
                      ? colorScheme.error
                      : colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
