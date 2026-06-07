import 'package:flutter/material.dart';

import 'package:shapeup/core/shared/extensions.dart';
import 'package:shapeup/features/products/presentation/widgets/product_label_widget.dart';
import 'package:shapeup/features/products/domain/entities/custom_product_entity.dart';

class ProductTileWidget extends StatelessWidget {
  const ProductTileWidget({
    super.key,
    required this.product,
    this.onTap,
    this.trailing,
  });

  final CustomProductEntity product;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: ProductLabelWidget(name: product.name),
      subtitle: Text(
        kbzhuPer100Text(
          calories: product.calories,
          proteins: product.proteins,
          fats: product.fats,
          carbs: product.carbs,
        ),
      ),
      onTap: onTap,
      trailing: trailing,
    );
  }
}
