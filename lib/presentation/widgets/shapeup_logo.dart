import 'package:flutter/material.dart';

class ShapeUpLogo extends StatelessWidget {
  const ShapeUpLogo({
    super.key,
    this.size = 72,
    this.circle = true,
    this.padding = const EdgeInsets.all(4),
    this.hero = false,
  });

  static const String assetPath = 'assets/images/app_logo.png';
  static const String heroTag = 'shapeup_app_logo';

  final double size;
  final bool circle;
  final EdgeInsetsGeometry padding;
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final logo = _LogoBox(
      size: size,
      circle: circle,
      padding: padding,
    );

    if (!hero) return logo;

    return Hero(
      tag: heroTag,
      flightShuttleBuilder: (
        flightContext,
        animation,
        flightDirection,
        fromHeroContext,
        toHeroContext,
      ) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOutCubic,
        );

        final beginRadius = flightDirection == HeroFlightDirection.push
            ? BorderRadius.circular(28)
            : BorderRadius.circular(999);
        final endRadius = flightDirection == HeroFlightDirection.push
            ? BorderRadius.circular(999)
            : BorderRadius.circular(28);

        return AnimatedBuilder(
          animation: curved,
          builder: (context, child) {
            final radius = BorderRadius.lerp(
              beginRadius,
              endRadius,
              curved.value,
            )!;

            return Material(
              color: Colors.transparent,
              child: ClipRRect(
                borderRadius: radius,
                child: child,
              ),
            );
          },
          child: _LogoImage(padding: padding),
        );
      },
      child: logo,
    );
  }
}

class _LogoBox extends StatelessWidget {
  const _LogoBox({
    required this.size,
    required this.circle,
    required this.padding,
  });

  final double size;
  final bool circle;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: circle ? null : BorderRadius.circular(28),
          color: colorScheme.surface.withValues(alpha: 0.96),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.12),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: _LogoImage(padding: padding),
      ),
    );
  }
}

class _LogoImage extends StatelessWidget {
  const _LogoImage({required this.padding});

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Image.asset(
        ShapeUpLogo.assetPath,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
