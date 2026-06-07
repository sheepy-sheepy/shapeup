class RecipeIngredientInputEntity {
  final String sourceType;
  final String sourceId;
  final String name;
  final double grams;
  final double calories;
  final double proteins;
  final double fats;
  final double carbs;

  const RecipeIngredientInputEntity({
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
