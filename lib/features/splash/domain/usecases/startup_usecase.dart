import 'package:shapeup/core/shared/enums.dart';
import 'package:shapeup/features/splash/domain/entities/startup_route_target_entity.dart';
import 'package:shapeup/features/splash/domain/repositories/splash_repository.dart';

export 'package:shapeup/features/splash/domain/entities/startup_route_target_entity.dart' show StartupRouteTargetEntity;

class StartupUseCase {
  const StartupUseCase(this.auth);

  final SplashRepository auth;

  Future<StartupRouteTargetEntity> resolveInitialRoute() async {
    if (await auth.wasExplicitlySignedOut()) {
      return const StartupRouteTargetEntity('/login');
    }

    if (await auth.hasStartedButUnfinishedOnboarding()) {
      try {
        await auth.signOutAfterInterruptedOnboarding();
      } catch (_) {}
      return const StartupRouteTargetEntity('/login');
    }

    final user = await auth.waitForRestoredCurrentUser();

    RegistrationStatus? status;
    String email = user?.email ?? '';

    if (user == null) {
      status = await auth.restoreLastLocalSessionIfAllowed();
      email = auth.currentEmail ?? '';
    } else {
      try {
        await auth.pushLocalProfileAndLatestMeasurementToSupabaseIfPossible();
        status = await auth.fetchRemoteProfileAndSaveLocal();
      } catch (_) {
        status = await auth.localStatusForCurrentUser();
      }
    }

    return _routeByStatus(status, email: email);
  }

  Future<StartupRouteTargetEntity> _routeByStatus(
    RegistrationStatus? status, {
    required String email,
  }) async {
    switch (status) {
      case RegistrationStatus.fullyRegistered:
        return const StartupRouteTargetEntity('/home');

      case RegistrationStatus.onboardingNotDone:
        return const StartupRouteTargetEntity('/onboarding');

      case RegistrationStatus.emailUnconfirmed:
        return StartupRouteTargetEntity(
          '/otp',
          extra: email,
          startOtpCooldown: true,
        );

      case null:
        return const StartupRouteTargetEntity('/login');
    }
  }
}
