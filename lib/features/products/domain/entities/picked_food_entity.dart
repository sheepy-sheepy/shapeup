class PickedFoodEntity {
  final String id;
  final String sourceType;
  final String name;
  final double calories;
  final double proteins;
  final double fats;
  final double carbs;

  const PickedFoodEntity({
    required this.id,
    required this.sourceType,
    required this.name,
    required this.calories,
    required this.proteins,
    required this.fats,
    required this.carbs,
  });
}
