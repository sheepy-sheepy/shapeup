import 'package:shapeup/features/measurements/domain/entities/body_measurement_entity.dart';
import 'package:shapeup/features/settings/domain/entities/local_user_entity.dart';

class ProfileSettingsDataEntity {
  const ProfileSettingsDataEntity({
    required this.user,
    required this.latestMeasurement,
  });

  final LocalUserEntity? user;
  final BodyMeasurementEntity? latestMeasurement;
}
