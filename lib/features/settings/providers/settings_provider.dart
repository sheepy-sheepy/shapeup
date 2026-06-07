import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shapeup/presentation/providers/app_providers.dart' as app_providers;

import 'package:shapeup/features/auth/providers/auth_provider.dart' as auth;
import 'package:shapeup/features/measurements/providers/measurements_provider.dart' as measurements;
import 'package:shapeup/features/settings/data/repositories/profile_repository_impl.dart';
import 'package:shapeup/features/settings/domain/repositories/profile_repository.dart';
import 'package:shapeup/features/settings/domain/usecases/profile_settings_usecase.dart';
import 'package:shapeup/features/settings/presentation/controllers/profile_settings_controller.dart';

final profileRepositoryInternalProvider = Provider<ProfileRepositoryImpl>((ref) {
  return ProfileRepositoryImpl(
    ref.watch(app_providers.appDatabaseProvider),
    ref.watch(app_providers.supabaseProvider),
    ref.watch(auth.authRepositoryProvider),
  );
});

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ref.watch(profileRepositoryInternalProvider);
});

final loadProfileSettingsUseCaseProvider =
    Provider<LoadProfileSettingsUseCase>((ref) {
  return LoadProfileSettingsUseCase(
    profileRepository: ref.watch(profileRepositoryProvider),
    measurementsRepository: ref.watch(measurements.measurementsRepositoryProvider),
  );
});

final profileSettingsUseCaseProvider = Provider<ProfileSettingsUseCase>((ref) {
  return ProfileSettingsUseCase(ref.watch(profileRepositoryProvider));
});

final profileSettingsLoadDataProvider =
    FutureProvider.autoDispose<ProfileSettingsDataEntity>(
  (ref) => ref.watch(loadProfileSettingsUseCaseProvider).load(),
);

final profileSettingsControllerProvider =
    Provider<ProfileSettingsController>((ref) {
  return ProfileSettingsController(ref.watch(profileSettingsUseCaseProvider));
});
