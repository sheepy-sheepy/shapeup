import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../entities/local_entities.dart';

export '../entities/local_entities.dart' show CustomProduct, Food;

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  throw UnimplementedError('ProductsRepository должен быть подключен в data-слое');
});

abstract class ProductsRepository {
  Future<List<CustomProduct>> customProducts(String query);
  Future<List<Food>> baseFoodsPage(
    String query, {
    required int offset,
    int limit = 150,
  });
  Future<List<Food>> baseFoods(String query);
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
