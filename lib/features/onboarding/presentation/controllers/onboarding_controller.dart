
import 'package:shapeup/core/shared/enums.dart';
import 'package:shapeup/features/onboarding/domain/entities/onboarding_data_entity.dart';
import 'package:shapeup/features/onboarding/domain/usecases/onboarding_usecase.dart';
import 'package:shapeup/features/onboarding/domain/usecases/onboarding_validation_usecase.dart';

export 'package:shapeup/features/onboarding/domain/usecases/onboarding_validation_usecase.dart'
    show BodyFatResultEntity;


class OnboardingController {
  const OnboardingController({
    required OnboardingUseCase onboardingOperationsUseCase,
  }) : _onboardingOperationsUseCase = onboardingOperationsUseCase;

  final OnboardingUseCase _onboardingOperationsUseCase;

  bool canSubmit({
    required bool loading,
    required bool openingLoginAfterExit,
    required String name,
    required String heightCm,
    required String weightKg,
    required String neckCm,
    required String hipsCm,
    required String waistCm,
    required String dateOfBirth,
  }) {
    if (loading || openingLoginAfterExit) return false;

    return OnboardingValidationUseCase.canSubmit(
      name: name,
      heightCm: heightCm,
      weightKg: weightKg,
      neckCm: neckCm,
      hipsCm: hipsCm,
      waistCm: waistCm,
      dateOfBirth: dateOfBirth,
    );
  }

  String? dateOfBirthValidationMessage(String? value) {
    return OnboardingValidationUseCase.dateOfBirthValidationMessage(value);
  }

  BodyFatResultEntity validateBodyFatFromText({
    required Sex sex,
    required String heightCm,
    required String neckCm,
    required String waistCm,
    required String hipsCm,
  }) {
    return OnboardingValidationUseCase.validateBodyFatFromText(
      sex: sex,
      heightCm: heightCm,
      neckCm: neckCm,
      waistCm: waistCm,
      hipsCm: hipsCm,
    );
  }

  OnboardingDataEntity? onboardingDataFromText({
    required String name,
    required String heightCm,
    required String weightKg,
    required String neckCm,
    required String hipsCm,
    required String waistCm,
    required Sex sex,
    required Goal goal,
    required ActivityLevel activity,
    required String dateOfBirth,
  }) {
    return OnboardingValidationUseCase.onboardingDataFromText(
      name: name,
      heightCm: heightCm,
      weightKg: weightKg,
      neckCm: neckCm,
      hipsCm: hipsCm,
      waistCm: waistCm,
      sex: sex,
      goal: goal,
      activity: activity,
      dateOfBirth: dateOfBirth,
    );
  }

  Future<void> markOnboardingStarted() {
    return _onboardingOperationsUseCase.markOnboardingStarted();
  }

  Future<void> signOutAfterInterruptedOnboarding() {
    return _onboardingOperationsUseCase.signOutAfterInterruptedOnboarding();
  }

  Future<void> completeOnboarding(OnboardingDataEntity data) {
    return _onboardingOperationsUseCase.completeOnboarding(data);
  }
}
