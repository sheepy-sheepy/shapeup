import 'package:flutter/material.dart';

import 'package:shapeup/features/diary/presentation/widgets/kbzhu_cell_widget.dart';

class MealTotalsLineWidget extends StatelessWidget {
  const MealTotalsLineWidget({super.key, 
    required this.calories,
    required this.proteins,
    required this.fats,
    required this.carbs,
    required this.style,
  });

  final double calories;
  final double proteins;
  final double fats;
  final double carbs;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 36,
          child: KbzhuCellWidget(
            text: 'К: ${calories.toStringAsFixed(2)}',
            style: style,
          ),
        ),
        Expanded(
          flex: 30,
          child: KbzhuCellWidget(
            text: 'Б:${proteins.toStringAsFixed(2)}',
            style: style,
          ),
        ),
        Expanded(
          flex: 30,
          child: KbzhuCellWidget(
            text: 'Ж:${fats.toStringAsFixed(2)}',
            style: style,
          ),
        ),
        Expanded(
          flex: 30,
          child: KbzhuCellWidget(
            text: 'У:${carbs.toStringAsFixed(2)}',
            style: style,
          ),
        ),
      ],
    );
  }
}
