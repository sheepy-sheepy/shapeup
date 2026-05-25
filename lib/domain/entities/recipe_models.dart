class RecipeIngredientInput {
  final String sourceType;
  final String sourceId;
  final String name;

  /// Вес ингредиента в сыром виде.
  final double grams;

  /// КБЖУ ингредиента на 100 г в сыром виде.
  final double calories;
  final double proteins;
  final double fats;
  final double carbs;

  const RecipeIngredientInput({
    required this.sourceType,
    required this.sourceId,
    required this.name,
    required this.grams,
    required this.calories,
    required this.proteins,
    required this.fats,
    required this.carbs,
  });
}

class RecipeTotals {
  const RecipeTotals({
    required this.calories,
    required this.proteins,
    required this.fats,
    required this.carbs,
    required this.ingredientsWeightGrams,
    required this.cookedWeightGrams,
  });

  /// Суммарные КБЖУ всего рецепта.
  final double calories;
  final double proteins;
  final double fats;
  final double carbs;

  /// Сумма сырых граммов всех ингредиентов.
  final double ingredientsWeightGrams;

  /// Итоговый вес готового блюда без тары.
  final double cookedWeightGrams;

  /// Совместимость со старым кодом, где использовался totalGrams.
  double get totalGrams => cookedWeightGrams;

  double get caloriesPer100 =>
      cookedWeightGrams <= 0 ? 0 : calories / cookedWeightGrams * 100;

  double get proteinsPer100 =>
      cookedWeightGrams <= 0 ? 0 : proteins / cookedWeightGrams * 100;

  double get fatsPer100 =>
      cookedWeightGrams <= 0 ? 0 : fats / cookedWeightGrams * 100;

  double get carbsPer100 =>
      cookedWeightGrams <= 0 ? 0 : carbs / cookedWeightGrams * 100;
}
