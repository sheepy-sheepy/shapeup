import 'package:shapeup/core/shared/errors.dart';
import 'package:shapeup/core/shared/extensions.dart';
import 'package:shapeup/features/products/domain/usecases/products_usecase.dart';
import 'package:shapeup/features/products/presentation/controllers/recipe_search_controller.dart';
import 'package:shapeup/features/products/domain/entities/custom_product_entity.dart';
import 'package:shapeup/features/products/domain/entities/recipe_entity.dart';
import 'package:shapeup/features/products/domain/entities/recipe_ingredient_entity.dart';


class ProductsController {
  const ProductsController(this._productsUseCase);

  final ProductsUseCase _productsUseCase;

  Future<List<CustomProductEntity>> customProducts(String query) {
    return _productsUseCase.customProducts(query);
  }

  Future<List<RecipeEntity>> recipes(String query) async {
    final allRecipes = await _productsUseCase.recipes('');
    return RecipeSearchController.filterAndSortBySearch(allRecipes, query);
  }

  Future<List<RecipeIngredientEntity>> recipeIngredients(String recipeId) {
    return _productsUseCase.recipeIngredients(recipeId);
  }

  Future<String> recipeKbzhuPer100Text(RecipeEntity recipe) async {
    final per100 = await _productsUseCase.per100ForRecipe(recipe);
    return kbzhuPer100Text(
      calories: per100.calories,
      proteins: per100.proteins,
      fats: per100.fats,
      carbs: per100.carbs,
    );
  }

  Future<RecipeNutritionValuesEntity> recipePer100(RecipeEntity recipe) {
    return _productsUseCase.per100ForRecipe(recipe);
  }

  String recipeKbzhuPer100TextFromIngredients({
    required RecipeEntity recipe,
    required List<RecipeIngredientEntity> ingredients,
  }) {
    try {
      final per100 = _productsUseCase.per100ForRecipeIngredients(
        recipe: recipe,
        ingredients: ingredients,
      );

      return kbzhuPer100Text(
        calories: per100.calories,
        proteins: per100.proteins,
        fats: per100.fats,
        carbs: per100.carbs,
      );
    } catch (_) {
      return recipeCookedWeightMissingMessage;
    }
  }

  double? nonNegativeNumberFromText(String value) {
    return _productsUseCase.nonNegativeNumberFromText(value);
  }

  double? caloriesFromMacros({
    required double? proteins,
    required double? fats,
    required double? carbs,
  }) {
    return _productsUseCase.caloriesFromMacros(
      proteins: proteins,
      fats: fats,
      carbs: carbs,
    );
  }

  bool canSaveProduct({
    required String name,
    required double? calories,
    required double? proteins,
    required double? fats,
    required double? carbs,
  }) {
    return _productsUseCase.canSaveProduct(
      name: name,
      calories: calories,
      proteins: proteins,
      fats: fats,
      carbs: carbs,
    );
  }

  Future<void> createProduct({
    required String name,
    required double calories,
    required double proteins,
    required double fats,
    required double carbs,
  }) {
    return _productsUseCase.createProduct(
      name: name,
      calories: calories,
      proteins: proteins,
      fats: fats,
      carbs: carbs,
    );
  }

  Future<void> updateProduct({
    required String id,
    required String name,
    required double calories,
    required double proteins,
    required double fats,
    required double carbs,
  }) {
    return _productsUseCase.updateProduct(
      id: id,
      name: name,
      calories: calories,
      proteins: proteins,
      fats: fats,
      carbs: carbs,
    );
  }

  Future<void> deleteProduct(String id) {
    return _productsUseCase.deleteProduct(id);
  }

  Future<void> deleteRecipe(String id) {
    return _productsUseCase.deleteRecipe(id);
  }
}
