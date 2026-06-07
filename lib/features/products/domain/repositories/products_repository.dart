
import 'package:shapeup/features/products/domain/entities/custom_product_entity.dart';
import 'package:shapeup/features/products/domain/entities/food_entity.dart';

export 'package:shapeup/features/products/domain/entities/custom_product_entity.dart' show CustomProductEntity;
export 'package:shapeup/features/products/domain/entities/food_entity.dart' show FoodEntity;


abstract class ProductsRepository {
  Future<List<CustomProductEntity>> customProducts(String query);
  Future<List<FoodEntity>> baseFoodsPage(
    String query, {
    required int offset,
    int limit = 150,
  });
  Future<void> createProduct({
    required String name,
    required double calories,
    required double proteins,
    required double fats,
    required double carbs,
  });
  Future<void> updateProduct({
    required String id,
    required String name,
    required double calories,
    required double proteins,
    required double fats,
    required double carbs,
  });
  Future<void> deleteProduct(String id);
}
