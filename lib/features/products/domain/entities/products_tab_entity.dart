import 'package:shapeup/features/products/domain/entities/custom_product_entity.dart';

class ProductsTabEntity {
  const ProductsTabEntity({
    required this.customProducts,
  });

  final List<CustomProductEntity> customProducts;
}
