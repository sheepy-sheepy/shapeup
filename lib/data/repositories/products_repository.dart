import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/repositories/auth_repository.dart' as auth_domain;
import '../../domain/repositories/products_repository.dart' as domain;
import '../../core/app_errors.dart';
import '../local/app_database.dart';

final productsRepositoryProvider = Provider<domain.ProductsRepository>((ref) {
  return ProductsRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(auth_domain.authRepositoryProvider),
  );
});

class ProductsRepository implements domain.ProductsRepository {
  ProductsRepository(this.db, this.auth);

  final AppDatabase db;
  final auth_domain.AuthRepository auth;
  final _uuid = const Uuid();

  double _roundTo(double value, int decimals) {
    var factor = 1.0;
    for (var i = 0; i < decimals; i++) {
      factor *= 10.0;
    }
    return (value * factor).roundToDouble() / factor;
  }

  double _kbju(double value) => _roundTo(value, 2);

  static const int _baseFoodsLimit = 150;

  List<Food>? _allBaseFoodsCache;

  String _normalize(String value) {
    return value.trim().toLowerCase();
  }

  Future<List<Food>> _allBaseFoods() async {
    final cached = _allBaseFoodsCache;
    if (cached != null) return cached;

    final rows = await db.select(db.foods).get();
    _allBaseFoodsCache = rows;
    return rows;
  }

  List<T> _slice<T>(
    List<T> items, {
    required int offset,
    required int limit,
  }) {
    if (offset >= items.length) return <T>[];
    return items.skip(offset).take(limit).toList();
  }

  List<T> _searchByPriority<T>({
    required Iterable<T> items,
    required String query,
    required String Function(T item) nameOf,
    required int offset,
    required int limit,
  }) {
    final q = _normalize(query);

    if (q.isEmpty) {
      final result = items.toList();
      return _slice(result, offset: offset, limit: limit);
    }

    final startsWith = <_SearchHit<T>>[];
    final contains = <_SearchHit<T>>[];

    for (final item in items) {
      final normalizedName = _normalize(nameOf(item));

      if (normalizedName.startsWith(q)) {
        startsWith.add(
          _SearchHit(
            item: item,
            normalizedName: normalizedName,
          ),
        );
      } else if (normalizedName.contains(q)) {
        contains.add(
          _SearchHit(
            item: item,
            normalizedName: normalizedName,
          ),
        );
      }
    }

    int compareHits(_SearchHit<T> a, _SearchHit<T> b) {
      return a.normalizedName.compareTo(b.normalizedName);
    }

    startsWith.sort(compareHits);
    contains.sort(compareHits);

    final result = <T>[
      for (final hit in startsWith) hit.item,
      for (final hit in contains) hit.item,
    ];

    return _slice(result, offset: offset, limit: limit);
  }

  @override
  Future<List<CustomProduct>> customProducts(String query) async {
    final user = auth.currentUser;
    if (user == null) return [];

    final rows = await (db.select(db.customProducts)
          ..where((t) => t.userId.equals(user.id) & t.deleted.equals(false))
          ..orderBy([
            (t) => drift.OrderingTerm.asc(t.name),
            (t) => drift.OrderingTerm.asc(t.id),
          ]))
        .get();

    return _searchByPriority<CustomProduct>(
      items: rows,
      query: query,
      nameOf: (item) => item.name,
      offset: 0,
      limit: rows.length,
    );
  }

  @override
  Future<List<Food>> baseFoodsPage(
    String query, {
    required int offset,
    int limit = _baseFoodsLimit,
  }) async {
    final q = _normalize(query);

    if (q.isEmpty) {
      return (db.select(db.foods)
            ..orderBy([
              (t) => drift.OrderingTerm.asc(t.name),
              (t) => drift.OrderingTerm.asc(t.id),
            ])
            ..limit(limit, offset: offset))
          .get();
    }

    final rows = await _allBaseFoods();

    return _searchByPriority<Food>(
      items: rows,
      query: query,
      nameOf: (item) => item.name,
      offset: offset,
      limit: limit,
    );
  }

