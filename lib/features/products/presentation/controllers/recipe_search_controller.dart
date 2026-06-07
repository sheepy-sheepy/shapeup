import 'package:shapeup/features/products/domain/entities/recipe_entity.dart';
class RecipeSearchController {
  const RecipeSearchController._();

  static String _normalizeSearch(String value) {
    return value.trim().toLowerCase();
  }

  static List<RecipeEntity> filterAndSortBySearch(
    List<RecipeEntity> recipes,
    String query,
  ) {
    final q = _normalizeSearch(query);

    if (q.isEmpty) {
      return recipes;
    }

    final startsWith = <RecipeEntity>[];
    final contains = <RecipeEntity>[];

    for (final recipe in recipes) {
      final name = _normalizeSearch(recipe.name);

      if (name.startsWith(q)) {
        startsWith.add(recipe);
      } else if (name.contains(q)) {
        contains.add(recipe);
      }
    }

    startsWith.sort(
      (a, b) => _normalizeSearch(a.name).compareTo(_normalizeSearch(b.name)),
    );

    contains.sort(
      (a, b) => _normalizeSearch(a.name).compareTo(_normalizeSearch(b.name)),
    );

    return [
      ...startsWith,
      ...contains,
    ];
  }
}
