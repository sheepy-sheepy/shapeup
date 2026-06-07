import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shapeup/features/splash/domain/usecases/startup_usecase.dart';
import 'package:shapeup/presentation/widgets/shape_up_logo_widget.dart';
import 'package:shapeup/features/auth/providers/auth_provider.dart';
import 'package:shapeup/features/splash/providers/splash_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _floatController;
  late final AnimationController _appearController;
  late final Animation<double> _logoOffset;
  late final Animation<double> _logoScale;
  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleOffset;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 980),
    )..repeat(reverse: true);

    _appearController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 820),
    )..forward();

    _logoOffset = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _logoScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _appearController, curve: Curves.easeOutBack),
    );

    _titleOpacity = CurvedAnimation(
      parent: _appearController,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
    );

    _titleOffset = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _appearController,
        curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) => _openInitialScreen());
  }

  @override
  void dispose() {
    _floatController.dispose();
    _appearController.dispose();
    super.dispose();
  }

  Future<void> _openInitialScreen() async {
    final start = DateTime.now();
    final nextRoute = await _resolveInitialRoute();

    final elapsed = DateTime.now().difference(start);
    const minSplashDuration = Duration(milliseconds: 1850);
    if (elapsed < minSplashDuration) {
      await Future<void>.delayed(minSplashDuration - elapsed);
    }

    if (!mounted) return;

    if (nextRoute.startOtpCooldown) {
      await ref.read(authFlowControllerProvider).startOtpCooldown();
      if (!mounted) return;
    }

    context.go(nextRoute.path, extra: nextRoute.extra);
  }

  Future<StartupRouteTargetEntity> _resolveInitialRoute() async {
    return ref.read(startupUseCaseProvider).resolveInitialRoute();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.primaryContainer.withValues(alpha: 0.78),
              colors.surface,
              colors.secondaryContainer.withValues(alpha: 0.62),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation:
                      Listenable.merge([_floatController, _appearController]),
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _logoOffset.value),
                      child: Transform.scale(
                        scale: _logoScale.value,
                        child: child,
                      ),
                    );
                  },
                  child: const ShapeUpLogoWidget(
                    size: 156,
                    circle: false,
                    padding: EdgeInsets.all(10),
                    hero: true,
                  ),
                ),
                const SizedBox(height: 26),
                FadeTransition(
                  opacity: _titleOpacity,
                  child: SlideTransition(
                    position: _titleOffset,
                    child: Column(
                      children: [
                        Text(
                          'ShapeUp',
                          style: theme.textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colors.primary,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Контролируйте пищевой баланс и физическую форму',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
