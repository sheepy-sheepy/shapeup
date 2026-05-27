import 'dart:math';
import '../../core/enums.dart';
import '../../core/number_utils.dart';

class MacroNorms {
  final double calories;
  final double proteins;
  final double fats;
  final double carbs;
  final double waterMl;

  const MacroNorms({
    required this.calories,
    required this.proteins,
    required this.fats,
    required this.carbs,
    required this.waterMl,
  });
}

class NutritionCalculator {
  static const double _cmToInch = 2.54;

  static int ageFromDob(DateTime dob, DateTime today) {
    var age = today.year - dob.year;
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  static double bodyFatPercent({
    required Sex sex,
    required double heightCm,
    required double neckCm,
    required double waistCm,
    required double hipsCm,
  }) {
    if (heightCm <= 0 || neckCm <= 0 || waistCm <= 0 || hipsCm <= 0) {
      throw ArgumentError('Все параметры должны быть больше 0');
    }

    final heightIn = heightCm / _cmToInch;
    final neckIn = neckCm / _cmToInch;
    final waistIn = waistCm / _cmToInch;
    final hipsIn = hipsCm / _cmToInch;

    late final double rawResult;

    if (sex == Sex.male) {
      final diff = waistIn - neckIn;
      if (diff <= 0) {
        throw ArgumentError('Для мужчин талия должна быть больше шеи');
      }

      rawResult =
          86.010 * (log(diff) / ln10) - 70.041 * (log(heightIn) / ln10) + 36.76;
    } else {
      final diff = waistIn + hipsIn - neckIn;
      if (diff <= 0) {
        throw ArgumentError(
          'Для женщин сумма талии и бедер должна быть больше шеи',
        );
      }

      rawResult = 163.205 * (log(diff) / ln10) -
          97.684 * (log(heightIn) / ln10) -
          78.387;
    }

    final result = roundTo(rawResult, 2);

    if (result <= 0) {
      throw ArgumentError('% жира должен быть больше 0');
    }

    return result;
  }

  static double activityKcalFactor(ActivityLevel level) => switch (level) {
        ActivityLevel.sedentary => 1.2,
        ActivityLevel.light => 1.375,
        ActivityLevel.moderate => 1.55,
        ActivityLevel.high => 1.725,
        ActivityLevel.extreme => 1.9,
      };

  static double activityWaterFactor(ActivityLevel level) => switch (level) {
        ActivityLevel.sedentary => 1.0,
        ActivityLevel.light => 1.2,
        ActivityLevel.moderate => 1.4,
        ActivityLevel.high => 1.6,
        ActivityLevel.extreme => 1.8,
      };

  static MacroNorms dailyNorms({
    required Sex sex,
    required Goal goal,
    required ActivityLevel activityLevel,
    required double weightKg,
    required double heightCm,
    required DateTime dob,
    required double deficitKcal,
    required DateTime today,
  }) {
    final age = ageFromDob(dob, today);
    final bmr = sex == Sex.male
        ? ((10 * weightKg) + (6.25 * heightCm) - (5 * age) + 5)
        : ((10 * weightKg) + (6.25 * heightCm) - (5 * age) - 161);

    final dci = bmr * activityKcalFactor(activityLevel);

    final calories = switch (goal) {
      Goal.loseWeight => dci - deficitKcal,
      Goal.gainWeight => dci + deficitKcal,
      Goal.maintain => dci,
    };

    late double proteinShare;
    late double fatShare;
    late double carbShare;

    switch (goal) {
      case Goal.loseWeight:
        proteinShare = 0.40;
        fatShare = 0.25;
        carbShare = 0.35;
      case Goal.maintain:
        proteinShare = 0.25;
        fatShare = 0.25;
        carbShare = 0.50;
      case Goal.gainWeight:
        proteinShare = 0.35;
        fatShare = 0.20;
        carbShare = 0.45;
    }

    final proteins = roundTo(((calories * proteinShare) / 4),2);
    final fats = roundTo(((calories * fatShare) / 9),2);
    final carbs = roundTo(((calories * carbShare) / 4),2);

    final waterBase = sex == Sex.male ? 35.0 : 31.0;
    final waterMl = double.parse(
      (weightKg * waterBase * activityWaterFactor(activityLevel))
          .toStringAsFixed(1),
    );

    return MacroNorms(
      calories: roundTo(calories,2),
      proteins: proteins,
      fats: fats,
      carbs: carbs,
      waterMl: waterMl,
    );
  }
}
