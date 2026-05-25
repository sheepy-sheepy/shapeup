import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../entities/local_entities.dart';
import '../entities/onboarding_data.dart';

export '../entities/local_entities.dart' show LocalUser;
export '../entities/onboarding_data.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  throw UnimplementedError('ProfileRepository должен быть подключен в data-слое');
});

abstract class ProfileRepository {
  Future<void> completeOnboarding(OnboardingData data);
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
  Future<LocalUser?> getCurrentLocalUser();
}
