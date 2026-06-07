import 'package:shapeup/features/measurements/domain/entities/measurements_data_entity.dart';
import 'package:shapeup/features/measurements/domain/repositories/measurements_repository.dart';
import 'package:shapeup/features/settings/domain/repositories/profile_repository.dart';

export 'package:shapeup/features/measurements/domain/entities/measurements_data_entity.dart' show MeasurementsDataEntity;

class LoadMeasurementsUseCase {
  const LoadMeasurementsUseCase({
    required this.measurementsRepository,
    required this.profileRepository,
  });

  final MeasurementsRepository measurementsRepository;
  final ProfileRepository profileRepository;

  Future<MeasurementsDataEntity> loadForDay(String dayKey) async {
    final result = await Future.wait<Object?>([
      profileRepository.getCurrentLocalUser(),
      measurementsRepository.measurementForDay(dayKey),
    ]);

    return MeasurementsDataEntity(
      user: result[0] as LocalUserEntity?,
      todayMeasurement: result[1] as BodyMeasurementEntity?,
    );
  }
}
