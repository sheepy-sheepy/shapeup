import 'package:shapeup/features/analytics/domain/entities/analytics_data_entity.dart';

export 'package:shapeup/features/analytics/domain/entities/analytics_data_entity.dart'
    show AnalyticsDataEntity;

abstract class AnalyticsRepository {
  Future<AnalyticsDataEntity> loadAnalytics();
}
