import 'package:flutter/widgets.dart';

mixin TodayChangeScheduler<T extends StatefulWidget> on State<T> {
  String? _pendingTodayKey;

  void scheduleTodayChangeIfNeeded({
    required String currentTodayKey,
    required String nextTodayKey,
    required ValueChanged<String> onTodayChanged,
  }) {
    if (nextTodayKey == currentTodayKey || nextTodayKey == _pendingTodayKey) {
      return;
    }

    _pendingTodayKey = nextTodayKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        if (_pendingTodayKey == nextTodayKey) {
          _pendingTodayKey = null;
        }
        return;
      }

      onTodayChanged(nextTodayKey);

      if (_pendingTodayKey == nextTodayKey) {
        _pendingTodayKey = null;
      }
    });
  }
}
