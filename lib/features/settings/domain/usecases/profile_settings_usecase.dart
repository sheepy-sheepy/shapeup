import 'package:shapeup/core/shared/errors.dart';
import 'package:shapeup/core/shared/enums.dart';
import 'package:shapeup/features/settings/domain/entities/profile_settings_draft_entity.dart';
import 'package:shapeup/features/settings/domain/entities/profile_settings_initial_entity.dart';
import 'package:shapeup/features/settings/domain/repositories/profile_repository.dart';
import 'package:shapeup/features/settings/domain/usecases/profile_settings_validation_usecase.dart';
import 'package:shapeup/features/measurements/domain/entities/body_measurement_entity.dart';

export 'package:shapeup/features/settings/domain/entities/profile_settings_draft_entity.dart' show ProfileSettingsDraftEntity;
export 'package:shapeup/features/settings/domain/entities/profile_settings_initial_entity.dart' show ProfileSettingsInitialEntity;

class ProfileSettingsUseCase {
  const ProfileSettingsUseCase(this._profileRepository);

  final ProfileRepository _profileRepository;

  ProfileSettingsDraftEntity draftFromText({
    required String name,
    required String heightCm,
    required String deficitKcal,
    required String dateOfBirth,
    required Sex sex,
    required Goal goal,
    required ActivityLevel activity,
  }) {
    return ProfileSettingsValidationUseCase.draftFromText(
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
    return ProfileSettingsValidationUseCase.canSave(
      saving: saving,
      draft: draft,
      initial: initial,
      latestMeasurement: latestMeasurement,
      today: today,
    );
  }

  String? deficitValidationMessage(String? value) {
    return ProfileSettingsValidationUseCase.deficitValidationMessage(value);
  }

  String? dateOfBirthValidationMessage(String? value) {
    return ProfileSettingsValidationUseCase.dateOfBirthValidationMessage(value);
  }

  Sex sexFromUser(LocalUserEntity user, {Sex fallback = Sex.male}) {
    return ProfileSettingsValidationUseCase.sexFromUser(user, fallback: fallback);
  }

  Goal goalFromUser(LocalUserEntity user, {Goal fallback = Goal.loseWeight}) {
    return ProfileSettingsValidationUseCase.goalFromUser(user, fallback: fallback);
  }

  ActivityLevel activityFromUser(
    LocalUserEntity user, {
    ActivityLevel fallback = ActivityLevel.sedentary,
  }) {
    return ProfileSettingsValidationUseCase.activityFromUser(user, fallback: fallback);
  }

  ProfileSettingsInitialEntity initialValuesFromUser({
    required LocalUserEntity user,
    required Sex sex,
    required Goal goal,
    required ActivityLevel activity,
  }) {
    return ProfileSettingsValidationUseCase.initialValuesFromUser(
      user: user,
      sex: sex,
      goal: goal,
      activity: activity,
    );
  }

  Future<void> saveProfile(ProfileSettingsDraftEntity draft) {
    final heightCm = draft.heightCm;
    final deficitKcal = draft.deficitKcal;
    final dateOfBirth = draft.dateOfBirth;

    if (heightCm == null || deficitKcal == null || dateOfBirth == null) {
      throw const AppException(profileSaveFailedMessage);
    }

    return _profileRepository.updateProfileSettings(
      name: draft.name,
      sex: draft.sex.name,
      goal: draft.goal.name,
      activityLevel: draft.activity.name,
      heightCm: heightCm,
      deficitKcal: deficitKcal,
      dateOfBirth: dateOfBirth,
    );
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _profileRepository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
