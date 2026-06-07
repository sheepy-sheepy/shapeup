
import 'package:shapeup/features/onboarding/domain/repositories/onboarding_repository.dart' as domain;
import 'package:shapeup/features/settings/domain/repositories/profile_repository.dart';

class OnboardingRepositoryImpl implements domain.OnboardingRepository {
  const OnboardingRepositoryImpl(this.profileRepository);

  final ProfileRepository profileRepository;

  @override
  Future<void> completeOnboarding(OnboardingDataEntity data) {
    return profileRepository.completeOnboarding(data);
  }
}
