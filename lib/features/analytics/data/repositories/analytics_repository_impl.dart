import 'package:shapeup/features/analytics/domain/entities/analytics_data_entity.dart';
import 'package:shapeup/features/analytics/domain/repositories/analytics_repository.dart' as domain;
import 'package:shapeup/features/measurements/domain/repositories/measurements_repository.dart' as measurements_domain;
import 'package:shapeup/features/photos/domain/repositories/photos_repository.dart' as photos_domain;

class AnalyticsRepositoryImpl implements domain.AnalyticsRepository {
  const AnalyticsRepositoryImpl({
    required this.measurementsRepository,
    required this.photosRepository,
  });

  final measurements_domain.MeasurementsRepository measurementsRepository;
  final photos_domain.PhotosRepository photosRepository;

  @override
  Future<AnalyticsDataEntity> loadAnalytics() async {
    final result = await Future.wait<Object>([
      measurementsRepository.allMeasurements(),
      photosRepository.allPhotos(),
    ]);

    return AnalyticsDataEntity(
      measurements: result[0] as List<measurements_domain.BodyMeasurementEntity>,
      photos: result[1] as List<photos_domain.ProgressPhotoEntity>,
    );
  }
}
