import 'package:shapeup/features/products/domain/entities/recipe_entity.dart';
import 'package:shapeup/features/products/domain/entities/recipe_ingredient_input_entity.dart';

class RecipeEditorDataEntity {
  const RecipeEditorDataEntity({
    required this.recipe,
    required this.ingredients,
  });

  final RecipeEntity? recipe;
  final List<RecipeIngredientInputEntity> ingredients;
}
