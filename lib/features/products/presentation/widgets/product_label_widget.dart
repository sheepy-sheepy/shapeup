import 'package:flutter/material.dart';

import 'package:shapeup/features/products/presentation/widgets/food_name_label_widget.dart';

class ProductLabelWidget extends StatelessWidget {
  const ProductLabelWidget({
    super.key,
    required this.name,
  });

  final String name;

  @override
  Widget build(BuildContext context) {
    return FoodNameLabelWidget(
      name: name,
      backgroundColor: const Color(0xFFDDF3E2).withValues(alpha: 0.90),
      borderColor: const Color(0xFFB8E6C2).withValues(alpha: 0.82),
    );
  }
}
