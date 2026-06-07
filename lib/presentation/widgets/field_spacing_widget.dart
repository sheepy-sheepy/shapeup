import 'package:flutter/material.dart';

import 'package:shapeup/core/design/theme.dart';

class FieldSpacingWidget extends StatelessWidget {
  const FieldSpacingWidget({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          children[i],
          if (i != children.length - 1) const SizedBox(height: AppSpacing.md),
        ],
      ],
    );
  }
}
