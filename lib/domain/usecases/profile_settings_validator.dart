import '../../core/app_errors.dart';
import '../../core/date_utils.dart';
import '../../core/enums.dart';
import '../../core/number_utils.dart';
import '../entities/local_entities.dart';
import '../services/nutrition_calculator.dart';

class ProfileSettingsDraft {
  const ProfileSettingsDraft({
    required this.name,
    required this.heightCm,
    required this.deficitKcal,
    required this.dateOfBirth,
    required this.sex,
    required this.goal,
    required this.activity,
  });

  final String name;
  final double? heightCm;
  final double? deficitKcal;
  final DateTime? dateOfBirth;
  final Sex sex;
  final Goal goal;
  final ActivityLevel activity;
}

class ProfileSettingsInitialValues {
  const ProfileSettingsInitialValues({
    required this.name,
    required this.heightCm,
    required this.deficitKcal,
    required this.dateOfBirth,
    required this.sex,
    required this.goal,
    required this.activity,
  });

  final String name;
  final double? heightCm;
  final double? deficitKcal;
  final DateTime? dateOfBirth;
  final Sex? sex;
  final Goal? goal;
  final ActivityLevel? activity;
}

class ProfileSettingsValidator {
  const ProfileSettingsValidator._();

  static const double minDeficitKcal = 50;
  static const double maxDeficitKcal = 1000;

  static double? positiveNumberFromText(String value) {
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed == null || parsed <= 0 || !parsed.isFinite) return null;
    return roundTo1(parsed);
  }

  static double? deficitFromText(String value) {
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed == null ||
        parsed < minDeficitKcal ||
        parsed > maxDeficitKcal ||
        !parsed.isFinite) {
      return null;
    }
    return roundTo0(parsed);
  }

  static DateTime? dateOfBirthFromText(String value) {
    return tryParseRuDate(value);
  }

  static String? deficitValidationMessage(String? value) {
    final parsed = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
    if (parsed == null) return enterNumberMessage;
    if (parsed < minDeficitKcal || parsed > maxDeficitKcal) {
      return deficitRangeMessage;
    }
    return null;
  }

  static String? dateOfBirthValidationMessage(String? value) {
    if (dateOfBirthFromText(value ?? '') == null) return dateFormatMessage;
    return null;
  }

  static Sex sexFromUser(LocalUser user, {Sex fallback = Sex.male}) {
    final sexName = user.sex;
    if (sexName == null) return fallback;

    for (final item in Sex.values) {
      if (item.name == sexName) return item;
    }

    return fallback;
  }

  static Goal goalFromUser(
    LocalUser user, {
    Goal fallback = Goal.loseWeight,
  }) {
    final goalName = user.goal;
    if (goalName == null) return fallback;

    for (final item in Goal.values) {
      if (item.name == goalName) return item;
    }

    return fallback;
  }

  static ActivityLevel activityFromUser(
    LocalUser user, {
    ActivityLevel fallback = ActivityLevel.sedentary,
  }) {
    final activityName = user.activityLevel;
    if (activityName == null) return fallback;

    for (final item in ActivityLevel.values) {
      if (item.name == activityName) return item;
    }

    return fallback;
  }

  static ProfileSettingsDraft draftFromText({
    required String name,
    required String heightCm,
    required String deficitKcal,
    required String dateOfBirth,
    required Sex sex,
    required Goal goal,
    required ActivityLevel activity,
  }) {
    return ProfileSettingsDraft(
      name: name.trim(),
      heightCm: positiveNumberFromText(heightCm),
      deficitKcal: deficitFromText(deficitKcal),
      dateOfBirth: dateOfBirthFromText(dateOfBirth),
      sex: sex,
      goal: goal,
      activity: activity,
    );
  }

  static ProfileSettingsInitialValues initialValuesFromUser({
    required LocalUser user,
    required Sex sex,
    required Goal goal,
    required ActivityLevel activity,
  }) {
    return ProfileSettingsInitialValues(
      name: user.name ?? '',
      heightCm: user.heightCm == null ? null : roundTo1(user.heightCm!),
      deficitKcal: roundTo0(user.deficitKcal),
      dateOfBirth: user.dateOfBirth,
      sex: sex,
      goal: goal,
      activity: activity,
    );
  }

  static bool canSave({
    required bool saving,
    required ProfileSettingsDraft draft,
    required ProfileSettingsInitialValues initial,
    required BodyMeasurement? latestMeasurement,
    DateTime? today,
  }) {
    if (saving) return false;
    if (draft.name.trim().isEmpty) return false;
    if (draft.heightCm == null) return false;
    if (draft.deficitKcal == null) return false;
    if (draft.dateOfBirth == null) return false;
    if (!hasChanges(draft: draft, initial: initial)) return false;

    return calorieNormIsValid(
      draft: draft,
      latestMeasurement: latestMeasurement,
      today: today ?? DateTime.now(),
    );
  }

  static bool hasChanges({
    required ProfileSettingsDraft draft,
    required ProfileSettingsInitialValues initial,
  }) {
    return draft.name.trim() != initial.name ||
        !_sameDouble(draft.heightCm, initial.heightCm) ||
        !_sameDouble(draft.deficitKcal, initial.deficitKcal) ||
        !_sameDate(draft.dateOfBirth, initial.dateOfBirth) ||
        draft.sex != initial.sex ||
        draft.goal != initial.goal ||
        draft.activity != initial.activity;
  }

  static bool calorieNormIsValid({
    required ProfileSettingsDraft draft,
    required BodyMeasurement? latestMeasurement,
    required DateTime today,
  }) {
    if (draft.goal != Goal.loseWeight) return true;
    if (latestMeasurement == null) return true;

    final heightCm = draft.heightCm;
    final deficitKcal = draft.deficitKcal;
    final dateOfBirth = draft.dateOfBirth;

    if (heightCm == null || deficitKcal == null || dateOfBirth == null) {
      return false;
    }

    final norms = NutritionCalculator.dailyNorms(
      sex: draft.sex,
      goal: draft.goal,
      activityLevel: draft.activity,
      weightKg: latestMeasurement.weightKg,
      heightCm: heightCm,
      dob: dateOfBirth,
      deficitKcal: deficitKcal,
      today: today,
    );

    return norms.calories > 0;
  }

  static bool _sameDate(DateTime? a, DateTime? b) {
    if (a == null || b == null) return a == b;

    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool _sameDouble(double? a, double? b) {
    if (a == null || b == null) return a == b;
    return (a - b).abs() < 0.001;
  }
}
