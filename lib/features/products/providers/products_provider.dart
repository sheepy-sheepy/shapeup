import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shapeup/presentation/providers/app_providers.dart' as app_providers;

import 'package:shapeup/features/auth/providers/auth_provider.dart' as auth;
import 'package:shapeup/features/products/data/repositories/products_repository_impl.dart';
import 'package:shapeup/features/products/data/repositories/recipes_repository_impl.dart';
import 'package:shapeup/features/products/domain/repositories/products_repository.dart';
import 'package:shapeup/features/products/domain/repositories/recipes_repository.dart';
import 'package:shapeup/features/products/domain/usecases/products_usecase.dart';
import 'package:shapeup/features/products/domain/usecases/recipe_editor_usecase.dart';
import 'package:shapeup/features/products/presentation/controllers/base_foods_paging_controller.dart';
import 'package:shapeup/features/products/presentation/controllers/products_controller.dart';
import 'package:shapeup/features/products/presentation/controllers/recipe_editor_controller.dart';

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepositoryImpl(
    ref.watch(app_providers.appDatabaseProvider),
    ref.watch(auth.authRepositoryProvider),
  );
});

final recipesRepositoryProvider = Provider<RecipesRepository>((ref) {
  return RecipesRepositoryImpl(
    ref.watch(app_providers.appDatabaseProvider),
    ref.watch(auth.authRepositoryProvider),
  );
});

final productsUseCaseProvider = Provider<ProductsUseCase>((ref) {
  return ProductsUseCase(
    productsRepository: ref.watch(productsRepositoryProvider),
    recipesRepository: ref.watch(recipesRepositoryProvider),
  );
});

final recipeEditorUseCaseProvider = Provider<RecipeEditorUseCase>((ref) {
  return RecipeEditorUseCase(ref.watch(recipesRepositoryProvider));
});

final baseFoodsPagingControllerFactoryProvider =
    Provider<BaseFoodsPagingControllerFactory>((ref) {
  return () => BaseFoodsPagingController(
        productsUseCase: ref.read(productsUseCaseProvider),
      );
});

final productsControllerProvider = Provider<ProductsController>((ref) {
  return ProductsController(ref.watch(productsUseCaseProvider));
});

final recipeEditorControllerProvider = Provider<RecipeEditorController>((ref) {
  return RecipeEditorController(ref.watch(recipeEditorUseCaseProvider));
});
