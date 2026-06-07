import 'package:shapeup/features/measurements/domain/entities/body_measurement_entity.dart';
import 'package:shapeup/features/settings/domain/entities/local_user_entity.dart';

class MeasurementsDataEntity {
  const MeasurementsDataEntity({
    required this.user,
    required this.todayMeasurement,
  });

  final LocalUserEntity? user;
  final BodyMeasurementEntity? todayMeasurement;
}
