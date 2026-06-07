import 'package:flutter/material.dart';

import 'package:shapeup/core/design/theme.dart';

class GramsInputWidget extends StatelessWidget {
  const GramsInputWidget({
    super.key,
    required this.controller,
    required this.setDialogState,
  });

  final TextEditingController controller;
  final StateSetter setDialogState;

  @override
  Widget build(BuildContext context) {
    const quickGrams = [50, 100, 150, 200];

    void setQuickGrams(int grams) {
      controller.text = grams.toString();
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
      setDialogState(() {});
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Граммы'),
          onChanged: (_) => setDialogState(() {}),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            for (final grams in quickGrams)
              ActionChip(
                label: Text('$grams г'),
                onPressed: () => setQuickGrams(grams),
              ),
          ],
        ),
      ],
    );
  }
}
