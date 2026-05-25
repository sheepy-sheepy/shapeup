import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums.dart';
import '../entities/local_entities.dart';

export '../entities/local_entities.dart' show BodyMeasurement;

final measurementsRepositoryProvider = Provider<MeasurementsRepository>((ref) {
  throw UnimplementedError(
    'MeasurementsRepository должен быть подключен в data-слое',
  );
});

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
  Future<List<BodyMeasurement>> allMeasurements();
  Future<BodyMeasurement?> measurementForDay(String dayKey);
  Future<BodyMeasurement?> latestMeasurementUpToDay(String dayKey);
  Future<BodyMeasurement?> measurementForNormDay(String dayKey);
}
