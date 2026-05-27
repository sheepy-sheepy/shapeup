import '../../domain/entities/local_entities.dart';

class RecipeSearchService {
  const RecipeSearchService._();

  static String _normalizeSearch(String value) {
    return value.trim().toLowerCase();
  }

  static List<Recipe> filterAndSortBySearch(
    List<Recipe> recipes,
    String query,
  ) {
    final q = _normalizeSearch(query);

    if (q.isEmpty) {
      return recipes;
    }

    final startsWith = <Recipe>[];
    final contains = <Recipe>[];

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
