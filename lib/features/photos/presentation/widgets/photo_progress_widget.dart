import 'package:flutter/material.dart';

import 'package:shapeup/core/design/theme.dart';

class PhotoProgressWidget extends StatelessWidget {
  const PhotoProgressWidget({super.key, 
    required this.selectedCount,
    required this.requiredCount,
  });

  final int selectedCount;
  final int requiredCount;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final progress = selectedCount / requiredCount;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border:
            Border.all(color: colors.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  selectedCount == requiredCount
                      ? 'Все фото выбраны'
                      : 'Выбрано $selectedCount из $requiredCount фото',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: colors.surfaceContainerHighest,
              color: selectedCount == requiredCount
                  ? colors.primary
                  : colors.tertiary,
            ),
          ),
        ],
      ),
    );
  }
}
