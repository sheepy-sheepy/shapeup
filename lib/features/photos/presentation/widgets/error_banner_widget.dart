import 'package:flutter/material.dart';

import 'package:shapeup/core/shared/errors.dart';
import 'package:shapeup/core/design/theme.dart';

class ErrorBannerWidget extends StatelessWidget {
  const ErrorBannerWidget({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colors.errorContainer.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: Text(
        errorWithTitle(photosLoadErrorTitle, text),
        style: TextStyle(color: colors.onErrorContainer),
      ),
    );
  }
}
