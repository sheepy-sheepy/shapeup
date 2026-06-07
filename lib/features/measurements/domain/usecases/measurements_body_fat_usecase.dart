import 'package:shapeup/core/shared/enums.dart';
import 'package:shapeup/core/shared/numbers.dart';
import 'package:shapeup/features/measurements/domain/entities/measurement_input_entity.dart';
import 'package:shapeup/domain/usecases/nutrition_calculation_usecase.dart';
import 'package:shapeup/features/measurements/domain/entities/body_measurement_entity.dart';
import 'package:shapeup/features/settings/domain/entities/local_user_entity.dart';

class MeasurementsBodyFatUseCase {
  const MeasurementsBodyFatUseCase._();

  static double? positiveMeasurementValueFromText(String value) {
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed == null || parsed <= 0 || !parsed.isFinite) return null;
    return roundTo1(parsed);
  }

  static MeasurementInputEntity? valuesFromText({
    required String weightKg,
    required String neckCm,
    required String waistCm,
    required String hipsCm,
  }) {
    final parsedWeightKg = positiveMeasurementValueFromText(weightKg);
    final parsedNeckCm = positiveMeasurementValueFromText(neckCm);
    final parsedWaistCm = positiveMeasurementValueFromText(waistCm);
    final parsedHipsCm = positiveMeasurementValueFromText(hipsCm);

    if (parsedWeightKg == null ||
        parsedNeckCm == null ||
        parsedWaistCm == null ||
        parsedHipsCm == null) {
      return null;
    }

    return MeasurementInputEntity(
      weightKg: parsedWeightKg,
      neckCm: parsedNeckCm,
      waistCm: parsedWaistCm,
      hipsCm: parsedHipsCm,
    );
  }

  static Sex? sexFromUser(LocalUserEntity user) {
    final sexName = user.sex;
    if (sexName == null) return null;

    for (final item in Sex.values) {
      if (item.name == sexName) return item;
    }

    return null;
  }

  static double? freshBodyFatForMeasurement({
    required LocalUserEntity user,
    required BodyMeasurementEntity measurement,
  }) {
    return bodyFatForUserValues(
      user: user,
      neckCm: measurement.neckCm,
      waistCm: measurement.waistCm,
      hipsCm: measurement.hipsCm,
    );
  }

  static double? bodyFatPreviewFromText({
    required LocalUserEntity user,
    required String neckCm,
    required String waistCm,
    required String hipsCm,
  }) {
    return bodyFatPreview(
      user: user,
      neckCm: positiveMeasurementValueFromText(neckCm),
      waistCm: positiveMeasurementValueFromText(waistCm),
      hipsCm: positiveMeasurementValueFromText(hipsCm),
    );
  }

  static double? bodyFatPreview({
    required LocalUserEntity user,
    required double? neckCm,
    required double? waistCm,
    required double? hipsCm,
  }) {
    return bodyFatForUserValues(
      user: user,
      neckCm: neckCm,
      waistCm: waistCm,
      hipsCm: hipsCm,
    );
  }

  static double? bodyFatForUserValues({
    required LocalUserEntity user,
    required double? neckCm,
    required double? waistCm,
    required double? hipsCm,
  }) {
    final sex = sexFromUser(user);
    final heightCm = user.heightCm;

    if (sex == null ||
        heightCm == null ||
        heightCm <= 0 ||
        neckCm == null ||
        waistCm == null ||
        hipsCm == null) {
      return null;
    }

    try {
      return NutritionCalculationUseCase.bodyFatPercent(
        sex: sex,
        heightCm: heightCm,
        neckCm: neckCm,
        waistCm: waistCm,
        hipsCm: hipsCm,
      );
    } catch (_) {
      return null;
    }
  }

  static bool canSaveMeasurementText({
    required String weightKg,
    required String neckCm,
    required String waistCm,
    required String hipsCm,
  }) {
    return valuesFromText(
          weightKg: weightKg,
          neckCm: neckCm,
          waistCm: waistCm,
          hipsCm: hipsCm,
        ) !=
        null;
  }

  static bool canSaveMeasurementValues({
    required double? weightKg,
    required double? neckCm,
    required double? waistCm,
    required double? hipsCm,
  }) {
    return weightKg != null &&
        neckCm != null &&
        waistCm != null &&
        hipsCm != null;
  }
}
