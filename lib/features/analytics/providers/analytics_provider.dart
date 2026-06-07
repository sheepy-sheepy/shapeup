import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shapeup/presentation/providers/app_providers.dart' as app_providers;
import 'package:shapeup/features/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:shapeup/features/analytics/domain/repositories/analytics_repository.dart';
import 'package:shapeup/features/analytics/domain/usecases/load_analytics_usecase.dart';
import 'package:shapeup/features/measurements/providers/measurements_provider.dart' as measurements;
import 'package:shapeup/features/photos/providers/photos_provider.dart' as photos;

final analyticsRepositoryProvider = Provider<AnalyticsRepository>((ref) {
  return AnalyticsRepositoryImpl(
    measurementsRepository: ref.watch(
      measurements.measurementsRepositoryProvider,
    ),
    photosRepository: ref.watch(photos.photosRepositoryProvider),
  );
});

final loadAnalyticsUseCaseProvider = Provider<LoadAnalyticsUseCase>((ref) {
  return LoadAnalyticsUseCase(ref.watch(analyticsRepositoryProvider));
});

final analyticsDataProvider =
    FutureProvider.autoDispose<AnalyticsDataEntity>((ref) {
  ref.watch(app_providers.currentDayKeyProvider);
  ref.watch(app_providers.appRefreshTickProvider);

  return ref.watch(loadAnalyticsUseCaseProvider).load();
});
