import 'package:shapeup/features/diary/domain/entities/norm_frame_entity.dart';
import 'package:shapeup/features/diary/domain/entities/diary_totals_entity.dart';
import 'package:shapeup/domain/entities/macro_norms_entity.dart';

export 'package:shapeup/features/diary/domain/entities/norm_frame_entity.dart' show NormFrameEntity;

class DiaryNormFrameUseCase {
  const DiaryNormFrameUseCase._();

  static const double calorieOverStepKcal = 100;
  static const double macroOverStepGrams = 50;
  static const double maxRedPowerUnits = 5;

  static NormFrameEntity calculate({
    required DiaryTotalsEntity totals,
    required MacroNormsEntity norms,
  }) {
    if (norms.calories <= 0) {
      return const NormFrameEntity(
        hasValidNorms: false,
        calorieProgress: 0,
        redPower: 0,
      );
    }

    final calorieProgress = _clamp01(totals.calories / norms.calories);

    final caloriesOver = _positiveDifference(totals.calories, norms.calories);
    final proteinsOver = _positiveDifference(totals.proteins, norms.proteins);
    final fatsOver = _positiveDifference(totals.fats, norms.fats);
    final carbsOver = _positiveDifference(totals.carbs, norms.carbs);

    final overUnits = _max4(
      _overUnits(caloriesOver, calorieOverStepKcal),
      _overUnits(proteinsOver, macroOverStepGrams),
      _overUnits(fatsOver, macroOverStepGrams),
      _overUnits(carbsOver, macroOverStepGrams),
    );

    return NormFrameEntity(
      hasValidNorms: true,
      calorieProgress: calorieProgress,
      redPower: _clamp01(overUnits / maxRedPowerUnits),
    );
  }

  static double _positiveDifference(double current, double norm) {
    final diff = current - norm;
    return diff <= 0 ? 0 : diff;
  }

  static double _overUnits(double overValue, double step) {
    return overValue < step ? 0 : overValue / step;
  }

  static double _clamp01(double value) {
    return value.clamp(0.0, 1.0).toDouble();
  }

  static double _max4(double a, double b, double c, double d) {
    final ab = a > b ? a : b;
    final cd = c > d ? c : d;
    return ab > cd ? ab : cd;
  }
}
