import 'package:flutter/material.dart';

import 'package:shapeup/core/design/theme.dart';

class EmptyPhotoWidget extends StatelessWidget {
  const EmptyPhotoWidget({super.key, 
    required this.label,
    required this.hint,
    required this.assetPath,
  });

  final String label;
  final String hint;
  final String assetPath;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primaryContainer.withValues(alpha: 0.22),
            colors.primaryContainer.withValues(alpha: 0.38),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Center(
          child: Container(
            width: double.infinity,
            height: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.14),
              ),
            ),
            child: Opacity(
              opacity: 0.82,
              child: Image.asset(
                assetPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.image_not_supported_outlined,
                    size: 58,
                    color: colors.primary.withValues(alpha: 0.68),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
