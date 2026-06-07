import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shapeup/core/shared/dates.dart';

class AppRefreshController extends StateNotifier<String>
    with WidgetsBindingObserver {
  AppRefreshController() : super(dayKeyFromDate(DateTime.now())) {
    WidgetsBinding.instance.addObserver(this);
    _scheduleNextMidnightCheck();

    _safetyTimer = Timer.periodic(
      const Duration(minutes: 1),
      (_) => _refreshDayKey(),
    );
  }

  Timer? _midnightTimer;
  Timer? _safetyTimer;

  void _scheduleNextMidnightCheck() {
    _midnightTimer?.cancel();

    final now = DateTime.now();
    final nextMidnight = DateTime(
      now.year,
      now.month,
      now.day + 1,
    ).add(const Duration(seconds: 1));

    _midnightTimer = Timer(nextMidnight.difference(now), () {
      _refreshDayKey();
      _scheduleNextMidnightCheck();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;

    _refreshDayKey();
    _scheduleNextMidnightCheck();
  }

  void _refreshDayKey() {
    final next = dayKeyFromDate(DateTime.now());
    if (next == state) return;
    state = next;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _midnightTimer?.cancel();
    _safetyTimer?.cancel();
    super.dispose();
  }
}
