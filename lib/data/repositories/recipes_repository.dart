import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/recipe_models.dart';
import '../../domain/usecases/recipe_nutrition_usecase.dart';
import '../../domain/repositories/auth_repository.dart' as auth_domain;
import '../../domain/repositories/recipes_repository.dart' as domain;
import '../../core/app_errors.dart';
import '../local/app_database.dart';

final recipesRepositoryProvider = Provider<domain.RecipesRepository>((ref) {
  return RecipesRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(auth_domain.authRepositoryProvider),
  );
});

class RecipesRepository implements domain.RecipesRepository {
  RecipesRepository(this.db, this.auth);

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
  double _grams(double value) => _roundTo(value, 1);

  @override
  Future<List<Recipe>> recipes([String query = '']) {
    final user = auth.currentUser;
    if (user == null) return Future.value([]);

    final normalizedQuery = query.trim();

    return (db.select(db.recipes)
          ..where(
            (t) =>
                t.userId.equals(user.id) &
                t.deleted.equals(false) &
                t.name.contains(normalizedQuery),
          )
          ..orderBy([
            (t) => drift.OrderingTerm.asc(t.name),
            (t) => drift.OrderingTerm.asc(t.id),
          ]))
        .get();
  }

  @override
  Future<Recipe?> recipeById(String recipeId) {
    return (db.select(db.recipes)..where((t) => t.id.equals(recipeId)))
        .getSingleOrNull();
  }

  @override
  Future<List<RecipeIngredient>> ingredients(String recipeId) {
    return (db.select(db.recipeIngredients)
          ..where((t) => t.recipeId.equals(recipeId)))
        .get();
  }

  @override
  double cookedWeightFromValues({
    required double tareWeightGrams,
    required double cookedWithTareWeightGrams,
  }) {
    return cookedWithTareWeightGrams - tareWeightGrams;
  }

  @override
  double cookedWeightFromRecipe(
    Recipe recipe, {
    double fallbackIngredientsWeightGrams = 0,
  }) {
    final cookedWeight = cookedWeightFromValues(
      tareWeightGrams: recipe.tareWeightGrams,
      cookedWithTareWeightGrams: recipe.cookedWithTareWeightGrams,
    );

    if (cookedWeight > 0) return cookedWeight;

    // Для старых рецептов, созданных до добавления веса готового блюда.
    return fallbackIngredientsWeightGrams;
  }

  @override
  Future<RecipeTotals> calculateTotals(
    List<RecipeIngredientInput> items, {
    double? cookedWeightGrams,
  }) async {
    return RecipeNutritionUseCase.totalsForInputs(
      items,
      cookedWeightGrams: cookedWeightGrams,
    );
  }


  void _validateIngredients(List<RecipeIngredientInput> ingredients) {
    ensureMinCount(ingredients.length, 2, 'Количество продуктов в рецепте');

    final distinctProducts = <String>{};

    for (final item in ingredients) {
      ensurePositive(item.grams, 'Граммы ингредиента');
      ensureNonNegative(item.calories, 'Калории');
      ensureNonNegative(item.proteins, 'Белки');
      ensureNonNegative(item.fats, 'Жиры');
      ensureNonNegative(item.carbs, 'Углеводы');

      distinctProducts.add('${item.sourceType}:${item.sourceId}');
    }

    if (distinctProducts.length < 2) {
      throw const ValidationException(
        'В рецепте должно быть минимум 2 разных продукта',
      );
    }
  }

  Future<void> _ensureUniqueRecipeName({
    required String name,
    String? exceptRecipeId,
  }) async {
    final user = auth.currentUser;
    if (user == null) throw Exception('Пользователь не авторизован');

    final normalizedName = name.trim().toLowerCase();
    if (normalizedName.isEmpty) return;

    final rows = await (db.select(db.recipes)
          ..where((t) => t.userId.equals(user.id) & t.deleted.equals(false)))
        .get();

    final duplicate = rows.any((recipe) {
      if (exceptRecipeId != null && recipe.id == exceptRecipeId) {
        return false;
      }

      return recipe.name.trim().toLowerCase() == normalizedName;
    });

    if (duplicate) {
      throw const ValidationException(
        'Рецепт с таким названием уже есть в своих рецептах',
      );
    }
  }

