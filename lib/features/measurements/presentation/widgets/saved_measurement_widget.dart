import 'package:flutter/material.dart';

import 'package:shapeup/core/design/theme.dart';
import 'package:shapeup/features/measurements/presentation/widgets/body_fat_result_widget.dart';
import 'package:shapeup/features/measurements/presentation/widgets/metric_tile_widget.dart';
import 'package:shapeup/features/measurements/domain/entities/body_measurement_entity.dart';

class SavedMeasurementWidget extends StatelessWidget {
  const SavedMeasurementWidget({super.key, 
    required this.measurement,
    required this.freshBodyFat,
  });

  final BodyMeasurementEntity measurement;
  final double? freshBodyFat;

  @override
  Widget build(BuildContext context) {
    final bodyFat = freshBodyFat ?? measurement.bodyFatPercent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Параметры за сегодня сохранены',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  'Следующий ввод будет доступен завтра.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
                BodyFatResultWidget(value: bodyFat),
                const SizedBox(height: AppSpacing.lg),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final twoColumns = constraints.maxWidth >= 360;
                    final cards = [
                      MetricTileWidget(
                        label: 'Вес',
                        value: measurement.weightKg.toStringAsFixed(1),
                        unit: 'кг',
                        icon: Icons.accessibility_new_outlined,
                      ),
                      MetricTileWidget(
                        label: 'Шея',
                        value: measurement.neckCm.toStringAsFixed(1),
                        unit: 'см',
                        icon: Icons.straighten_outlined,
                      ),
                      MetricTileWidget(
                        label: 'Талия',
                        value: measurement.waistCm.toStringAsFixed(1),
                        unit: 'см',
                        icon: Icons.straighten_outlined,
                      ),
                      MetricTileWidget(
                        label: 'Бедра',
                        value: measurement.hipsCm.toStringAsFixed(1),
                        unit: 'см',
                        icon: Icons.straighten,
                      ),
                    ];

                    if (!twoColumns) {
                      return Column(
                        children: [
                          for (var i = 0; i < cards.length; i++) ...[
                            cards[i],
                            if (i != cards.length - 1)
                              const SizedBox(height: AppSpacing.sm),
                          ],
                        ],
                      );
                    }

                    return GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppSpacing.sm,
                      crossAxisSpacing: AppSpacing.sm,
                      childAspectRatio: 2.7,
                      children: cards,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
