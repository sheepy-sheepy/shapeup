import 'package:shapeup/core/shared/errors.dart';
import 'package:shapeup/features/products/domain/entities/recipe_ingredient_input_entity.dart';
import 'package:shapeup/features/products/domain/entities/recipe_totals_entity.dart';
import 'package:shapeup/features/products/domain/entities/recipe_nutrition_values_entity.dart';
import 'package:shapeup/features/products/domain/entities/recipe_entity.dart';
import 'package:shapeup/features/products/domain/entities/recipe_ingredient_entity.dart';

class RecipeNutritionUseCase {
  const RecipeNutritionUseCase._();

  static RecipeTotalsEntity totalsForInputs(
    List<RecipeIngredientInputEntity> items, {
    double? cookedWeightGrams,
  }) {
    double calories = 0;
    double proteins = 0;
    double fats = 0;
    double carbs = 0;
    double ingredientsWeightGrams = 0;

    for (final item in items) {
      final ratio = item.grams / 100.0;

      calories += item.calories * ratio;
      proteins += item.proteins * ratio;
      fats += item.fats * ratio;
      carbs += item.carbs * ratio;
      ingredientsWeightGrams += item.grams;
    }

    final finalCookedWeightGrams =
        cookedWeightGrams == null || cookedWeightGrams <= 0
            ? ingredientsWeightGrams
            : cookedWeightGrams;

    return RecipeTotalsEntity(
      calories: calories,
      proteins: proteins,
      fats: fats,
      carbs: carbs,
      cookedWeightGrams: finalCookedWeightGrams,
    );
  }

  static RecipeNutritionValuesEntity per100ForRecipe({
    required RecipeEntity recipe,
    required List<RecipeIngredientEntity> ingredients,
  }) {
    double totalCalories = 0;
    double totalProteins = 0;
    double totalFats = 0;
    double totalCarbs = 0;

    for (final ingredient in ingredients) {
      final ratio = ingredient.grams / 100.0;

      totalCalories += ingredient.caloriesSnapshot * ratio;
      totalProteins += ingredient.proteinsSnapshot * ratio;
      totalFats += ingredient.fatsSnapshot * ratio;
      totalCarbs += ingredient.carbsSnapshot * ratio;
    }

    final cookedWeightGrams =
        recipe.cookedWithTareWeightGrams - recipe.tareWeightGrams;

    if (cookedWeightGrams <= 0) {
      throw const AppException(recipeCookedWeightMissingMessage);
    }

    return RecipeNutritionValuesEntity(
      calories: totalCalories / cookedWeightGrams * 100,
      proteins: totalProteins / cookedWeightGrams * 100,
      fats: totalFats / cookedWeightGrams * 100,
      carbs: totalCarbs / cookedWeightGrams * 100,
    );
  }
}
