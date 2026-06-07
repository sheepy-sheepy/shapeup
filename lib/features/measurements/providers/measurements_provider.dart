import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shapeup/presentation/providers/app_providers.dart' as app_providers;

import 'package:shapeup/features/auth/providers/auth_provider.dart' as auth;
import 'package:shapeup/features/measurements/data/repositories/measurements_repository_impl.dart';
import 'package:shapeup/features/measurements/domain/repositories/measurements_repository.dart';
import 'package:shapeup/features/measurements/domain/usecases/measurements_usecase.dart';
import 'package:shapeup/features/measurements/presentation/controllers/measurements_controller.dart';
import 'package:shapeup/features/settings/providers/settings_provider.dart' as settings;

final measurementsRepositoryProvider = Provider<MeasurementsRepository>((ref) {
  return MeasurementsRepositoryImpl(
    ref.watch(app_providers.appDatabaseProvider),
    ref.watch(auth.authRepositoryProvider),
  );
});

final loadMeasurementsUseCaseProvider =
    Provider<LoadMeasurementsUseCase>((ref) {
  return LoadMeasurementsUseCase(
    measurementsRepository: ref.watch(measurementsRepositoryProvider),
    profileRepository: ref.watch(settings.profileRepositoryProvider),
  );
});

final measurementsUseCaseProvider = Provider<MeasurementsUseCase>((ref) {
  return MeasurementsUseCase(ref.watch(measurementsRepositoryProvider));
});

final measurementsLoadDataProvider = FutureProvider.autoDispose
    .family<MeasurementsDataEntity, String>(
  (ref, dayKey) => ref.watch(
        loadMeasurementsUseCaseProvider,
      ).loadForDay(dayKey),
);

final measurementsControllerProvider = Provider<MeasurementsController>((ref) {
  return MeasurementsController(ref.watch(measurementsUseCaseProvider));
});
