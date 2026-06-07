import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shapeup/core/shared/preferences.dart';

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

