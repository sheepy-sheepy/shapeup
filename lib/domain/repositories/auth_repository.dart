import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/enums.dart';
import '../../core/preferences_service.dart';

const otpResendCooldownSeconds = 60;
const _otpCooldownExpiresAtKey = 'otp_cooldown_expires_at_ms';

class OtpCooldownState {
  final DateTime? expiresAt;
  final int secondsLeft;
  final bool initialized;

  const OtpCooldownState({
    required this.expiresAt,
    required this.secondsLeft,
    required this.initialized,
  });

  bool get canResend => initialized && secondsLeft == 0;

  OtpCooldownState copyWith({
    DateTime? expiresAt,
    int? secondsLeft,
    bool? initialized,
    bool clearExpiresAt = false,
  }) {
    return OtpCooldownState(
      expiresAt: clearExpiresAt ? null : (expiresAt ?? this.expiresAt),
      secondsLeft: secondsLeft ?? this.secondsLeft,
      initialized: initialized ?? this.initialized,
    );
  }

  static const initial = OtpCooldownState(
    expiresAt: null,
    secondsLeft: 0,
    initialized: false,
  );
}

class OtpCooldownNotifier extends StateNotifier<OtpCooldownState> {
  OtpCooldownNotifier(this._preferences) : super(OtpCooldownState.initial) {
    _restore();
  }

  final PreferencesService _preferences;
  Timer? _timer;

  Future<void> _restore() async {
    final expiresAtMs = await _preferences.getInt(_otpCooldownExpiresAtKey);

    if (expiresAtMs == null) {
      state = state.copyWith(
        initialized: true,
        secondsLeft: 0,
        clearExpiresAt: true,
      );
      return;
    }

    final expiresAt = DateTime.fromMillisecondsSinceEpoch(expiresAtMs);
    final diff = expiresAt.difference(DateTime.now()).inSeconds;

    if (diff <= 0) {
      await clear();
      state = state.copyWith(
        initialized: true,
        secondsLeft: 0,
        clearExpiresAt: true,
      );
      return;
    }

    state = state.copyWith(
      initialized: true,
      expiresAt: expiresAt,
      secondsLeft: diff,
    );
    _startTicker();
  }

  Future<void> startCooldown([int seconds = otpResendCooldownSeconds]) async {
    final expiresAt = DateTime.now().add(Duration(seconds: seconds));
    await _preferences.setInt(
      _otpCooldownExpiresAtKey,
      expiresAt.millisecondsSinceEpoch,
    );

    state = state.copyWith(
      initialized: true,
      expiresAt: expiresAt,
      secondsLeft: seconds,
    );
    _startTicker();
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final expiresAt = state.expiresAt;
      if (expiresAt == null) {
        timer.cancel();
        state = state.copyWith(secondsLeft: 0);
        return;
      }

      final diff = expiresAt.difference(DateTime.now()).inSeconds;
      if (diff <= 0) {
        timer.cancel();
        await clear();
        state = state.copyWith(
          secondsLeft: 0,
          clearExpiresAt: true,
          initialized: true,
        );
      } else {
        state = state.copyWith(secondsLeft: diff);
      }
    });
  }

  Future<void> clear() async {
    _timer?.cancel();
    await _preferences.remove(_otpCooldownExpiresAtKey);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final otpCooldownProvider =
    StateNotifierProvider<OtpCooldownNotifier, OtpCooldownState>(
  (ref) => OtpCooldownNotifier(ref.watch(preferencesServiceProvider)),
);

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('AuthRepository должен быть подключен в data-слое');
});

abstract class AuthRepository {
  dynamic get currentUser;
  String? get currentUserId;
  String? get currentEmail;
  String? get activeRemoteUserId;

  Future<dynamic> waitForRestoredCurrentUser({
    Duration timeout = const Duration(seconds: 2),
  });

  Future<bool> wasExplicitlySignedOut();
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
