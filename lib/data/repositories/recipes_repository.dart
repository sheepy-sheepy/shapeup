import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/recipe_models.dart';
import '../../domain/repositories/auth_repository.dart' as auth_domain;
import '../../domain/repositories/recipes_repository.dart' as domain;
import '../../core/app_errors.dart';
import '../../core/number_utils.dart';
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

  double _cookedWeightFromValues({
    required double tareWeightGrams,
    required double cookedWithTareWeightGrams,
  }) {
    return cookedWithTareWeightGrams - tareWeightGrams;
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
      throw const ValidationException(recipeMinDifferentProductsMessage);
    }
  }

  Future<void> _ensureUniqueRecipeName({
    required String name,
    String? exceptRecipeId,
  }) async {
    final user = auth.currentUser;
    if (user == null) throw const AppException(unauthorizedMessage);

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
      throw const ValidationException(recipeDuplicateMessage);
    }
  }

  void _validateCookedWeights({
    required double tareWeightGrams,
    required double cookedWithTareWeightGrams,
  }) {
    if (tareWeightGrams < 0) {
      throw const ValidationException(tareWeightNonNegativeMessage);
    }

    if (cookedWithTareWeightGrams < 0) {
      throw const ValidationException(cookedWithTareWeightNonNegativeMessage);
    }

    final hasAnyWeight = tareWeightGrams > 0 || cookedWithTareWeightGrams > 0;

    if (!hasAnyWeight) return;

    final cookedWeightGrams = _cookedWeightFromValues(
      tareWeightGrams: tareWeightGrams,
      cookedWithTareWeightGrams: cookedWithTareWeightGrams,
    );

    if (cookedWeightGrams <= 0) {
      throw const ValidationException(cookedWeightPositiveMessage);
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
    if (user == null) throw const AppException(unauthorizedMessage);

    ensureNotEmpty(name, 'Название рецепта');
    _validateIngredients(ingredients);
    _validateCookedWeights(
      tareWeightGrams: tareWeightGrams,
      cookedWithTareWeightGrams: cookedWithTareWeightGrams,
    );
    await _ensureUniqueRecipeName(name: name);

    final recipeId = _uuid.v4();
    final roundedTareWeightGrams = roundGrams(tareWeightGrams);
    final roundedCookedWithTareWeightGrams =
        roundGrams(cookedWithTareWeightGrams);

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
                grams: roundGrams(i.grams),
                caloriesSnapshot: roundKbju(i.calories),
                proteinsSnapshot: roundKbju(i.proteins),
                fatsSnapshot: roundKbju(i.fats),
                carbsSnapshot: roundKbju(i.carbs),
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

    final roundedTareWeightGrams = roundGrams(tareWeightGrams);
    final roundedCookedWithTareWeightGrams =
        roundGrams(cookedWithTareWeightGrams);

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
                grams: roundGrams(i.grams),
                caloriesSnapshot: roundKbju(i.calories),
                proteinsSnapshot: roundKbju(i.proteins),
                fatsSnapshot: roundKbju(i.fats),
                carbsSnapshot: roundKbju(i.carbs),
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
