import 'package:shapeup/core/shared/errors.dart';
import 'package:shapeup/core/shared/dates.dart';
import 'package:shapeup/core/shared/enums.dart';
import 'package:shapeup/core/shared/numbers.dart';
import 'package:shapeup/features/settings/domain/entities/profile_settings_draft_entity.dart';
import 'package:shapeup/features/settings/domain/entities/profile_settings_initial_entity.dart';
import 'package:shapeup/domain/usecases/nutrition_calculation_usecase.dart';
import 'package:shapeup/features/measurements/domain/entities/body_measurement_entity.dart';
import 'package:shapeup/features/settings/domain/entities/local_user_entity.dart';

class ProfileSettingsValidationUseCase {
  const ProfileSettingsValidationUseCase._();

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

  static Sex sexFromUser(LocalUserEntity user, {Sex fallback = Sex.male}) {
    final sexName = user.sex;
    if (sexName == null) return fallback;

    for (final item in Sex.values) {
      if (item.name == sexName) return item;
    }

    return fallback;
  }

  static Goal goalFromUser(
    LocalUserEntity user, {
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
    LocalUserEntity user, {
    ActivityLevel fallback = ActivityLevel.sedentary,
  }) {
    final activityName = user.activityLevel;
    if (activityName == null) return fallback;

    for (final item in ActivityLevel.values) {
      if (item.name == activityName) return item;
    }

    return fallback;
  }

  static ProfileSettingsDraftEntity draftFromText({
    required String name,
    required String heightCm,
    required String deficitKcal,
    required String dateOfBirth,
    required Sex sex,
    required Goal goal,
    required ActivityLevel activity,
  }) {
    return ProfileSettingsDraftEntity(
      name: name.trim(),
      heightCm: positiveNumberFromText(heightCm),
      deficitKcal: deficitFromText(deficitKcal),
      dateOfBirth: dateOfBirthFromText(dateOfBirth),
      sex: sex,
      goal: goal,
      activity: activity,
    );
  }

  static ProfileSettingsInitialEntity initialValuesFromUser({
    required LocalUserEntity user,
    required Sex sex,
    required Goal goal,
    required ActivityLevel activity,
  }) {
    return ProfileSettingsInitialEntity(
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
    required ProfileSettingsDraftEntity draft,
    required ProfileSettingsInitialEntity initial,
    required BodyMeasurementEntity? latestMeasurement,
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
    required ProfileSettingsDraftEntity draft,
    required ProfileSettingsInitialEntity initial,
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
    required ProfileSettingsDraftEntity draft,
    required BodyMeasurementEntity? latestMeasurement,
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

    final norms = NutritionCalculationUseCase.dailyNorms(
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
