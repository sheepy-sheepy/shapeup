
import 'package:shapeup/core/shared/enums.dart';


abstract class SplashRepository {
  String? get currentEmail;

  Future<dynamic> waitForRestoredCurrentUser({
    Duration timeout = const Duration(seconds: 2),
  });

  Future<bool> wasExplicitlySignedOut();
  Future<bool> hasStartedButUnfinishedOnboarding();
  Future<void> signOutAfterInterruptedOnboarding();
  Future<RegistrationStatus?> restoreLastLocalSessionIfAllowed();
  Future<void> pushLocalProfileAndLatestMeasurementToSupabaseIfPossible();
  Future<RegistrationStatus?> fetchRemoteProfileAndSaveLocal();
  Future<RegistrationStatus?> localStatusForCurrentUser();
}
