import 'package:shapeup/core/shared/errors.dart';
import 'package:shapeup/core/shared/dates.dart';
import 'package:shapeup/core/shared/enums.dart';
import 'package:shapeup/features/measurements/domain/entities/body_fat_result_entity.dart';
import 'package:shapeup/features/onboarding/domain/entities/onboarding_data_entity.dart';
import 'package:shapeup/domain/usecases/nutrition_calculation_usecase.dart';

export 'package:shapeup/features/measurements/domain/entities/body_fat_result_entity.dart' show BodyFatResultEntity;

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

  static OnboardingDataEntity? onboardingDataFromText({
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

    return OnboardingDataEntity(
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

  static BodyFatResultEntity validateBodyFatFromText({
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

  static BodyFatResultEntity validateBodyFat({
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
        return const BodyFatResultEntity(
          isValid: false,
          message: bodyFatInputsInvalidMessage,
        );
      }

      final bodyFat = NutritionCalculationUseCase.bodyFatPercent(
        sex: sex,
        heightCm: heightCm,
        neckCm: neckCm,
        waistCm: waistCm,
        hipsCm: hipsCm,
      );

      if (!bodyFat.isFinite || bodyFat <= 0) {
        return const BodyFatResultEntity(
          isValid: false,
          message: bodyFatInvalidMessage,
        );
      }

      return const BodyFatResultEntity(
        isValid: true,
        message: '',
      );
    } catch (error) {
      return BodyFatResultEntity(
        isValid: false,
        message: bodyFatValidationMessageFromError(error),
      );
    }
  }
}
