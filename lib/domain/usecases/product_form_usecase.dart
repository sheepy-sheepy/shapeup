class ProductFormUseCase {
  const ProductFormUseCase._();

  static double? nonNegativeNumberFromText(String value) {
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed == null || parsed < 0) return null;
    return parsed;
  }

  static double? caloriesFromMacros({
    required double? proteins,
    required double? fats,
    required double? carbs,
  }) {
    if (proteins == null || fats == null || carbs == null) return null;
    return (proteins * 4) + (fats * 9) + (carbs * 4);
  }

  static bool canSaveProduct({
    required String name,
    required double? calories,
    required double? proteins,
    required double? fats,
    required double? carbs,
  }) {
    return name.trim().isNotEmpty &&
        calories != null &&
        proteins != null &&
        fats != null &&
        carbs != null;
  }
}
