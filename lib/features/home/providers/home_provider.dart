import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shapeup/features/home/data/repositories/home_repository_impl.dart';
import 'package:shapeup/features/home/domain/repositories/home_repository.dart';
import 'package:shapeup/features/home/domain/usecases/home_navigation_usecase.dart';

final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  return const HomeRepositoryImpl();
});

final homeNavigationUseCaseProvider = Provider<HomeNavigationUseCase>((ref) {
  return HomeNavigationUseCase(ref.watch(homeRepositoryProvider));
});
