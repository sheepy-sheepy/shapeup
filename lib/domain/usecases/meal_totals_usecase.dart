import '../entities/local_entities.dart';

class MealTotalsResult {
  const MealTotalsResult({
    required this.calories,
    required this.proteins,
    required this.fats,
    required this.carbs,
  });

  final double calories;
  final double proteins;
  final double fats;
  final double carbs;
}

class MealTotalsUseCase {
  const MealTotalsUseCase._();

  static MealTotalsResult calculate(List<MealItem> items) {
    double calories = 0;
    double proteins = 0;
    double fats = 0;
    double carbs = 0;

    for (final item in items) {
      final ratio = item.grams / 100.0;

      calories += item.caloriesSnapshot * ratio;
      proteins += item.proteinsSnapshot * ratio;
      fats += item.fatsSnapshot * ratio;
      carbs += item.carbsSnapshot * ratio;
    }

    return MealTotalsResult(
      calories: calories,
      proteins: proteins,
      fats: fats,
      carbs: carbs,
    );
  }
}
