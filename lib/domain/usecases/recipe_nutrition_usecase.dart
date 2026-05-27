import '../entities/local_entities.dart';
import '../entities/recipe_models.dart';

class RecipeNutritionValues {
  const RecipeNutritionValues({
    required this.calories,
    required this.proteins,
    required this.fats,
    required this.carbs,
  });

  final double calories;
  final double proteins;
  final double fats;
  final double carbs;
}

class RecipeNutritionUseCase {
  const RecipeNutritionUseCase._();

  static RecipeTotals totalsForInputs(
    List<RecipeIngredientInput> items, {
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

    return RecipeTotals(
      calories: calories,
      proteins: proteins,
      fats: fats,
      carbs: carbs,
      cookedWeightGrams: finalCookedWeightGrams,
    );
  }

  static RecipeNutritionValues per100ForRecipe({
    required Recipe recipe,
    required List<RecipeIngredient> ingredients,
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
      throw Exception('У рецепта не указан итоговый вес готового блюда');
    }

    return RecipeNutritionValues(
      calories: totalCalories / cookedWeightGrams * 100,
      proteins: totalProteins / cookedWeightGrams * 100,
      fats: totalFats / cookedWeightGrams * 100,
      carbs: totalCarbs / cookedWeightGrams * 100,
    );
  }
}
