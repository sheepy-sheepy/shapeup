class NormFrameEntity {
  const NormFrameEntity({
    required this.hasValidNorms,
    required this.calorieProgress,
    required this.redPower,
  });

  final bool hasValidNorms;
  final double calorieProgress;
  final double redPower;

  bool get hasOverage => redPower > 0;
}
