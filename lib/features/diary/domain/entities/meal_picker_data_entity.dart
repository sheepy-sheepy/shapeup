import 'package:shapeup/features/products/domain/entities/custom_product_entity.dart';
import 'package:shapeup/features/products/domain/entities/recipe_entity.dart';

class MealPickerDataEntity {
  const MealPickerDataEntity({
    required this.customProducts,
    required this.recipes,
  });

  final List<CustomProductEntity> customProducts;
  final List<RecipeEntity> recipes;
}
