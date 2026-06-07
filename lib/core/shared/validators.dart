import 'package:shapeup/core/shared/errors.dart';

class Validators {
  static String? requiredText(String? value) {
    if (value == null || value.trim().isEmpty) return requiredFieldMessage;
    return null;
  }

  static String? positiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) return requiredFieldMessage;
    final d = double.tryParse(value.replaceAll(',', '.'));
    if (d == null) return enterNumberMessage;
    if (d <= 0) return positiveValueMessage;
    return null;
  }

  static String? nonNegativeNumber(String? value) {
    if (value == null || value.trim().isEmpty) return requiredFieldMessage;
    final d = double.tryParse(value.replaceAll(',', '.'));
    if (d == null) return enterNumberMessage;
    if (d < 0) return nonNegativeValueMessage;
    return null;
  }
}
