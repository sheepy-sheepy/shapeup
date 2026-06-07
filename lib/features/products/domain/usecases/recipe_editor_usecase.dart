import 'package:shapeup/core/shared/errors.dart';
import 'package:shapeup/features/products/domain/entities/recipe_editor_data_entity.dart';
import 'package:shapeup/features/products/domain/repositories/recipes_repository.dart';
import 'package:shapeup/features/products/domain/usecases/recipe_form_usecase.dart';

export 'package:shapeup/features/products/domain/entities/recipe_editor_data_entity.dart' show RecipeEditorDataEntity;

class RecipeEditorUseCase {
  const RecipeEditorUseCase(this._recipesRepository);

  final RecipesRepository _recipesRepository;

  double? positiveNumberFromText(String value) {
    return RecipeFormUseCase.positiveNumberFromText(value);
  }

  double? cookedWeight({
    required double? tareWeightGrams,
    required double? cookedWithTareWeightGrams,
  }) {
    return RecipeFormUseCase.cookedWeight(
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
    return RecipeFormUseCase.canSaveRecipe(
      loading: loading,
      name: name,
      items: items,
      cookedWeightGrams: cookedWeightGrams,
    );
  }

  String? positiveNumberValidator(String? value) {
    return RecipeFormUseCase.positiveNumberValidator(value);
  }

  String? cookedWithTareValidator({
    required String? value,
    required double? tareWeightGrams,
  }) {
    return RecipeFormUseCase.cookedWithTareValidator(
      value: value,
      tareWeightGrams: tareWeightGrams,
    );
  }

  RecipeTotalsEntity totalsForInputs(
    List<RecipeIngredientInputEntity> items, {
    required double cookedWeightGrams,
  }) {
    return RecipeFormUseCase.totalsForInputs(
      items,
      cookedWeightGrams: cookedWeightGrams,
    );
  }

  Future<RecipeEditorDataEntity> loadInitialData(String recipeId) async {
    final result = await Future.wait<Object?>([
      _recipesRepository.recipeById(recipeId),
      _recipesRepository.ingredients(recipeId),
    ]);

    final recipe = result[0] as RecipeEntity?;
    final ingredients = result[1] as List<RecipeIngredientEntity>;

    return RecipeEditorDataEntity(
      recipe: recipe,
      ingredients: ingredients
          .map(
            (e) => RecipeIngredientInputEntity(
              sourceType: e.sourceType,
              sourceId: e.sourceId,
              name: e.nameSnapshot,
              grams: e.grams,
              calories: e.caloriesSnapshot,
              proteins: e.proteinsSnapshot,
              fats: e.fatsSnapshot,
              carbs: e.carbsSnapshot,
            ),
          )
          .toList(),
    );
  }

  Future<void> saveRecipe({
    required String? recipeId,
    required String name,
    required List<RecipeIngredientInputEntity> ingredients,
    required double tareWeightGrams,
    required double cookedWithTareWeightGrams,
  }) {
    if (RecipeFormUseCase.cookedWeight(
          tareWeightGrams: tareWeightGrams,
          cookedWithTareWeightGrams: cookedWithTareWeightGrams,
        ) ==
        null) {
      throw const AppException(cookedWeightPositiveMessage);
    }

    if (recipeId == null) {
      return _recipesRepository.createRecipe(
        name: name,
        ingredients: ingredients,
        tareWeightGrams: tareWeightGrams,
        cookedWithTareWeightGrams: cookedWithTareWeightGrams,
      );
    }

    return _recipesRepository.updateRecipe(
      recipeId: recipeId,
      name: name,
      ingredients: ingredients,
      tareWeightGrams: tareWeightGrams,
      cookedWithTareWeightGrams: cookedWithTareWeightGrams,
    );
  }
}
