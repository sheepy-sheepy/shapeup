import 'package:flutter/material.dart';

import 'package:shapeup/features/products/presentation/widgets/food_section_widget.dart';

class ProductsPanelWidget extends StatelessWidget {
  const ProductsPanelWidget({
    super.key,
    required this.children,
    this.title = 'Свои продукты',
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return FoodSectionWidget(
      title: title,
      backgroundColor: const Color(0xFFEAF7EC).withValues(alpha: 0.74),
      borderColor: const Color(0xFFB8E6C2).withValues(alpha: 0.70),
      children: children,
    );
  }
}
