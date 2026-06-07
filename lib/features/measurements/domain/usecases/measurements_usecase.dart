import 'package:shapeup/core/shared/errors.dart';
import 'package:shapeup/core/shared/extensions.dart';
import 'package:shapeup/features/measurements/domain/entities/measurement_input_entity.dart';
import 'package:shapeup/features/measurements/domain/repositories/measurements_repository.dart';
import 'package:shapeup/features/measurements/domain/usecases/measurements_body_fat_usecase.dart';
import 'package:shapeup/features/settings/domain/entities/local_user_entity.dart';

export 'package:shapeup/features/measurements/domain/entities/measurement_input_entity.dart' show MeasurementInputEntity;

class MeasurementsUseCase {
  const MeasurementsUseCase(this._measurementsRepository);

  final MeasurementsRepository _measurementsRepository;

  bool canSaveMeasurementText({
    required String weightKg,
    required String neckCm,
    required String waistCm,
    required String hipsCm,
  }) {
    return MeasurementsBodyFatUseCase.canSaveMeasurementText(
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
    return MeasurementsBodyFatUseCase.valuesFromText(
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
    return MeasurementsBodyFatUseCase.bodyFatPreviewFromText(
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
    return MeasurementsBodyFatUseCase.freshBodyFatForMeasurement(
      user: user,
      measurement: measurement,
    );
  }

  String? sexLabelFromUser(LocalUserEntity user) {
    return MeasurementsBodyFatUseCase.sexFromUser(user)?.label;
  }

  Future<void> saveMeasurement({
    required String dayKey,
    required LocalUserEntity user,
    required MeasurementInputEntity values,
  }) {
    final heightCm = user.heightCm;
    final sex = MeasurementsBodyFatUseCase.sexFromUser(user);

    if (heightCm == null || sex == null) {
      throw const AppException(localProfileNotFoundMessage);
    }

    return _measurementsRepository.saveMeasurement(
      dayKey: dayKey,
      weightKg: values.weightKg,
      neckCm: values.neckCm,
      waistCm: values.waistCm,
      hipsCm: values.hipsCm,
      heightCm: heightCm,
      sex: sex,
    );
  }
}
