class FoodEntity {
  const FoodEntity({
    required this.id,
    required this.name,
    required this.calories,
    required this.proteins,
    required this.fats,
    required this.carbs,
  });

  final String id;
  final String name;
  final double calories;
  final double proteins;
  final double fats;
  final double carbs;
}
