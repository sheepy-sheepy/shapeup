import 'package:shapeup/core/shared/dates.dart';
import 'package:shapeup/features/settings/domain/entities/profile_settings_data_entity.dart';
import 'package:shapeup/features/measurements/domain/repositories/measurements_repository.dart';
import 'package:shapeup/features/settings/domain/repositories/profile_repository.dart';

export 'package:shapeup/features/settings/domain/entities/profile_settings_data_entity.dart' show ProfileSettingsDataEntity;

class LoadProfileSettingsUseCase {
  const LoadProfileSettingsUseCase({
    required this.profileRepository,
    required this.measurementsRepository,
  });

  final ProfileRepository profileRepository;
  final MeasurementsRepository measurementsRepository;

  Future<ProfileSettingsDataEntity> load() async {
    final todayKey = dayKeyFromDate(DateTime.now());
    final result = await Future.wait<Object?>([
      profileRepository.getCurrentLocalUser(),
      measurementsRepository.latestMeasurementUpToDay(todayKey),
    ]);

    return ProfileSettingsDataEntity(
      user: result[0] as LocalUserEntity?,
      latestMeasurement: result[1] as BodyMeasurementEntity?,
    );
  }
}
