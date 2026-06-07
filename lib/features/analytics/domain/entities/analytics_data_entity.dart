import 'package:shapeup/features/measurements/domain/entities/body_measurement_entity.dart';
import 'package:shapeup/features/photos/domain/entities/progress_photo_entity.dart';

class AnalyticsDataEntity {
  const AnalyticsDataEntity({
    required this.measurements,
    required this.photos,
  });

  final List<BodyMeasurementEntity> measurements;
  final List<ProgressPhotoEntity> photos;
}
