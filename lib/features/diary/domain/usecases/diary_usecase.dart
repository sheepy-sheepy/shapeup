import 'package:shapeup/features/diary/domain/repositories/diary_repository.dart';
import 'package:shapeup/features/diary/domain/usecases/meal_item_grams_usecase.dart';
import 'package:shapeup/features/diary/domain/usecases/meal_totals_usecase.dart';
import 'package:shapeup/features/diary/domain/usecases/water_intake_usecase.dart';


class DiaryUseCase {
  const DiaryUseCase(this._diaryRepository);

  final DiaryRepository _diaryRepository;

  Future<List<MealItemEntity>> mealItems(String mealId) {
    return _diaryRepository.mealItems(mealId);
  }

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
  }) {
    return _diaryRepository.addMealItem(
      mealId: mealId,
      sourceType: sourceType,
      sourceId: sourceId,
      name: name,
      grams: grams,
      calories: calories,
      proteins: proteins,
      fats: fats,
      carbs: carbs,
    );
  }

  Future<void> updateMealItemGrams({
    required String mealItemId,
    required double grams,
  }) {
    return _diaryRepository.updateMealItemGrams(
      mealItemId: mealItemId,
      grams: grams,
    );
  }

  Future<void> deleteMealItem(String mealItemId) {
    return _diaryRepository.deleteMealItem(mealItemId);
  }

  Future<DiaryTotalsEntity> totalsForDay(String dayKey) {
    return _diaryRepository.totalsForDay(dayKey);
  }

  Future<double> changeWater({
    required String dayKey,
    required double current,
    required double delta,
    required bool increase,
  }) async {
    final next = WaterIntakeUseCase.nextAmount(
      current: current,
      delta: delta,
      increase: increase,
    );

    await _diaryRepository.updateWater(dayKey, next);
    return next;
  }

  MealTotalsEntity mealTotals(List<MealItemEntity> items) {
    return MealTotalsUseCase.calculate(items);
  }

  double? positiveGramsFromText(String value) {
    return MealItemGramsUseCase.positiveGramsFromText(value);
  }

  bool canSubmitGrams(String value) {
    return MealItemGramsUseCase.canSubmitGrams(value);
  }

  double? positiveWaterVolumeFromText(String value) {
    return WaterIntakeUseCase.positiveVolumeFromText(value);
  }
}
