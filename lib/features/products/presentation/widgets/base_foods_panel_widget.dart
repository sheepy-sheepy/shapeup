import 'package:flutter/material.dart';

import 'package:shapeup/features/products/presentation/widgets/food_section_widget.dart';

class BaseFoodsPanelWidget extends StatelessWidget {
  const BaseFoodsPanelWidget({
    super.key,
    required this.children,
    this.title = 'Готовая база продуктов',
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return FoodSectionWidget(
      title: title,
      backgroundColor: Colors.white.withValues(alpha: 0.68),
      borderColor: Colors.white.withValues(alpha: 0.48),
      children: children,
    );
  }
}
