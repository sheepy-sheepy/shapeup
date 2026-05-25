import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/enums.dart';
import '../repositories/auth_repository.dart';

final startupCoordinatorProvider = Provider<StartupCoordinator>((ref) {
  return StartupCoordinator(ref.watch(authRepositoryProvider));
});

class StartupRouteTarget {
  const StartupRouteTarget(
    this.path, {
    this.extra,
    this.startOtpCooldown = false,
  });

  final String path;
  final Object? extra;
  final bool startOtpCooldown;
}

class StartupCoordinator {
  const StartupCoordinator(this.auth);

  final AuthRepository auth;

  Future<StartupRouteTarget> resolveInitialRoute() async {
    if (await auth.wasExplicitlySignedOut()) {
      return const StartupRouteTarget('/login');
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

  Future<StartupRouteTarget> _routeByStatus(
    RegistrationStatus? status, {
    required String email,
  }) async {
    switch (status) {
      case RegistrationStatus.fullyRegistered:
        return const StartupRouteTarget('/home');

      case RegistrationStatus.onboardingNotDone:
        return const StartupRouteTarget('/onboarding');

      case RegistrationStatus.emailUnconfirmed:
        return StartupRouteTarget(
          '/otp',
          extra: email,
          startOtpCooldown: true,
        );

      case null:
        return const StartupRouteTarget('/login');
    }
  }
}
