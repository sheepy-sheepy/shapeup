class RecipeIngredientEntity {
  const RecipeIngredientEntity({
    required this.id,
    required this.recipeId,
    required this.sourceType,
    required this.sourceId,
    required this.nameSnapshot,
    required this.grams,
    required this.caloriesSnapshot,
    required this.proteinsSnapshot,
    required this.fatsSnapshot,
    required this.carbsSnapshot,
  });

  final String id;
  final String recipeId;
  final String sourceType;
  final String sourceId;
  final String nameSnapshot;
  final double grams;
  final double caloriesSnapshot;
  final double proteinsSnapshot;
  final double fatsSnapshot;
  final double carbsSnapshot;
}
