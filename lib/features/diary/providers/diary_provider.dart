import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shapeup/presentation/providers/app_providers.dart' as app_providers;

import 'package:shapeup/features/auth/providers/auth_provider.dart' as auth;
import 'package:shapeup/features/diary/data/repositories/diary_repository_impl.dart';
import 'package:shapeup/features/diary/domain/repositories/diary_repository.dart';
import 'package:shapeup/features/diary/domain/usecases/diary_usecase.dart';
import 'package:shapeup/features/diary/domain/usecases/load_diary_day_usecase.dart';
import 'package:shapeup/features/diary/presentation/controllers/diary_controller.dart';
import 'package:shapeup/features/measurements/providers/measurements_provider.dart' as measurements;
import 'package:shapeup/features/settings/providers/settings_provider.dart' as settings;

final diaryRepositoryProvider = Provider<DiaryRepository>((ref) {
  return DiaryRepositoryImpl(
    ref.watch(app_providers.appDatabaseProvider),
    ref.watch(auth.authRepositoryProvider),
  );
});

final diaryUseCaseProvider = Provider<DiaryUseCase>((ref) {
  return DiaryUseCase(ref.watch(diaryRepositoryProvider));
});

final loadDiaryDayUseCaseProvider = Provider<LoadDiaryDayUseCase>((ref) {
  return LoadDiaryDayUseCase(
    diaryRepository: ref.watch(diaryRepositoryProvider),
    measurementsRepository: ref.watch(
      measurements.measurementsRepositoryProvider,
    ),
    profileRepository: ref.watch(settings.profileRepositoryProvider),
  );
});

final diaryControllerProvider = Provider<DiaryController>((ref) {
  return DiaryController(
    diaryOperationsUseCase: ref.watch(diaryUseCaseProvider),
    diaryDayLoader: ref.watch(loadDiaryDayUseCaseProvider),
  );
});
