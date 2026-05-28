import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../entities/local_entities.dart';
import '../entities/recipe_models.dart';
import '../../core/app_errors.dart';

export '../entities/local_entities.dart' show Recipe, RecipeIngredient;
export '../entities/recipe_models.dart';

final recipesRepositoryProvider = Provider<RecipesRepository>((ref) {
  throw UnimplementedError(recipesRepositoryNotConnectedMessage);
});

abstract class RecipesRepository {
  Future<List<Recipe>> recipes([String query = '']);
  Future<Recipe?> recipeById(String recipeId);
  Future<List<RecipeIngredient>> ingredients(String recipeId);
  Future<void> createRecipe({
    required String name,
    required List<RecipeIngredientInput> ingredients,
    double tareWeightGrams = 0,
    double cookedWithTareWeightGrams = 0,
  });
  Future<void> updateRecipe({
    required String recipeId,
    required String name,
    required List<RecipeIngredientInput> ingredients,
    double tareWeightGrams = 0,
    double cookedWithTareWeightGrams = 0,
  });
  Future<void> deleteRecipe(String recipeId);
}
