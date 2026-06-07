import 'package:flutter/material.dart';

import 'package:shapeup/presentation/widgets/logo_image_widget.dart';

class LogoBoxWidget extends StatelessWidget {
  const LogoBoxWidget({super.key, 
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
        child: LogoImageWidget(padding: padding),
      ),
    );
  }
}
