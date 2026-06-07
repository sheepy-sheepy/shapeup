import 'package:shapeup/features/products/domain/entities/recipe_entity.dart';
import 'package:shapeup/features/products/domain/entities/recipe_ingredient_entity.dart';
import 'package:shapeup/features/products/domain/entities/recipe_ingredient_input_entity.dart';
export 'package:shapeup/features/products/domain/entities/recipe_entity.dart' show RecipeEntity;
export 'package:shapeup/features/products/domain/entities/recipe_ingredient_entity.dart' show RecipeIngredientEntity;
export 'package:shapeup/features/products/domain/entities/recipe_ingredient_input_entity.dart';
export 'package:shapeup/features/products/domain/entities/recipe_totals_entity.dart';


abstract class RecipesRepository {
  Future<List<RecipeEntity>> recipes([String query = '']);
  Future<RecipeEntity?> recipeById(String recipeId);
  Future<List<RecipeIngredientEntity>> ingredients(String recipeId);
  Future<void> createRecipe({
    required String name,
    required List<RecipeIngredientInputEntity> ingredients,
    double tareWeightGrams = 0,
    double cookedWithTareWeightGrams = 0,
  });
  Future<void> updateRecipe({
    required String recipeId,
    required String name,
    required List<RecipeIngredientInputEntity> ingredients,
    double tareWeightGrams = 0,
    double cookedWithTareWeightGrams = 0,
  });
  Future<void> deleteRecipe(String recipeId);
}
