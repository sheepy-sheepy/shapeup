import 'package:flutter/material.dart';

class AppBackgroundWidget extends StatelessWidget {
  const AppBackgroundWidget({
    super.key,
    required this.child,
  });

  static const imageAssetPath = 'assets/images/background.png';

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final overlayColor = brightness == Brightness.dark
        ? Colors.black.withValues(alpha: 0.58)
        : Colors.white.withValues(alpha: 0.50);

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          imageAssetPath,
          fit: BoxFit.cover,
          alignment: Alignment.center,
          gaplessPlayback: true,
          errorBuilder: (_, __, ___) => const DecoratedBox(
            decoration: BoxDecoration(color: Color(0xFFF6FAF1)),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(color: overlayColor),
        ),
        child,
      ],
    );
  }
}
