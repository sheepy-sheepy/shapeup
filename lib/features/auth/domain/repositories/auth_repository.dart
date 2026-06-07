import 'package:shapeup/core/shared/enums.dart';


abstract class AuthRepository {
  dynamic get currentUser;
  String? get currentUserId;
  String? get currentEmail;
  String? get activeRemoteUserId;

  Future<dynamic> waitForRestoredCurrentUser({
    Duration timeout = const Duration(seconds: 2),
  });

  Future<bool> wasExplicitlySignedOut();
  Future<bool> hasStartedButUnfinishedOnboarding();
  Future<void> markOnboardingStarted();
  Future<void> clearStartedButUnfinishedOnboarding();
  Future<void> signOutAfterInterruptedOnboarding();
  Future<RegistrationStatus?> restoreLastLocalSessionIfAllowed();

  Future<RegistrationStatus?> signInLocalIfExists({
    required String email,
    String? password,
    bool warmUpRemoteSession = false,
  });

  void startRemoteSessionWarmUpForLocalAccount({
    required String email,
    required String password,
  });

  Future<void> waitForRemoteSessionWarmUp({
    Duration maxWait = const Duration(seconds: 4),
  });

  Future<void> pushLocalProfileAndLatestMeasurementToSupabaseIfPossible();

  Future<void> cacheLocalPasswordForCurrentUser({required String password});

  Future<RegistrationStatus?> localStatusForCurrentUser();
  Future<void> signUp({required String email, required String password});
  Future<bool> isEmailRegisteredInSupabase(String email);
  Future<void> signIn({required String email, required String password});
  Future<void> verifyOtp({required String email, required String token});
  Future<void> resendOtp({required String email});
  Future<void> signOut({bool explicit = true});
  Future<RegistrationStatus?> fetchRemoteProfileAndSaveLocal();
  Future<void> saveLocalStatus({
    required String userId,
    required String email,
    required RegistrationStatus status,
  });
  Future<void> updateStatusRemoteThenLocal(RegistrationStatus status);
}
