import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/app_ui.dart';
import '../../../../core/design.dart';
import '../../../../domain/repositories/diary_repository.dart';
import '../../../widgets/app_animations.dart';
import 'water_growth_animation.dart';

class WaterCard extends ConsumerStatefulWidget {
  const WaterCard({
    super.key,
    required this.dayKey,
    required this.waterAmountController,
    required this.waterNorm,
    required this.waterProgress,
    required this.waterConsumed,
  });

  final String dayKey;
  final TextEditingController waterAmountController;
  final double? waterNorm;
  final double waterProgress;
  final double waterConsumed;

  @override
  ConsumerState<WaterCard> createState() => _WaterCardState();
}

class _WaterCardState extends ConsumerState<WaterCard> {
  late double waterConsumed;
  int _waterWaveTrigger = 0;

  @override
  void initState() {
    super.initState();
    waterConsumed = widget.waterConsumed;
  }

  @override
  void didUpdateWidget(covariant WaterCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.dayKey != widget.dayKey) {
      waterConsumed = widget.waterConsumed;
    }
  }

  double? _waterInputMl() {
    final value = double.tryParse(
      widget.waterAmountController.text.trim().replaceAll(',', '.'),
    );
    if (value == null || value <= 0) return null;
    return value;
  }

  Future<void> _quickAddWater(double ml) async {
    widget.waterAmountController.text = ml.toStringAsFixed(0);
    await _changeWater(increase: true);
  }

  Future<void> _changeWater({required bool increase}) async {
    FocusManager.instance.primaryFocus?.unfocus();

    final delta = _waterInputMl();

    if (delta == null) {
      if (mounted) {
        showAppSnackBar(context, 'Введите положительный объем воды в мл');
      }
      return;
    }

    final next = increase ? waterConsumed + delta : waterConsumed - delta;
    final clamped = next < 0 ? 0.0 : next;

    await ref.read(diaryRepositoryProvider).updateWater(
          widget.dayKey,
          clamped,
        );

    if (!mounted) return;

    setState(() {
      waterConsumed = clamped;
      _waterWaveTrigger++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final waterNorm = widget.waterNorm;

    final waterProgress = waterNorm == null || waterNorm <= 0
        ? 0.0
        : (waterConsumed / waterNorm).clamp(0.0, 1.0);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.water_drop_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Вода',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (waterNorm != null) ...[
              WaterGrowthAnimation(
                progress: waterProgress,
                waveTrigger: _waterWaveTrigger,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Выпито ${waterConsumed.toStringAsFixed(1)} мл '
                'из ${waterNorm.toStringAsFixed(1)} мл',
              ),
              const SizedBox(height: AppSpacing.sm),
              AnimatedProgressBar(value: waterProgress),
              const SizedBox(height: AppSpacing.lg),
            ] else ...[
              Text('Выпито ${waterConsumed.toStringAsFixed(1)} мл'),
              const SizedBox(height: 8),
              const Text(
                'Норма воды недоступна: нет параметров тела на выбранную дату или ранее.',
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                IconButton.filledTonal(
                  onPressed: () => _changeWater(increase: false),
                  icon: const Icon(Icons.remove),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: TextField(
                    controller: widget.waterAmountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Объем воды, мл',
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton.filledTonal(
                  onPressed: () => _changeWater(increase: true),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Center(
  child: Wrap(
    alignment: WrapAlignment.center,
    spacing: AppSpacing.sm,
    runSpacing: AppSpacing.xs,
    children: [
      ActionChip(
        label: const Text('+200 мл'),
        onPressed: () => _quickAddWater(200),
      ),
      const SizedBox(width: AppSpacing.sm),
      ActionChip(
        label: const Text('+250 мл'),
        onPressed: () => _quickAddWater(250),
      ),
      const SizedBox(width: AppSpacing.sm),
      ActionChip(
        label: const Text('+500 мл'),
        onPressed: () => _quickAddWater(500),
      ),
    ],
  ),
),
          ],
        ),
      ),
    );
  }
}
