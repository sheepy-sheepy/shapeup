import 'package:shapeup/core/shared/enums.dart';
import 'package:shapeup/features/auth/domain/repositories/auth_repository.dart';
class AuthUseCase {
  const AuthUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<RegistrationStatus?> signInLocalIfExists({
    required String email,
    required String password,
    bool warmUpRemoteSession = false,
  }) {
    return _authRepository.signInLocalIfExists(
      email: email,
      password: password,
      warmUpRemoteSession: warmUpRemoteSession,
    );
  }

  Future<void> signIn({required String email, required String password}) {
    return _authRepository.signIn(email: email, password: password);
  }

  Future<RegistrationStatus?> fetchRemoteProfileAndSaveLocal() {
    return _authRepository.fetchRemoteProfileAndSaveLocal();
  }

  Future<void> signUp({required String email, required String password}) {
    return _authRepository.signUp(email: email, password: password);
  }

  dynamic get currentUser => _authRepository.currentUser;

  Future<void> saveLocalStatus({
    required String userId,
    required String email,
    required RegistrationStatus status,
  }) {
    return _authRepository.saveLocalStatus(
      userId: userId,
      email: email,
      status: status,
    );
  }

  Future<void> verifyOtp({required String email, required String token}) {
    return _authRepository.verifyOtp(email: email, token: token);
  }

  Future<void> updateStatusRemoteThenLocal(RegistrationStatus status) {
    return _authRepository.updateStatusRemoteThenLocal(status);
  }

  Future<void> resendOtp({required String email}) {
    return _authRepository.resendOtp(email: email);
  }

  Future<void> markOnboardingStarted() {
    return _authRepository.markOnboardingStarted();
  }

  Future<void> clearStartedButUnfinishedOnboarding() {
    return _authRepository.clearStartedButUnfinishedOnboarding();
  }

  Future<void> signOut({bool explicit = true}) {
    return _authRepository.signOut(explicit: explicit);
  }
}
