
import 'package:shapeup/features/diary/domain/entities/diary_totals_entity.dart';
import 'package:shapeup/features/diary/domain/entities/meal_entity.dart';
import 'package:shapeup/features/diary/domain/entities/meal_item_entity.dart';

export 'package:shapeup/features/diary/domain/entities/diary_totals_entity.dart' show DiaryTotalsEntity;
export 'package:shapeup/features/diary/domain/entities/meal_entity.dart' show MealEntity;
export 'package:shapeup/features/diary/domain/entities/meal_item_entity.dart' show MealItemEntity;


abstract class DiaryRepository {
  Future<void> ensureMealsForDay(String dayKey);
  Future<List<MealEntity>> mealsForDay(String dayKey);
  Future<List<MealItemEntity>> mealItems(String mealId);
  Future<void> addMealItem({
    required String mealId,
    required String sourceType,
    required String sourceId,
    required String name,
    required double grams,
    required double calories,
    required double proteins,
    required double fats,
    required double carbs,
  });
  Future<void> updateMealItemGrams({
    required String mealItemId,
    required double grams,
  });
  Future<void> deleteMealItem(String mealItemId);
  Future<void> updateWater(String dayKey, double waterMl);
  Future<DiaryTotalsEntity> totalsForDay(String dayKey);
}
