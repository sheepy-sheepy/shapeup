import 'package:flutter/material.dart';

import 'package:shapeup/features/products/presentation/widgets/section_title_widget.dart';

class FoodSectionWidget extends StatelessWidget {
  const FoodSectionWidget({super.key, 
    required this.title,
    required this.backgroundColor,
    required this.borderColor,
    required this.children,
  });

  final String title;
  final Color backgroundColor;
  final Color borderColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.fromLTRB(8, 8, 8, 12),
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitleWidget(title: title),
          ...children,
        ],
      ),
    );
  }
}
