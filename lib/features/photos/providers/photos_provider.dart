import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shapeup/presentation/providers/app_providers.dart' as app_providers;

import 'package:shapeup/features/auth/providers/auth_provider.dart' as auth;
import 'package:shapeup/features/photos/data/repositories/photos_repository_impl.dart';
import 'package:shapeup/features/photos/domain/repositories/photos_repository.dart';
import 'package:shapeup/features/photos/domain/usecases/photos_usecase.dart';
import 'package:shapeup/features/photos/presentation/controllers/photos_controller.dart';

final photosRepositoryProvider = Provider<PhotosRepository>((ref) {
  return PhotosRepositoryImpl(
    ref.watch(app_providers.appDatabaseProvider),
    ref.watch(auth.authRepositoryProvider),
    PhotoPickerAdapter(),
  );
});

final photosUseCaseProvider = Provider<PhotosUseCase>((ref) {
  return PhotosUseCase(ref.watch(photosRepositoryProvider));
});

final photosControllerProvider = Provider<PhotosController>((ref) {
  return PhotosController(ref.watch(photosUseCaseProvider));
});
