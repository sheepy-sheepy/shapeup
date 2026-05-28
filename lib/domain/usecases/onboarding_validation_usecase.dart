import '../../core/app_errors.dart';
import '../../core/date_utils.dart';
import '../../core/enums.dart';
import '../entities/onboarding_data.dart';
import '../services/nutrition_calculator.dart';

class BodyFatValidationResult {
  const BodyFatValidationResult({
    required this.isValid,
    required this.message,
  });

  final bool isValid;
  final String message;
}

class OnboardingValidationUseCase {
  const OnboardingValidationUseCase._();

  static double? positiveNumberFromText(String value) {
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed == null || parsed <= 0 || !parsed.isFinite) return null;
    return parsed;
  }

  static bool isValidDateOfBirth(DateTime? dateOfBirth, {DateTime? today}) {
    if (dateOfBirth == null) return false;
    return dateOfBirth.isBefore(today ?? DateTime.now());
  }

  static DateTime? dateOfBirthFromText(String value, {DateTime? today}) {
    final parsed = tryParseRuDate(value);
    if (!isValidDateOfBirth(parsed, today: today)) return null;
    return parsed;
  }

  static String? dateOfBirthValidationMessage(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return requiredFieldMessage;
    if (!hasRuDateFormat(text)) return dateFormatMessage;
    if (dateOfBirthFromText(text) == null) return dateInvalidMessage;
    return null;
  }

  static bool canSubmit({
    required String name,
    required String heightCm,
    required String weightKg,
    required String neckCm,
    required String hipsCm,
    required String waistCm,
    required String dateOfBirth,
  }) {
    return name.trim().isNotEmpty &&
        positiveNumberFromText(heightCm) != null &&
        positiveNumberFromText(weightKg) != null &&
        positiveNumberFromText(neckCm) != null &&
        positiveNumberFromText(hipsCm) != null &&
        positiveNumberFromText(waistCm) != null &&
        dateOfBirthFromText(dateOfBirth) != null;
  }

  static OnboardingData? onboardingDataFromText({
    required String name,
    required String heightCm,
    required String weightKg,
    required String neckCm,
    required String hipsCm,
    required String waistCm,
    required Sex sex,
    required Goal goal,
    required ActivityLevel activity,
    required String dateOfBirth,
  }) {
    final parsedHeightCm = positiveNumberFromText(heightCm);
    final parsedWeightKg = positiveNumberFromText(weightKg);
    final parsedNeckCm = positiveNumberFromText(neckCm);
    final parsedHipsCm = positiveNumberFromText(hipsCm);
    final parsedWaistCm = positiveNumberFromText(waistCm);
    final parsedDateOfBirth = dateOfBirthFromText(dateOfBirth);

    if (name.trim().isEmpty ||
        parsedHeightCm == null ||
        parsedWeightKg == null ||
        parsedNeckCm == null ||
        parsedHipsCm == null ||
        parsedWaistCm == null ||
        parsedDateOfBirth == null) {
      return null;
    }

    return OnboardingData(
      name: name.trim(),
      heightCm: parsedHeightCm,
      weightKg: parsedWeightKg,
      neckCm: parsedNeckCm,
      hipsCm: parsedHipsCm,
      waistCm: parsedWaistCm,
      sex: sex,
      goal: goal,
      activityLevel: activity,
      dateOfBirth: parsedDateOfBirth,
    );
  }

  static BodyFatValidationResult validateBodyFatFromText({
    required Sex sex,
    required String heightCm,
    required String neckCm,
    required String waistCm,
    required String hipsCm,
  }) {
    return validateBodyFat(
      sex: sex,
      heightCm: positiveNumberFromText(heightCm),
      neckCm: positiveNumberFromText(neckCm),
      waistCm: positiveNumberFromText(waistCm),
      hipsCm: positiveNumberFromText(hipsCm),
    );
  }

  static BodyFatValidationResult validateBodyFat({
    required Sex sex,
    required double? heightCm,
    required double? neckCm,
    required double? waistCm,
    required double? hipsCm,
  }) {
    try {
      if (heightCm == null ||
          neckCm == null ||
          waistCm == null ||
          hipsCm == null) {
        return const BodyFatValidationResult(
          isValid: false,
          message: bodyFatInputsInvalidMessage,
        );
      }

      final bodyFat = NutritionCalculator.bodyFatPercent(
        sex: sex,
        heightCm: heightCm,
        neckCm: neckCm,
        waistCm: waistCm,
        hipsCm: hipsCm,
      );

      if (!bodyFat.isFinite || bodyFat <= 0) {
        return const BodyFatValidationResult(
          isValid: false,
          message: bodyFatInvalidMessage,
        );
      }

      return const BodyFatValidationResult(
        isValid: true,
        message: '',
      );
    } catch (error) {
      return BodyFatValidationResult(
        isValid: false,
        message: bodyFatValidationMessageFromError(error),
      );
    }
  }
}