  /// Старый метод оставлен для других экранов:
  /// recipe_editor_screen.dart, meal_item_picker_screen.dart и т.д.
  @override
  Future<List<Food>> baseFoods(String query) {
    return baseFoodsPage(
      query,
      offset: 0,
      limit: _baseFoodsLimit,
    );
  }

  Future<void> _ensureUniqueProductName({
    required String name,
    String? exceptProductId,
  }) async {
    final user = auth.currentUser;
    if (user == null) throw Exception('Пользователь не авторизован');

    final normalizedName = _normalize(name);
    if (normalizedName.isEmpty) return;

    final customRows = await (db.select(db.customProducts)
          ..where((t) => t.userId.equals(user.id) & t.deleted.equals(false)))
        .get();

    final duplicateCustom = customRows.any((product) {
      if (exceptProductId != null && product.id == exceptProductId) {
        return false;
      }

      return _normalize(product.name) == normalizedName;
    });

    if (duplicateCustom) {
      throw const ValidationException(
        'Продукт с таким названием уже есть в своих продуктах',
      );
    }

    final baseRows = await _allBaseFoods();
    final duplicateBase = baseRows.any(
      (food) => _normalize(food.name) == normalizedName,
    );

    if (duplicateBase) {
      throw const ValidationException(
        'Продукт с таким названием уже есть в готовой базе продуктов',
      );
    }
  }

  @override
  Future<void> createProduct({
    required String name,
    required double calories,
    required double proteins,
    required double fats,
    required double carbs,
  }) async {
    final user = auth.currentUser;
    if (user == null) throw Exception('Пользователь не авторизован');

    ensureNotEmpty(name, 'Название продукта');
    ensureNonNegative(calories, 'Калории');
    ensureNonNegative(proteins, 'Белки');
    ensureNonNegative(fats, 'Жиры');
    ensureNonNegative(carbs, 'Углеводы');

    await _ensureUniqueProductName(name: name);

    final id = _uuid.v4();

    final roundedCalories = _kbju(calories);
    final roundedProteins = _kbju(proteins);
    final roundedFats = _kbju(fats);
    final roundedCarbs = _kbju(carbs);

    await db.into(db.customProducts).insert(
          CustomProductsCompanion.insert(
            id: id,
            userId: user.id,
            name: name,
            calories: roundedCalories,
            proteins: roundedProteins,
            fats: roundedFats,
            carbs: roundedCarbs,
          ),
        );

  }

  @override
  Future<void> updateProduct({
    required String id,
    required String name,
    required double calories,
    required double proteins,
    required double fats,
    required double carbs,
  }) async {
    ensureNotEmpty(name, 'Название продукта');
    ensureNonNegative(calories, 'Калории');
    ensureNonNegative(proteins, 'Белки');
    ensureNonNegative(fats, 'Жиры');
    ensureNonNegative(carbs, 'Углеводы');

    await _ensureUniqueProductName(name: name, exceptProductId: id);

    final roundedCalories = _kbju(calories);
    final roundedProteins = _kbju(proteins);
    final roundedFats = _kbju(fats);
    final roundedCarbs = _kbju(carbs);

    await (db.update(db.customProducts)..where((t) => t.id.equals(id))).write(
      CustomProductsCompanion(
        name: drift.Value(name),
        calories: drift.Value(roundedCalories),
        proteins: drift.Value(roundedProteins),
        fats: drift.Value(roundedFats),
        carbs: drift.Value(roundedCarbs),
      ),
    );

  }

  @override
  Future<void> deleteProduct(String id) async {
    await (db.update(db.customProducts)..where((t) => t.id.equals(id))).write(
      const CustomProductsCompanion(
        deleted: drift.Value(true),
      ),
    );

  }

}

class _SearchHit<T> {
  const _SearchHit({
    required this.item,
    required this.normalizedName,
  });

  final T item;
  final String normalizedName;
}
