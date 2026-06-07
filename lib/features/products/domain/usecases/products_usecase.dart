import 'package:shapeup/features/products/domain/entities/recipe_nutrition_values_entity.dart';
import 'package:shapeup/features/products/domain/repositories/products_repository.dart';
import 'package:shapeup/features/products/domain/repositories/recipes_repository.dart';
import 'package:shapeup/features/products/domain/usecases/product_form_usecase.dart';
import 'package:shapeup/features/products/domain/usecases/recipe_nutrition_usecase.dart';
export 'package:shapeup/features/products/domain/entities/recipe_nutrition_values_entity.dart' show RecipeNutritionValuesEntity;


class ProductsUseCase {
  const ProductsUseCase({
    required ProductsRepository productsRepository,
    required RecipesRepository recipesRepository,
  })  : _productsRepository = productsRepository,
        _recipesRepository = recipesRepository;

  final ProductsRepository _productsRepository;
  final RecipesRepository _recipesRepository;

  Future<List<CustomProductEntity>> customProducts(String query) {
    return _productsRepository.customProducts(query);
  }

  Future<List<FoodEntity>> baseFoodsPage(
    String query, {
    required int offset,
    int limit = 150,
  }) {
    return _productsRepository.baseFoodsPage(
      query,
      offset: offset,
      limit: limit,
    );
  }

  Future<List<RecipeEntity>> recipes(String query) {
    return _recipesRepository.recipes(query);
  }

  Future<List<RecipeIngredientEntity>> recipeIngredients(String recipeId) {
    return _recipesRepository.ingredients(recipeId);
  }

  Future<RecipeNutritionValuesEntity> per100ForRecipe(RecipeEntity recipe) async {
    final ingredients = await _recipesRepository.ingredients(recipe.id);
    return RecipeNutritionUseCase.per100ForRecipe(
      recipe: recipe,
      ingredients: ingredients,
    );
  }

  RecipeNutritionValuesEntity per100ForRecipeIngredients({
    required RecipeEntity recipe,
    required List<RecipeIngredientEntity> ingredients,
  }) {
    return RecipeNutritionUseCase.per100ForRecipe(
      recipe: recipe,
      ingredients: ingredients,
    );
  }

  double? nonNegativeNumberFromText(String value) {
    return ProductFormUseCase.nonNegativeNumberFromText(value);
  }

  double? caloriesFromMacros({
    required double? proteins,
    required double? fats,
    required double? carbs,
  }) {
    return ProductFormUseCase.caloriesFromMacros(
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
    return ProductFormUseCase.canSaveProduct(
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
    return _productsRepository.createProduct(
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
    return _productsRepository.updateProduct(
      id: id,
      name: name,
      calories: calories,
      proteins: proteins,
      fats: fats,
      carbs: carbs,
    );
  }

  Future<void> deleteProduct(String id) {
    return _productsRepository.deleteProduct(id);
  }

  Future<void> deleteRecipe(String id) {
    return _recipesRepository.deleteRecipe(id);
  }
}
