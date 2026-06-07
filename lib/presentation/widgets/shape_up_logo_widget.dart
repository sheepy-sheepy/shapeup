import 'package:flutter/material.dart';

import 'package:shapeup/presentation/widgets/logo_box_widget.dart';
import 'package:shapeup/presentation/widgets/logo_image_widget.dart';

class ShapeUpLogoWidget extends StatelessWidget {
  const ShapeUpLogoWidget({
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
    final logo = LogoBoxWidget(
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
          child: LogoImageWidget(padding: padding),
        );
      },
      child: logo,
    );
  }
}
