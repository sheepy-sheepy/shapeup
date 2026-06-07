import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shapeup/presentation/app.dart';
import 'package:shapeup/core/config/app_config.dart';
import 'package:shapeup/core/shared/logger.dart';
import 'package:shapeup/presentation/providers/app_providers.dart';
import 'package:shapeup/data/local/database.dart';
import 'package:shapeup/data/local/foods_importer.dart'; 
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
      ],
      child: const AppWidget(),
    ),
  );

  _importFoodsInBackground(db, logger);
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

void _importFoodsInBackground(AppDatabase db, AppLogger logger) {
  unawaited(_importFoods(db, logger));
}

Future<void> _importFoods(AppDatabase db, AppLogger logger) async {
  try {
    await FoodsImporter(db).importIfNeeded();
  } catch (error, stack) {
    logger.error('FoodsImporterError', error, stack);
  }
}
