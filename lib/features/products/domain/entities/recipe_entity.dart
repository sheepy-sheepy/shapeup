class RecipeEntity {
  const RecipeEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.tareWeightGrams,
    required this.cookedWithTareWeightGrams,
    required this.deleted,
    required this.updatedAt,
  });

  final String id;
  final String userId;
  final String name;
  final double tareWeightGrams;
  final double cookedWithTareWeightGrams;
  final bool deleted;
  final DateTime updatedAt;
}
