import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shapeup/features/auth/presentation/controllers/otp_cooldown_controller.dart';
import 'package:shapeup/presentation/providers/app_providers.dart' as app_providers;
import 'package:shapeup/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:shapeup/features/auth/domain/repositories/auth_repository.dart';
import 'package:shapeup/features/auth/domain/usecases/auth_usecase.dart';
import 'package:shapeup/features/auth/presentation/controllers/auth_flow_controller.dart';

final otpCooldownProvider =
    StateNotifierProvider<OtpCooldownNotifier, OtpCooldownState>(
  (ref) => OtpCooldownNotifier(
    ref.watch(app_providers.preferencesServiceProvider),
  ),
);

final authRepositoryInternalProvider = Provider<AuthRepositoryImpl>((ref) {
  final db = ref.watch(app_providers.appDatabaseProvider);

  return AuthRepositoryImpl(
    ref.watch(app_providers.supabaseProvider),
    db,
    ref.watch(app_providers.preferencesServiceProvider),
    AuthLocalCredentialsStore(db),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return ref.watch(authRepositoryInternalProvider);
});

final authUseCaseProvider = Provider<AuthUseCase>((ref) {
  return AuthUseCase(ref.watch(authRepositoryProvider));
});

final authFlowControllerProvider = Provider<AuthFlowController>((ref) {
  return AuthFlowController(
    authUseCase: ref.watch(authUseCaseProvider),
    otpCooldownNotifier: ref.watch(otpCooldownProvider.notifier),
  );
});

final otpCooldownStateProvider = Provider<OtpCooldownState>((ref) {
  return ref.watch(otpCooldownProvider);
});
