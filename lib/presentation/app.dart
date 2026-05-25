import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/design.dart';
import 'navigation/app_router.dart';
import 'state/app_refresh.dart';
import 'widgets/app_background.dart';

class App extends ConsumerStatefulWidget {
  const App({super.key});

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  DateTime? _pausedAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden) {
      _pausedAt = DateTime.now();
      return;
    }

    if (state == AppLifecycleState.resumed) {
      final pausedAt = _pausedAt;
      _pausedAt = null;

      if (pausedAt == null) return;

      final inactiveTime = DateTime.now().difference(pausedAt);

      // Если приложение долго было в фоне, мягко обновляем данные.
      if (inactiveTime.inMinutes >= 10) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          notifyAppDataChanged(ref);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'ShapeUp',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: router,
      builder: (context, child) {
        return AppBackground(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}