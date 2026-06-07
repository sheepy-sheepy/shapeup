import 'package:shapeup/core/shared/errors.dart';
import 'package:shapeup/features/products/domain/entities/recipe_ingredient_input_entity.dart';
import 'package:shapeup/features/products/domain/entities/recipe_totals_entity.dart';
import 'package:shapeup/features/products/domain/usecases/recipe_nutrition_usecase.dart';

class RecipeFormUseCase {
  const RecipeFormUseCase._();

  static double? positiveNumberFromText(String value) {
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }

  static double? cookedWeight({
    required double? tareWeightGrams,
    required double? cookedWithTareWeightGrams,
  }) {
    if (tareWeightGrams == null || cookedWithTareWeightGrams == null) {
      return null;
    }

    final result = cookedWithTareWeightGrams - tareWeightGrams;
    if (result <= 0) return null;

    return result;
  }

  static bool hasTwoDifferentProducts(List<RecipeIngredientInputEntity> items) {
    final distinct = items.map((item) => '${item.sourceType}:${item.sourceId}').toSet();
    return distinct.length >= 2;
  }

  static bool canSaveRecipe({
    required bool loading,
    required String name,
    required List<RecipeIngredientInputEntity> items,
    required double? cookedWeightGrams,
  }) {
    return !loading &&
        name.trim().isNotEmpty &&
        items.length >= 2 &&
        hasTwoDifferentProducts(items) &&
        cookedWeightGrams != null;
  }

  static String? positiveNumberValidator(String? value) {
    final parsed = positiveNumberFromText(value ?? '');
    if (parsed == null) return enterPositiveNumberMessage;
    return null;
  }

  static String? cookedWithTareValidator({
    required String? value,
    required double? tareWeightGrams,
  }) {
    final parsed = positiveNumberFromText(value ?? '');
    if (parsed == null) return enterPositiveNumberMessage;

    if (tareWeightGrams != null && parsed <= tareWeightGrams) {
      return cookedWithTareWeightNonNegativeMessage;
    }

    return null;
  }

  static RecipeTotalsEntity totalsForInputs(
    List<RecipeIngredientInputEntity> items, {
    required double cookedWeightGrams,
  }) {
    return RecipeNutritionUseCase.totalsForInputs(
      items,
      cookedWeightGrams: cookedWeightGrams,
    );
  }
}
