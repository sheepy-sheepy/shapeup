

class WaterIntakeUseCase {
  const WaterIntakeUseCase._();

  static double? positiveVolumeFromText(String value) {
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed == null || parsed <= 0) return null;
    return parsed;
  }

  static double nextAmount({
    required double current,
    required double delta,
    required bool increase,
  }) {
    final next = increase ? current + delta : current - delta;
    return next < 0 ? 0.0 : next;
  }
}
