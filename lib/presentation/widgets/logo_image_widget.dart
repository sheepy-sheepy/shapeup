import 'package:flutter/material.dart';

import 'package:shapeup/presentation/widgets/shape_up_logo_widget.dart';

class LogoImageWidget extends StatelessWidget {
  const LogoImageWidget({super.key, required this.padding});

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Image.asset(
        ShapeUpLogoWidget.assetPath,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
