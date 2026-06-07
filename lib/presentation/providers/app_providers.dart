import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:shapeup/core/shared/preferences.dart';
import 'package:shapeup/data/local/database.dart';
import 'package:shapeup/data/remote/supabase.dart';
import 'package:shapeup/presentation/controllers/app_refresh_controller.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return supabaseClient;
});

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return const PreferencesService();
});

final currentDayKeyProvider =
    StateNotifierProvider<AppRefreshController, String>(
  (ref) {
    final notifier = AppRefreshController();
    ref.onDispose(notifier.dispose);
    return notifier;
  },
);

final appRefreshTickProvider = StateProvider<int>((ref) => 0);

void notifyAppDataChanged(WidgetRef ref) {
  ref.read(appRefreshTickProvider.notifier).state++;
}
