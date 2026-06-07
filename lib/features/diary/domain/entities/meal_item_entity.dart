class MealItemEntity {
  const MealItemEntity({
    required this.id,
    required this.mealId,
    required this.sourceType,
    required this.sourceId,
    required this.nameSnapshot,
    required this.grams,
    required this.caloriesSnapshot,
    required this.proteinsSnapshot,
    required this.fatsSnapshot,
    required this.carbsSnapshot,
    required this.createdAt,
  });

  final String id;
  final String mealId;
  final String sourceType;
  final String sourceId;
  final String nameSnapshot;
  final double grams;
  final double caloriesSnapshot;
  final double proteinsSnapshot;
  final double fatsSnapshot;
  final double carbsSnapshot;
  final DateTime createdAt;
}
