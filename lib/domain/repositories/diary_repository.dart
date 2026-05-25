import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../entities/diary_totals.dart';
import '../entities/local_entities.dart';

export '../entities/diary_totals.dart';
export '../entities/local_entities.dart' show Meal, MealItem;

final diaryRepositoryProvider = Provider<DiaryRepository>((ref) {
  throw UnimplementedError('DiaryRepository должен быть подключен в data-слое');
});

abstract class DiaryRepository {
  Future<void> ensureMealsForDay(String dayKey);
  Future<List<Meal>> mealsForDay(String dayKey);
  Future<List<MealItem>> mealItems(String mealId);
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
  Future<DiaryTotals> totalsForDay(String dayKey);
}
