class BodyMeasurementEntity {
  const BodyMeasurementEntity({
    required this.id,
    required this.userId,
    required this.dayKey,
    required this.weightKg,
    required this.neckCm,
    required this.waistCm,
    required this.hipsCm,
    required this.bodyFatPercent,
  });

  final String id;
  final String userId;
  final String dayKey;
  final double weightKg;
  final double neckCm;
  final double waistCm;
  final double hipsCm;
  final double bodyFatPercent;
}
