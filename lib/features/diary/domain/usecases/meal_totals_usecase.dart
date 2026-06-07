import 'package:shapeup/features/diary/domain/entities/meal_totals_entity.dart';
import 'package:shapeup/features/diary/domain/entities/meal_item_entity.dart';

export 'package:shapeup/features/diary/domain/entities/meal_totals_entity.dart' show MealTotalsEntity;

class MealTotalsUseCase {
  const MealTotalsUseCase._();

  static MealTotalsEntity calculate(List<MealItemEntity> items) {
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

    return MealTotalsEntity(
      calories: calories,
      proteins: proteins,
      fats: fats,
      carbs: carbs,
    );
  }
}
