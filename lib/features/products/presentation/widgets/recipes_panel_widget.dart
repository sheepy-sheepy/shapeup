import 'package:flutter/material.dart';

import 'package:shapeup/features/products/presentation/widgets/food_section_widget.dart';

class RecipesPanelWidget extends StatelessWidget {
  const RecipesPanelWidget({
    super.key,
    required this.children,
    this.title = 'Свои рецепты',
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return FoodSectionWidget(
      title: title,
      backgroundColor: const Color(0xFFEAF4FF).withValues(alpha: 0.74),
      borderColor: const Color(0xFFBBD8F4).withValues(alpha: 0.70),
      children: children,
    );
  }
}
