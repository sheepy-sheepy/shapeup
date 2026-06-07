
import 'package:shapeup/core/shared/enums.dart';
import 'package:shapeup/features/settings/domain/usecases/profile_settings_usecase.dart';
import 'package:shapeup/features/measurements/domain/entities/body_measurement_entity.dart';
import 'package:shapeup/features/settings/domain/entities/local_user_entity.dart';
export 'package:shapeup/features/settings/domain/usecases/load_profile_settings_usecase.dart';
export 'package:shapeup/features/settings/domain/usecases/profile_settings_usecase.dart'
    show ProfileSettingsDraftEntity, ProfileSettingsInitialEntity;


class ProfileSettingsController {
  const ProfileSettingsController(this._profileSettingsUseCase);

  final ProfileSettingsUseCase _profileSettingsUseCase;

  ProfileSettingsDraftEntity draftFromText({
    required String name,
    required String heightCm,
    required String deficitKcal,
    required String dateOfBirth,
    required Sex sex,
    required Goal goal,
    required ActivityLevel activity,
  }) {
    return _profileSettingsUseCase.draftFromText(
      name: name,
      heightCm: heightCm,
      deficitKcal: deficitKcal,
      dateOfBirth: dateOfBirth,
      sex: sex,
      goal: goal,
      activity: activity,
    );
  }

  bool canSave({
    required bool saving,
    required ProfileSettingsDraftEntity draft,
    required ProfileSettingsInitialEntity initial,
    required BodyMeasurementEntity? latestMeasurement,
    DateTime? today,
  }) {
    return _profileSettingsUseCase.canSave(
      saving: saving,
      draft: draft,
      initial: initial,
      latestMeasurement: latestMeasurement,
      today: today,
    );
  }

  String? deficitValidationMessage(String? value) {
    return _profileSettingsUseCase.deficitValidationMessage(value);
  }

  String? dateOfBirthValidationMessage(String? value) {
    return _profileSettingsUseCase.dateOfBirthValidationMessage(value);
  }

  Sex sexFromUser(LocalUserEntity user, {Sex fallback = Sex.male}) {
    return _profileSettingsUseCase.sexFromUser(user, fallback: fallback);
  }

  Goal goalFromUser(LocalUserEntity user, {Goal fallback = Goal.loseWeight}) {
    return _profileSettingsUseCase.goalFromUser(user, fallback: fallback);
  }

  ActivityLevel activityFromUser(
    LocalUserEntity user, {
    ActivityLevel fallback = ActivityLevel.sedentary,
  }) {
    return _profileSettingsUseCase.activityFromUser(user, fallback: fallback);
  }

  ProfileSettingsInitialEntity initialValuesFromUser({
    required LocalUserEntity user,
    required Sex sex,
    required Goal goal,
    required ActivityLevel activity,
  }) {
    return _profileSettingsUseCase.initialValuesFromUser(
      user: user,
      sex: sex,
      goal: goal,
      activity: activity,
    );
  }

  Future<void> saveProfile(ProfileSettingsDraftEntity draft) {
    return _profileSettingsUseCase.saveProfile(draft);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _profileSettingsUseCase.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
