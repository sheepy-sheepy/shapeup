import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../entities/local_entities.dart';
import '../repositories/measurements_repository.dart';
import '../repositories/profile_repository.dart';

final measurementsLoaderProvider = Provider<MeasurementsLoader>((ref) {
  return MeasurementsLoader(
    measurementsRepository: ref.watch(measurementsRepositoryProvider),
    profileRepository: ref.watch(profileRepositoryProvider),
  );
});

class MeasurementsLoadData {
  const MeasurementsLoadData({
    required this.user,
    required this.todayMeasurement,
  });

  final LocalUser? user;
  final BodyMeasurement? todayMeasurement;
}

class MeasurementsLoader {
  const MeasurementsLoader({
    required this.measurementsRepository,
    required this.profileRepository,
  });

  final MeasurementsRepository measurementsRepository;
  final ProfileRepository profileRepository;

  Future<MeasurementsLoadData> loadForDay(String dayKey) async {
    final result = await Future.wait<Object?>([
      profileRepository.getCurrentLocalUser(),
      measurementsRepository.measurementForDay(dayKey),
    ]);

    return MeasurementsLoadData(
      user: result[0] as LocalUser?,
      todayMeasurement: result[1] as BodyMeasurement?,
    );
  }
}
