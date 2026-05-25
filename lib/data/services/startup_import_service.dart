import 'dart:async';

import '../../core/app_logger.dart';
import '../local/app_database.dart';
import '../local/foods_importer.dart';

class StartupImportService {
  const StartupImportService({
    required this.db,
    required this.logger,
  });

  final AppDatabase db;
  final AppLogger logger;

  void importFoodsInBackground() {
    unawaited(_importFoods());
  }

  Future<void> _importFoods() async {
    try {
      await FoodsImporter(db).importIfNeeded();
    } catch (error, stack) {
      logger.error('FoodsImporterError', error, stack);
    }
  }
}
