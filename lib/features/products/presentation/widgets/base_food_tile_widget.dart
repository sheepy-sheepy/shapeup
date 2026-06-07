import 'package:flutter/material.dart';

import 'package:shapeup/core/shared/extensions.dart';
import 'package:shapeup/features/products/presentation/widgets/base_food_label_widget.dart';
import 'package:shapeup/features/products/domain/entities/food_entity.dart';

class BaseFoodTileWidget extends StatelessWidget {
  const BaseFoodTileWidget({
    super.key,
    required this.food,
    this.onTap,
    this.trailing,
  });

  final FoodEntity food;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: BaseFoodLabelWidget(name: food.name),
      subtitle: Text(
        kbzhuPer100Text(
          calories: food.calories,
          proteins: food.proteins,
          fats: food.fats,
          carbs: food.carbs,
        ),
      ),
      onTap: onTap,
      trailing: trailing,
    );
  }
}
