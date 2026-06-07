import 'package:flutter/material.dart';

import 'package:shapeup/features/products/presentation/widgets/food_name_label_widget.dart';

class RecipeLabelWidget extends StatelessWidget {
  const RecipeLabelWidget({
    super.key,
    required this.name,
  });

  final String name;

  @override
  Widget build(BuildContext context) {
    return FoodNameLabelWidget(
      name: name,
      backgroundColor: const Color(0xFFDDEEFF).withValues(alpha: 0.90),
      borderColor: const Color(0xFFBBD8F4).withValues(alpha: 0.82),
    );
  }
}
