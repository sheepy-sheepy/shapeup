import 'package:shapeup/core/shared/numbers.dart';

class MealItemGramsUseCase {
  const MealItemGramsUseCase._();

  static double? positiveGramsFromText(String value) {
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) return null;
    return roundGrams(parsed);
  }

  static bool canSubmitGrams(String value) {
    return positiveGramsFromText(value) != null;
  }
}
