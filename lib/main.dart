import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'presentation/app.dart';
import 'core/app_config.dart';
import 'core/app_logger.dart';
import 'data/local/app_database.dart';
import 'data/services/startup_import_service.dart';
import 'domain/repositories/auth_repository.dart' as auth_domain;
import 'domain/repositories/diary_repository.dart' as diary_domain;
import 'domain/repositories/measurements_repository.dart' as measurements_domain;
import 'domain/repositories/photos_repository.dart' as photos_domain;
import 'domain/repositories/products_repository.dart' as products_domain;
import 'domain/repositories/profile_repository.dart' as profile_domain;
import 'domain/repositories/recipes_repository.dart' as recipes_domain;
import 'data/repositories/auth_repository.dart' as auth_data;
import 'data/repositories/diary_repository.dart' as diary_data;
import 'data/repositories/measurements_repository.dart' as measurements_data;
import 'data/repositories/photos_repository.dart' as photos_data;
import 'data/repositories/products_repository.dart' as products_data;
import 'data/repositories/profile_repository.dart' as profile_data;
import 'data/repositories/recipes_repository.dart' as recipes_data;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const logger = AppLogger();
  _setupErrorHandling(logger);

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  final db = AppDatabase();

  runApp(
    ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),

        auth_domain.authRepositoryProvider.overrideWith(
          (ref) => ref.watch(auth_data.authRepositoryImplProvider),
        ),
        diary_domain.diaryRepositoryProvider.overrideWith(
          (ref) => ref.watch(diary_data.diaryRepositoryProvider),
        ),
        measurements_domain.measurementsRepositoryProvider.overrideWith(
          (ref) => ref.watch(measurements_data.measurementsRepositoryProvider),
        ),
        photos_domain.photosRepositoryProvider.overrideWith(
          (ref) => ref.watch(photos_data.photosRepositoryProvider),
        ),
        products_domain.productsRepositoryProvider.overrideWith(
          (ref) => ref.watch(products_data.productsRepositoryProvider),
        ),
        profile_domain.profileRepositoryProvider.overrideWith(
          (ref) => ref.watch(profile_data.profileRepositoryProvider),
        ),
        recipes_domain.recipesRepositoryProvider.overrideWith(
          (ref) => ref.watch(recipes_data.recipesRepositoryProvider),
        ),
      ],
      child: const App(),
    ),
  );

  StartupImportService(db: db, logger: logger).importFoodsInBackground();
}

void _setupErrorHandling(AppLogger logger) {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    logger.error('FlutterError', details.exception, details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    logger.error('PlatformDispatcherError', error, stack);
    return true;
  };
}