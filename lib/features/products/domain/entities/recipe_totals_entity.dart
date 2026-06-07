class RecipeTotalsEntity {
  const RecipeTotalsEntity({
    required this.calories,
    required this.proteins,
    required this.fats,
    required this.carbs,
    required this.cookedWeightGrams,
  });

  final double calories;
  final double proteins;
  final double fats;
  final double carbs;
  final double cookedWeightGrams;

  double get caloriesPer100 =>
      cookedWeightGrams <= 0 ? 0 : calories / cookedWeightGrams * 100;

  double get proteinsPer100 =>
      cookedWeightGrams <= 0 ? 0 : proteins / cookedWeightGrams * 100;

  double get fatsPer100 =>
      cookedWeightGrams <= 0 ? 0 : fats / cookedWeightGrams * 100;

  double get carbsPer100 =>
      cookedWeightGrams <= 0 ? 0 : carbs / cookedWeightGrams * 100;
}
