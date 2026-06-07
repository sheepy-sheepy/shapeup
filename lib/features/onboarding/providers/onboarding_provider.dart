import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shapeup/features/auth/providers/auth_provider.dart' as auth;
import 'package:shapeup/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:shapeup/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:shapeup/features/onboarding/domain/usecases/onboarding_usecase.dart';
import 'package:shapeup/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:shapeup/features/settings/providers/settings_provider.dart' as settings;

final onboardingRepositoryProvider = Provider<OnboardingRepository>((ref) {
  return OnboardingRepositoryImpl(
    ref.watch(settings.profileRepositoryProvider),
  );
});

final onboardingUseCaseProvider = Provider<OnboardingUseCase>((ref) {
  return OnboardingUseCase(
    authRepository: ref.watch(auth.authRepositoryProvider),
    onboardingRepository: ref.watch(onboardingRepositoryProvider),
  );
});

final onboardingControllerProvider = Provider<OnboardingController>((ref) {
  return OnboardingController(
    onboardingOperationsUseCase: ref.watch(onboardingUseCaseProvider),
  );
});
