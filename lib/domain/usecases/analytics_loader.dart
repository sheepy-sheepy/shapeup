import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../entities/local_entities.dart';
import '../repositories/measurements_repository.dart';
import '../repositories/photos_repository.dart';

final analyticsLoaderProvider = Provider<AnalyticsLoader>((ref) {
  return AnalyticsLoader(
    measurementsRepository: ref.watch(measurementsRepositoryProvider),
    photosRepository: ref.watch(photosRepositoryProvider),
  );
});

class AnalyticsData {
  const AnalyticsData({
    required this.measurements,
    required this.photos,
  });

  final List<BodyMeasurement> measurements;
  final List<ProgressPhoto> photos;
}

class AnalyticsLoader {
  const AnalyticsLoader({
    required this.measurementsRepository,
    required this.photosRepository,
  });

  final MeasurementsRepository measurementsRepository;
  final PhotosRepository photosRepository;

  Future<AnalyticsData> load() async {
    final result = await Future.wait<Object>([
      measurementsRepository.allMeasurements(),
      photosRepository.allPhotos(),
    ]);

    return AnalyticsData(
      measurements: result[0] as List<BodyMeasurement>,
      photos: result[1] as List<ProgressPhoto>,
    );
  }
}
