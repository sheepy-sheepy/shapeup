
import 'package:shapeup/core/shared/enums.dart';
import 'package:shapeup/features/measurements/domain/entities/body_measurement_entity.dart';

export 'package:shapeup/features/measurements/domain/entities/body_measurement_entity.dart' show BodyMeasurementEntity;


abstract class MeasurementsRepository {
  Future<void> saveMeasurement({
    required String dayKey,
    required double weightKg,
    required double neckCm,
    required double waistCm,
    required double hipsCm,
    required double heightCm,
    required Sex sex,
  });
  Future<List<BodyMeasurementEntity>> allMeasurements();
  Future<BodyMeasurementEntity?> measurementForDay(String dayKey);
  Future<BodyMeasurementEntity?> latestMeasurementUpToDay(String dayKey);
  Future<BodyMeasurementEntity?> measurementForNormDay(String dayKey);
}
