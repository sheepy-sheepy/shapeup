import '../../core/enums.dart';
import '../../core/number_utils.dart';
import '../entities/local_entities.dart';
import '../services/nutrition_calculator.dart';

class MeasurementInputValues {
  const MeasurementInputValues({
    required this.weightKg,
    required this.neckCm,
    required this.waistCm,
    required this.hipsCm,
  });

  final double weightKg;
  final double neckCm;
  final double waistCm;
  final double hipsCm;
}

class MeasurementsBodyFatUseCase {
  const MeasurementsBodyFatUseCase._();

  static double? positiveMeasurementValueFromText(String value) {
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed == null || parsed <= 0 || !parsed.isFinite) return null;
    return roundTo1(parsed);
  }

  static MeasurementInputValues? valuesFromText({
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

    return MeasurementInputValues(
      weightKg: parsedWeightKg,
      neckCm: parsedNeckCm,
      waistCm: parsedWaistCm,
      hipsCm: parsedHipsCm,
    );
  }

  static Sex? sexFromUser(LocalUser user) {
    final sexName = user.sex;
    if (sexName == null) return null;

    for (final item in Sex.values) {
      if (item.name == sexName) return item;
    }

    return null;
  }

  static double? freshBodyFatForMeasurement({
    required LocalUser user,
    required BodyMeasurement measurement,
  }) {
    return bodyFatForUserValues(
      user: user,
      neckCm: measurement.neckCm,
      waistCm: measurement.waistCm,
      hipsCm: measurement.hipsCm,
    );
  }

  static double? bodyFatPreviewFromText({
    required LocalUser user,
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
    required LocalUser user,
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
    required LocalUser user,
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
      return NutritionCalculator.bodyFatPercent(
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
