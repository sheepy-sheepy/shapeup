import 'package:flutter/material.dart';

import 'package:shapeup/features/diary/presentation/controllers/diary_controller.dart';
import 'package:shapeup/features/diary/presentation/widgets/norms_card_widget.dart';
import 'package:shapeup/features/diary/presentation/widgets/water_loader_widget.dart';
import 'package:shapeup/domain/entities/macro_norms_entity.dart';

class DiarySummaryWidget extends StatelessWidget {
  const DiarySummaryWidget({
    super.key,
    required this.dayKey,
    required this.norms,
    required this.waterAmountController,
    required this.totalsRefreshTick,
  });

  final String dayKey;
  final MacroNormsEntity? norms;
  final TextEditingController waterAmountController;
  final ValueNotifier<int> totalsRefreshTick;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        NormsCardWidget(
          key: ValueKey('norms_$dayKey'),
          dayKey: dayKey,
          norms: norms,
          totalsRefreshTick: totalsRefreshTick,
        ),
        WaterLoaderWidget(
          key: ValueKey('water_loader_$dayKey'),
          dayKey: dayKey,
          waterAmountController: waterAmountController,
          waterNorm: norms?.waterMl,
        ),
      ],
    );
  }
}
