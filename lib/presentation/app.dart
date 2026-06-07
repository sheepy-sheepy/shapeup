import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shapeup/core/design/theme.dart';
import 'package:shapeup/presentation/navigation/app_router.dart';
import 'package:shapeup/presentation/providers/app_providers.dart' as app_providers;
import 'package:shapeup/presentation/widgets/app_background_widget.dart';

class AppWidget extends ConsumerStatefulWidget {
  const AppWidget({super.key});

  @override
  ConsumerState<AppWidget> createState() => _AppWidgetState();
}

class _AppWidgetState extends ConsumerState<AppWidget> with WidgetsBindingObserver {
  late final _router = createAppRouter();
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

      if (inactiveTime.inMinutes >= 10) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          app_providers.notifyAppDataChanged(ref);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'ShapeUp',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      routerConfig: _router,
      builder: (context, child) {
        return AppBackgroundWidget(
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
