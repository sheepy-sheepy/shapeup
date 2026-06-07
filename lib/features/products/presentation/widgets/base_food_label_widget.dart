import 'package:flutter/material.dart';

import 'package:shapeup/features/products/presentation/widgets/food_name_label_widget.dart';

class BaseFoodLabelWidget extends StatelessWidget {
  const BaseFoodLabelWidget({
    super.key,
    required this.name,
  });

  final String name;

  @override
  Widget build(BuildContext context) {
    return FoodNameLabelWidget(
      name: name,
      backgroundColor: Colors.white.withValues(alpha: 0.86),
      borderColor: Colors.white.withValues(alpha: 0.70),
    );
  }
}
