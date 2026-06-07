class CustomProductEntity {
  const CustomProductEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.calories,
    required this.proteins,
    required this.fats,
    required this.carbs,
    required this.deleted,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;
  final double calories;
  final double proteins;
  final double fats;
  final double carbs;
  final bool deleted;
  final DateTime updatedAt;
}
