
import 'package:shapeup/features/onboarding/domain/entities/onboarding_data_entity.dart';

export 'package:shapeup/features/onboarding/domain/entities/onboarding_data_entity.dart' show OnboardingDataEntity;


abstract class OnboardingRepository {
  Future<void> completeOnboarding(OnboardingDataEntity data);
}
