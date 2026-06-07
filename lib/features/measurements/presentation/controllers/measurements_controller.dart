import 'package:shapeup/features/measurements/domain/usecases/measurements_usecase.dart';
import 'package:shapeup/features/measurements/domain/entities/body_measurement_entity.dart';
import 'package:shapeup/features/settings/domain/entities/local_user_entity.dart';

export 'package:shapeup/features/measurements/domain/usecases/load_measurements_usecase.dart';
export 'package:shapeup/features/measurements/domain/usecases/measurements_usecase.dart'
    show MeasurementInputEntity;


class MeasurementsController {
  const MeasurementsController(this._measurementsUseCase);

  final MeasurementsUseCase _measurementsUseCase;

  bool canSaveMeasurementText({
    required String weightKg,
    required String neckCm,
    required String waistCm,
    required String hipsCm,
  }) {
    return _measurementsUseCase.canSaveMeasurementText(
      weightKg: weightKg,
      neckCm: neckCm,
      waistCm: waistCm,
      hipsCm: hipsCm,
    );
  }

  MeasurementInputEntity? valuesFromText({
    required String weightKg,
    required String neckCm,
    required String waistCm,
    required String hipsCm,
  }) {
    return _measurementsUseCase.valuesFromText(
      weightKg: weightKg,
      neckCm: neckCm,
      waistCm: waistCm,
      hipsCm: hipsCm,
    );
  }

  double? bodyFatPreviewFromText({
    required LocalUserEntity user,
    required String neckCm,
    required String waistCm,
    required String hipsCm,
  }) {
    return _measurementsUseCase.bodyFatPreviewFromText(
      user: user,
      neckCm: neckCm,
      waistCm: waistCm,
      hipsCm: hipsCm,
    );
  }

  double? freshBodyFatForMeasurement({
    required LocalUserEntity user,
    required BodyMeasurementEntity measurement,
  }) {
    return _measurementsUseCase.freshBodyFatForMeasurement(
      user: user,
      measurement: measurement,
    );
  }

  String? sexLabelFromUser(LocalUserEntity user) {
    return _measurementsUseCase.sexLabelFromUser(user);
  }

  Future<void> saveMeasurement({
    required String dayKey,
    required LocalUserEntity user,
    required MeasurementInputEntity values,
  }) {
    return _measurementsUseCase.saveMeasurement(
      dayKey: dayKey,
      user: user,
      values: values,
    );
  }
}
