class MealEntity {
  const MealEntity({
    required this.id,
    required this.userId,
    required this.dayKey,
    required this.mealType,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String dayKey;
  final String mealType;
  final DateTime updatedAt;
}
