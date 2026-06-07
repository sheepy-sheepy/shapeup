import 'package:shapeup/features/auth/domain/repositories/auth_repository.dart';
import 'package:shapeup/features/onboarding/domain/repositories/onboarding_repository.dart';


class OnboardingUseCase {
  const OnboardingUseCase({
    required AuthRepository authRepository,
    required OnboardingRepository onboardingRepository,
  })  : _authRepository = authRepository,
        _onboardingRepository = onboardingRepository;

  final AuthRepository _authRepository;
  final OnboardingRepository _onboardingRepository;

  Future<void> markOnboardingStarted() {
    return _authRepository.markOnboardingStarted();
  }

  Future<void> signOutAfterInterruptedOnboarding() {
    return _authRepository.signOutAfterInterruptedOnboarding();
  }

  Future<void> completeOnboarding(OnboardingDataEntity data) async {
    await _onboardingRepository.completeOnboarding(data);
    await _authRepository.clearStartedButUnfinishedOnboarding();
  }
}
