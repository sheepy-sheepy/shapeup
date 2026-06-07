import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shapeup/features/auth/providers/auth_provider.dart' as auth;
import 'package:shapeup/features/splash/data/repositories/splash_repository_impl.dart';
import 'package:shapeup/features/splash/domain/repositories/splash_repository.dart';
import 'package:shapeup/features/splash/domain/usecases/startup_usecase.dart';

final splashRepositoryProvider = Provider<SplashRepository>((ref) {
  return SplashRepositoryImpl(ref.watch(auth.authRepositoryProvider));
});

final startupUseCaseProvider = Provider<StartupUseCase>((ref) {
  return StartupUseCase(ref.watch(splashRepositoryProvider));
});
