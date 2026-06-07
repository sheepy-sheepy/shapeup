
import 'package:shapeup/features/onboarding/domain/entities/onboarding_data_entity.dart';
import 'package:shapeup/features/settings/domain/entities/local_user_entity.dart';

export 'package:shapeup/features/settings/domain/entities/local_user_entity.dart' show LocalUserEntity;
export 'package:shapeup/features/onboarding/domain/entities/onboarding_data_entity.dart' show OnboardingDataEntity;


abstract class ProfileRepository {
  Future<void> completeOnboarding(OnboardingDataEntity data);
  Future<void> updateProfileSettings({
    required String name,
    required String sex,
    required String goal,
    required String activityLevel,
    required double heightCm,
    required double deficitKcal,
    required DateTime dateOfBirth,
  });
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
  Future<LocalUserEntity?> getCurrentLocalUser();
}
