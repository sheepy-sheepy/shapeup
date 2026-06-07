import 'package:shapeup/features/products/domain/entities/recipe_ingredient_input_entity.dart';
import 'package:shapeup/features/products/domain/entities/recipe_totals_entity.dart';
import 'package:shapeup/features/products/domain/usecases/recipe_editor_usecase.dart';
export 'package:shapeup/features/products/domain/usecases/recipe_editor_usecase.dart'
    show RecipeEditorDataEntity;


class RecipeEditorController {
  const RecipeEditorController(this._recipeEditorUseCase);

  final RecipeEditorUseCase _recipeEditorUseCase;

  double? positiveNumberFromText(String value) {
    return _recipeEditorUseCase.positiveNumberFromText(value);
  }

  double? cookedWeight({
    required double? tareWeightGrams,
    required double? cookedWithTareWeightGrams,
  }) {
    return _recipeEditorUseCase.cookedWeight(
      tareWeightGrams: tareWeightGrams,
      cookedWithTareWeightGrams: cookedWithTareWeightGrams,
    );
  }

  bool canSaveRecipe({
    required bool loading,
    required String name,
    required List<RecipeIngredientInputEntity> items,
    required double? cookedWeightGrams,
  }) {
    return _recipeEditorUseCase.canSaveRecipe(
      loading: loading,
      name: name,
      items: items,
      cookedWeightGrams: cookedWeightGrams,
    );
  }

  String? positiveNumberValidator(String? value) {
    return _recipeEditorUseCase.positiveNumberValidator(value);
  }

  String? cookedWithTareValidator({
    required String? value,
    required double? tareWeightGrams,
  }) {
    return _recipeEditorUseCase.cookedWithTareValidator(
      value: value,
      tareWeightGrams: tareWeightGrams,
    );
  }

  RecipeTotalsEntity totalsForInputs(
    List<RecipeIngredientInputEntity> items, {
    required double cookedWeightGrams,
  }) {
    return _recipeEditorUseCase.totalsForInputs(
      items,
      cookedWeightGrams: cookedWeightGrams,
    );
  }

  Future<RecipeEditorDataEntity> loadInitialData(String recipeId) {
    return _recipeEditorUseCase.loadInitialData(recipeId);
  }

  Future<void> saveRecipe({
    required String? recipeId,
    required String name,
    required List<RecipeIngredientInputEntity> ingredients,
    required double tareWeightGrams,
    required double cookedWithTareWeightGrams,
  }) {
    return _recipeEditorUseCase.saveRecipe(
      recipeId: recipeId,
      name: name,
      ingredients: ingredients,
      tareWeightGrams: tareWeightGrams,
      cookedWithTareWeightGrams: cookedWithTareWeightGrams,
    );
  }
}
