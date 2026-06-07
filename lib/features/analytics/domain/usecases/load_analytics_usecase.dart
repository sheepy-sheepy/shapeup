import 'package:shapeup/features/analytics/domain/repositories/analytics_repository.dart';

export 'package:shapeup/features/analytics/domain/entities/analytics_data_entity.dart' show AnalyticsDataEntity;


class LoadAnalyticsUseCase {
  const LoadAnalyticsUseCase(this._analyticsRepository);

  final AnalyticsRepository _analyticsRepository;

  Future<AnalyticsDataEntity> load() {
    return _analyticsRepository.loadAnalytics();
  }
}
