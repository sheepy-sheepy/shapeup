import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/date_utils.dart';
import '../entities/local_entities.dart';
import '../repositories/measurements_repository.dart';
import '../repositories/profile_repository.dart';

final profileSettingsLoaderProvider = Provider<ProfileSettingsLoader>((ref) {
  return ProfileSettingsLoader(
    profileRepository: ref.watch(profileRepositoryProvider),
    measurementsRepository: ref.watch(measurementsRepositoryProvider),
  );
});

class ProfileSettingsLoadData {
  const ProfileSettingsLoadData({
    required this.user,
    required this.latestMeasurement,
  });

  final LocalUser? user;
  final BodyMeasurement? latestMeasurement;
}

class ProfileSettingsLoader {
  const ProfileSettingsLoader({
    required this.profileRepository,
    required this.measurementsRepository,
  });

  final ProfileRepository profileRepository;
  final MeasurementsRepository measurementsRepository;

  Future<ProfileSettingsLoadData> load() async {
    final todayKey = dayKeyFromDate(DateTime.now());
    final result = await Future.wait<Object?>([
      profileRepository.getCurrentLocalUser(),
      measurementsRepository.latestMeasurementUpToDay(todayKey),
    ]);

    return ProfileSettingsLoadData(
      user: result[0] as LocalUser?,
      latestMeasurement: result[1] as BodyMeasurement?,
    );
  }
}
