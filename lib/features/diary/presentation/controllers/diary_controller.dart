import 'package:flutter/material.dart';

import 'package:shapeup/core/design/norm_frame_style.dart';
import 'package:shapeup/features/diary/domain/entities/diary_totals_entity.dart';
import 'package:shapeup/domain/usecases/nutrition_calculation_usecase.dart';
import 'package:shapeup/features/diary/domain/usecases/load_diary_day_usecase.dart';
import 'package:shapeup/features/diary/domain/usecases/diary_norm_frame_usecase.dart';
import 'package:shapeup/features/diary/domain/usecases/diary_usecase.dart';
import 'package:shapeup/domain/entities/macro_norms_entity.dart';
import 'package:shapeup/features/diary/domain/entities/meal_item_entity.dart';

export 'package:shapeup/features/diary/domain/entities/diary_totals_entity.dart';
export 'package:shapeup/domain/usecases/nutrition_calculation_usecase.dart' show MacroNormsEntity;
export 'package:shapeup/features/diary/domain/usecases/load_diary_day_usecase.dart' show DiaryDayEntity;
export 'package:shapeup/features/diary/domain/entities/diary_totals_entity.dart' show DiaryTotalsEntity;
export 'package:shapeup/features/diary/domain/entities/meal_entity.dart' show MealEntity;
export 'package:shapeup/features/diary/domain/entities/meal_item_entity.dart' show MealItemEntity;


class DiaryController {
  const DiaryController({
    required DiaryUseCase diaryOperationsUseCase,
    required LoadDiaryDayUseCase diaryDayLoader,
  })  : _diaryOperationsUseCase = diaryOperationsUseCase,
        _diaryDayLoader = diaryDayLoader;

  final DiaryUseCase _diaryOperationsUseCase;
  final LoadDiaryDayUseCase _diaryDayLoader;

  Future<DiaryDayEntity> loadDay({
    required String dayKey,
    required DateTime date,
  }) {
    return _diaryDayLoader.loadDay(dayKey: dayKey, date: date);
  }

  Future<List<MealItemEntity>> mealItems(String mealId) {
    return _diaryOperationsUseCase.mealItems(mealId);
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
    return _diaryOperationsUseCase.addMealItem(
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
    return _diaryOperationsUseCase.updateMealItemGrams(
      mealItemId: mealItemId,
      grams: grams,
    );
  }

  Future<void> deleteMealItem(String mealItemId) {
    return _diaryOperationsUseCase.deleteMealItem(mealItemId);
  }

  Future<DiaryTotalsEntity> totalsForDay(String dayKey) {
    return _diaryOperationsUseCase.totalsForDay(dayKey);
  }

  Future<double> changeWater({
    required String dayKey,
    required double current,
    required double delta,
    required bool increase,
  }) {
    return _diaryOperationsUseCase.changeWater(
      dayKey: dayKey,
      current: current,
      delta: delta,
      increase: increase,
    );
  }

  double? positiveWaterVolumeFromText(String value) {
    return _diaryOperationsUseCase.positiveWaterVolumeFromText(value);
  }

  double? positiveGramsFromText(String value) {
    return _diaryOperationsUseCase.positiveGramsFromText(value);
  }

  bool canSubmitGrams(String value) {
    return _diaryOperationsUseCase.canSubmitGrams(value);
  }

  dynamic mealTotals(List<MealItemEntity> items) {
    return _diaryOperationsUseCase.mealTotals(items);
  }

  NormFrameUiStyle normFrameStyle({
    required ColorScheme colors,
    required DiaryTotalsEntity totals,
    required MacroNormsEntity norms,
  }) {
    final frameData = DiaryNormFrameUseCase.calculate(
      totals: totals,
      norms: norms,
    );

    if (!frameData.hasValidNorms) {
      return NormFrameUiStyle(
        color: colors.outlineVariant.withValues(alpha: 0.45),
        width: 1.0,
      );
    }

    if (frameData.hasOverage) {
      return NormFrameUiStyle(
        color: Color.lerp(
          const Color(0xFFFFE4E4),
          const Color(0xFFEFA0A0),
          frameData.redPower,
        )!,
        width: 1.4 + frameData.redPower * 1.8,
      );
    }

    return NormFrameUiStyle(
      color: Color.lerp(
        colors.outlineVariant.withValues(alpha: 0.38),
        const Color(0xFFBFE8C8),
        frameData.calorieProgress,
      )!,
      width: 1.0 + frameData.calorieProgress * 1.2,
    );
  }
}
