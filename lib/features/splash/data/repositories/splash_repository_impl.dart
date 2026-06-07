
import 'package:shapeup/core/shared/enums.dart';
import 'package:shapeup/features/splash/domain/repositories/splash_repository.dart' as domain;
import 'package:shapeup/features/auth/domain/repositories/auth_repository.dart';

class SplashRepositoryImpl implements domain.SplashRepository {
  const SplashRepositoryImpl(this.authRepository);

  final AuthRepository authRepository;

  @override
  String? get currentEmail => authRepository.currentEmail;

  @override
  Future<dynamic> waitForRestoredCurrentUser({
    Duration timeout = const Duration(seconds: 2),
  }) {
    return authRepository.waitForRestoredCurrentUser(timeout: timeout);
  }

  @override
  Future<bool> wasExplicitlySignedOut() {
    return authRepository.wasExplicitlySignedOut();
  }

  @override
  Future<bool> hasStartedButUnfinishedOnboarding() {
    return authRepository.hasStartedButUnfinishedOnboarding();
  }

  @override
  Future<void> signOutAfterInterruptedOnboarding() {
    return authRepository.signOutAfterInterruptedOnboarding();
  }

  @override
  Future<RegistrationStatus?> restoreLastLocalSessionIfAllowed() {
    return authRepository.restoreLastLocalSessionIfAllowed();
  }

  @override
  Future<void> pushLocalProfileAndLatestMeasurementToSupabaseIfPossible() {
    return authRepository.pushLocalProfileAndLatestMeasurementToSupabaseIfPossible();
  }

  @override
  Future<RegistrationStatus?> fetchRemoteProfileAndSaveLocal() {
    return authRepository.fetchRemoteProfileAndSaveLocal();
  }

  @override
  Future<RegistrationStatus?> localStatusForCurrentUser() {
    return authRepository.localStatusForCurrentUser();
  }
}