  void _validateCookedWeights({
    required double tareWeightGrams,
    required double cookedWithTareWeightGrams,
  }) {
    if (tareWeightGrams < 0) {
      throw Exception('Вес тары не может быть меньше 0');
    }

    if (cookedWithTareWeightGrams < 0) {
      throw Exception('Вес готового блюда с тарой не может быть меньше 0');
    }

    final hasAnyWeight = tareWeightGrams > 0 || cookedWithTareWeightGrams > 0;

    // Пока оставлено для совместимости со старым экраном рецепта:
    // старый код еще не передает эти значения.
    if (!hasAnyWeight) return;

    final cookedWeightGrams = cookedWeightFromValues(
      tareWeightGrams: tareWeightGrams,
      cookedWithTareWeightGrams: cookedWithTareWeightGrams,
    );

    if (cookedWeightGrams <= 0) {
      throw Exception(
        'Итоговый вес готового блюда должен быть больше 0',
      );
    }
  }

  @override
  Future<void> createRecipe({
    required String name,
    required List<RecipeIngredientInput> ingredients,
    double tareWeightGrams = 0,
    double cookedWithTareWeightGrams = 0,
  }) async {
    final user = auth.currentUser;
    if (user == null) throw Exception('Пользователь не авторизован');

    ensureNotEmpty(name, 'Название рецепта');
    _validateIngredients(ingredients);
    _validateCookedWeights(
      tareWeightGrams: tareWeightGrams,
      cookedWithTareWeightGrams: cookedWithTareWeightGrams,
    );
    await _ensureUniqueRecipeName(name: name);

    final recipeId = _uuid.v4();
    final roundedTareWeightGrams = _grams(tareWeightGrams);
    final roundedCookedWithTareWeightGrams = _grams(cookedWithTareWeightGrams);

    await db.transaction(() async {
      await db.into(db.recipes).insert(
            RecipesCompanion.insert(
              id: recipeId,
              userId: user.id,
              name: name,
              tareWeightGrams: drift.Value(roundedTareWeightGrams),
              cookedWithTareWeightGrams:
                  drift.Value(roundedCookedWithTareWeightGrams),
            ),
          );

      for (final i in ingredients) {
        await db.into(db.recipeIngredients).insert(
              RecipeIngredientsCompanion.insert(
                id: _uuid.v4(),
                recipeId: recipeId,
                sourceType: i.sourceType,
                sourceId: i.sourceId,
                nameSnapshot: i.name,
                grams: _grams(i.grams),
                caloriesSnapshot: _kbju(i.calories),
                proteinsSnapshot: _kbju(i.proteins),
                fatsSnapshot: _kbju(i.fats),
                carbsSnapshot: _kbju(i.carbs),
              ),
            );
      }

    });
  }

  @override
  Future<void> updateRecipe({
    required String recipeId,
    required String name,
    required List<RecipeIngredientInput> ingredients,
    double tareWeightGrams = 0,
    double cookedWithTareWeightGrams = 0,
  }) async {
    ensureNotEmpty(name, 'Название рецепта');
    _validateIngredients(ingredients);
    _validateCookedWeights(
      tareWeightGrams: tareWeightGrams,
      cookedWithTareWeightGrams: cookedWithTareWeightGrams,
    );
    await _ensureUniqueRecipeName(
      name: name,
      exceptRecipeId: recipeId,
    );

    final roundedTareWeightGrams = _grams(tareWeightGrams);
    final roundedCookedWithTareWeightGrams = _grams(cookedWithTareWeightGrams);

    await db.transaction(() async {
      await (db.update(db.recipes)..where((t) => t.id.equals(recipeId))).write(
        RecipesCompanion(
          name: drift.Value(name),
          tareWeightGrams: drift.Value(roundedTareWeightGrams),
          cookedWithTareWeightGrams:
              drift.Value(roundedCookedWithTareWeightGrams),
        ),
      );

      await (db.delete(db.recipeIngredients)
            ..where((t) => t.recipeId.equals(recipeId)))
          .go();

      for (final i in ingredients) {
        await db.into(db.recipeIngredients).insert(
              RecipeIngredientsCompanion.insert(
                id: _uuid.v4(),
                recipeId: recipeId,
                sourceType: i.sourceType,
                sourceId: i.sourceId,
                nameSnapshot: i.name,
                grams: _grams(i.grams),
                caloriesSnapshot: _kbju(i.calories),
                proteinsSnapshot: _kbju(i.proteins),
                fatsSnapshot: _kbju(i.fats),
                carbsSnapshot: _kbju(i.carbs),
              ),
            );
      }

    });
  }

  @override
  Future<void> deleteRecipe(String recipeId) async {
    await (db.update(db.recipes)..where((t) => t.id.equals(recipeId))).write(
      const RecipesCompanion(
        deleted: drift.Value(true),
      ),
    );

  }

}
