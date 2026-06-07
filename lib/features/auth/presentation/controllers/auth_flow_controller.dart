import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shapeup/core/shared/errors.dart';
import 'package:shapeup/core/shared/enums.dart';
import 'package:shapeup/features/auth/presentation/controllers/otp_cooldown_controller.dart';
import 'package:shapeup/features/auth/domain/usecases/auth_usecase.dart';
import 'package:shapeup/features/auth/domain/entities/auth_route_target_entity.dart';

class AuthFlowController {
  const AuthFlowController({
    required AuthUseCase authUseCase,
    required OtpCooldownNotifier otpCooldownNotifier,
  })  : _authUseCase = authUseCase,
        _otpCooldownNotifier = otpCooldownNotifier;

  final AuthUseCase _authUseCase;
  final OtpCooldownNotifier _otpCooldownNotifier;

  bool canVerifyOtp(String code) {
    return RegExp(r'^\d{6}$').hasMatch(code);
  }

  Future<AuthRouteTargetEntity> login({
    required String email,
    required String password,
  }) async {
    final localStatus = await _authUseCase.signInLocalIfExists(
      email: email,
      password: password,
      warmUpRemoteSession: true,
    );

    if (localStatus != null) {
      return _routeByStatus(localStatus, email: email);
    }

    try {
      await _authUseCase.signIn(
        email: email,
        password: password,
      );
    } on AuthException catch (error) {
      if (_isEmailNotConfirmed(error)) {
        await _otpCooldownNotifier.startCooldown();
        return AuthRouteTargetEntity('/otp', extra: email);
      }

      rethrow;
    }

    final status = await _authUseCase.fetchRemoteProfileAndSaveLocal();
    return _routeByStatus(status, email: email);
  }

  Future<AuthRouteTargetEntity> register({
    required String email,
    required String password,
  }) async {
    await _authUseCase.signUp(email: email, password: password);

    final user = _authUseCase.currentUser;
    if (user != null) {
      await _authUseCase.saveLocalStatus(
        userId: user.id,
        email: email,
        status: RegistrationStatus.emailUnconfirmed,
      );
    }

    await _otpCooldownNotifier.startCooldown();
    return AuthRouteTargetEntity('/otp', extra: email);
  }

  Future<AuthRouteTargetEntity> verifyOtp({
    required String email,
    required String token,
  }) async {
    await _authUseCase.verifyOtp(
      email: email,
      token: token,
    );

    await _authUseCase.updateStatusRemoteThenLocal(
      RegistrationStatus.onboardingNotDone,
    );

    await _authUseCase.markOnboardingStarted();
    await _otpCooldownNotifier.clear();
    return const AuthRouteTargetEntity('/onboarding');
  }

  Future<void> resendOtp({required String email}) async {
    await _authUseCase.resendOtp(email: email);
    await _otpCooldownNotifier.startCooldown();
  }

  Future<void> startOtpCooldown() {
    return _otpCooldownNotifier.startCooldown();
  }

  Future<void> signOut({bool explicit = true}) {
    return _authUseCase.signOut(explicit: explicit);
  }

  Future<AuthRouteTargetEntity> _routeByStatus(
    RegistrationStatus? status, {
    required String email,
  }) async {
    switch (status) {
      case RegistrationStatus.emailUnconfirmed:
        await _otpCooldownNotifier.startCooldown();
        return AuthRouteTargetEntity('/otp', extra: email);
      case RegistrationStatus.onboardingNotDone:
        return const AuthRouteTargetEntity('/onboarding');
      case RegistrationStatus.fullyRegistered:
        await _authUseCase.clearStartedButUnfinishedOnboarding();
        return const AuthRouteTargetEntity('/home');
      case null:
        throw const AppException(registrationStatusNotFoundMessage);
    }
  }

  bool _isEmailNotConfirmed(AuthException error) {
    final message = error.message.toLowerCase();
    return message.contains('email not confirmed') ||
        message.contains('email_not_confirmed') ||
        error.statusCode == '400';
  }
}
