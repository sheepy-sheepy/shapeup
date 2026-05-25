import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../domain/services/nutrition_calculator.dart';
import '../../../../core/design.dart';
import '../../../../domain/repositories/diary_repository.dart';
import '../../../widgets/app_animations.dart';
import 'water_card.dart';

class DiarySummarySection extends StatelessWidget {
  const DiarySummarySection({
    super.key,
    required this.dayKey,
    required this.norms,
    required this.waterAmountController,
    required this.totalsRefreshTick,
  });

  final String dayKey;
  final MacroNorms? norms;
  final TextEditingController waterAmountController;
  final ValueNotifier<int> totalsRefreshTick;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _NormsCard(
          key: ValueKey('norms_$dayKey'),
          dayKey: dayKey,
          norms: norms,
          totalsRefreshTick: totalsRefreshTick,
        ),
        _WaterInitialLoader(
          key: ValueKey('water_loader_$dayKey'),
          dayKey: dayKey,
          waterAmountController: waterAmountController,
          waterNorm: norms?.waterMl,
        ),
      ],
    );
  }
}

class _NormsCard extends ConsumerStatefulWidget {
  const _NormsCard({
    super.key,
    required this.dayKey,
    required this.norms,
    required this.totalsRefreshTick,
  });

  final String dayKey;
  final MacroNorms? norms;
  final ValueNotifier<int> totalsRefreshTick;

  @override
  ConsumerState<_NormsCard> createState() => _NormsCardState();
}

class _NormsCardState extends ConsumerState<_NormsCard> {
  DiaryTotals? totals;
  String? errorText;
  bool initialLoading = true;

  @override
  void initState() {
    super.initState();
    widget.totalsRefreshTick.addListener(_refreshTotals);
    _loadInitialTotals();
  }

  @override
  void didUpdateWidget(covariant _NormsCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.totalsRefreshTick != widget.totalsRefreshTick) {
      oldWidget.totalsRefreshTick.removeListener(_refreshTotals);
      widget.totalsRefreshTick.addListener(_refreshTotals);
    }

    if (oldWidget.dayKey != widget.dayKey) {
      _refreshTotals();
    }
  }

  @override
  void dispose() {
    widget.totalsRefreshTick.removeListener(_refreshTotals);
    super.dispose();
  }

  Future<void> _loadInitialTotals() async {
    try {
      final loaded =
          await ref.read(diaryRepositoryProvider).totalsForDay(widget.dayKey);

      if (!mounted) return;

      setState(() {
        totals = loaded;
        errorText = null;
        initialLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorText = e.toString();
        initialLoading = false;
      });
    }
  }

  Future<void> _refreshTotals() async {
    try {
      final loaded =
          await ref.read(diaryRepositoryProvider).totalsForDay(widget.dayKey);

      if (!mounted) return;

      setState(() {
        totals = loaded;
        errorText = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorText = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (initialLoading && totals == null) {
      return const SizedBox.shrink();
    }

    if (errorText != null && totals == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Ошибка итогов дня: $errorText'),
        ),
      );
    }

    final currentTotals = totals;

    if (currentTotals == null) {
      return const SizedBox.shrink();
    }

    if (widget.norms == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Норма КБЖУ недоступна: нет параметров тела на выбранную дату или ранее, либо профиль заполнен не полностью.',
              ),
              const SizedBox(height: 12),
              Text(
                'Съедено калорий: ${currentTotals.calories.toStringAsFixed(2)}',
              ),
              Text(
                'Съедено белков: ${currentTotals.proteins.toStringAsFixed(2)}',
              ),
              Text(
                'Съедено жиров: ${currentTotals.fats.toStringAsFixed(2)}',
              ),
              Text(
                'Съедено углеводов: ${currentTotals.carbs.toStringAsFixed(2)}',
              ),
            ],
          ),
        ),
      );
    }

    final norms = widget.norms!;
    final frameStyle = _normFrameStyle(
      context,
      totals: currentTotals,
      norms: norms,
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: frameStyle.color,
          width: frameStyle.width,
        ),
        boxShadow: [
          BoxShadow(
            color: frameStyle.color.withValues(alpha: 0.16),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.track_changes,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Норма на день',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              NormRow(
                label: 'Калории',
                consumed: currentTotals.calories,
                norm: norms.calories,
                unit: 'ккал',
              ),
              NormRow(
                label: 'Белки',
                consumed: currentTotals.proteins,
                norm: norms.proteins,
                unit: 'г',
              ),
              NormRow(
                label: 'Жиры',
                consumed: currentTotals.fats,
                norm: norms.fats,
                unit: 'г',
              ),
              NormRow(
                label: 'Углеводы',
                consumed: currentTotals.carbs,
                norm: norms.carbs,
                unit: 'г',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WaterInitialLoader extends ConsumerStatefulWidget {
  const _WaterInitialLoader({
    super.key,
    required this.dayKey,
    required this.waterAmountController,
    required this.waterNorm,
  });

  final String dayKey;
  final TextEditingController waterAmountController;
  final double? waterNorm;

  @override
  ConsumerState<_WaterInitialLoader> createState() =>
      _WaterInitialLoaderState();
}

class _WaterInitialLoaderState extends ConsumerState<_WaterInitialLoader> {
  DiaryTotals? totals;
  String? errorText;
  bool initialLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWater();
  }

  @override
  void didUpdateWidget(covariant _WaterInitialLoader oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.dayKey != widget.dayKey) {
      _loadWater();
    }
  }

  Future<void> _loadWater() async {
    try {
      final loaded =
          await ref.read(diaryRepositoryProvider).totalsForDay(widget.dayKey);

      if (!mounted) return;

      setState(() {
        totals = loaded;
        errorText = null;
        initialLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorText = e.toString();
        initialLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (initialLoading && totals == null) {
      return const SizedBox.shrink();
    }

    if (errorText != null && totals == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Ошибка загрузки воды: $errorText'),
        ),
      );
    }

    final currentTotals = totals;

    if (currentTotals == null) {
      return const SizedBox.shrink();
    }

    return WaterCard(
      key: ValueKey('water_${widget.dayKey}'),
      dayKey: widget.dayKey,
      waterAmountController: widget.waterAmountController,
      waterNorm: widget.waterNorm,
      waterProgress: widget.waterNorm == null || widget.waterNorm! <= 0
          ? 0
          : (currentTotals.waterMl / widget.waterNorm!).clamp(0.0, 1.0),
      waterConsumed: currentTotals.waterMl,
    );
  }
}

class _NormFrameStyle {
  const _NormFrameStyle({
    required this.color,
    required this.width,
  });

  final Color color;
  final double width;
}

double _clamp01(double value) => value.clamp(0.0, 1.0).toDouble();

double _max4(double a, double b, double c, double d) {
  return math.max(math.max(a, b), math.max(c, d));
}

_NormFrameStyle _normFrameStyle(
  BuildContext context, {
  required DiaryTotals totals,
  required MacroNorms norms,
}) {
  final colors = Theme.of(context).colorScheme;

  if (norms.calories <= 0) {
    return _NormFrameStyle(
      color: colors.outlineVariant.withValues(alpha: 0.45),
      width: 1.0,
    );
  }

  final calorieProgress = _clamp01(totals.calories / norms.calories);

  final caloriesOver = math.max(0.0, totals.calories - norms.calories);
  final proteinsOver = math.max(0.0, totals.proteins - norms.proteins);
  final fatsOver = math.max(0.0, totals.fats - norms.fats);
  final carbsOver = math.max(0.0, totals.carbs - norms.carbs);

  final caloriesOverUnits = caloriesOver < 100 ? 0.0 : caloriesOver / 100.0;
  final proteinsOverUnits = proteinsOver < 50 ? 0.0 : proteinsOver / 50.0;
  final fatsOverUnits = fatsOver < 50 ? 0.0 : fatsOver / 50.0;
  final carbsOverUnits = carbsOver < 50 ? 0.0 : carbsOver / 50.0;

  final overUnits = _max4(
    caloriesOverUnits,
    proteinsOverUnits,
    fatsOverUnits,
    carbsOverUnits,
  );

  if (overUnits > 0) {
    final redPower = _clamp01(overUnits / 5.0);

    return _NormFrameStyle(
      color: Color.lerp(
        const Color(0xFFFFE4E4),
        const Color(0xFFEFA0A0),
        redPower,
      )!,
      width: 1.4 + redPower * 1.8,
    );
  }

  return _NormFrameStyle(
    color: Color.lerp(
      colors.outlineVariant.withValues(alpha: 0.38),
      const Color(0xFFBFE8C8),
      calorieProgress,
    )!,
    width: 1.0 + calorieProgress * 1.2,
  );
}
class NormRow extends StatelessWidget {
  const NormRow({
    super.key,
    required this.label,
    required this.consumed,
    required this.norm,
    required this.unit,
    this.fractionDigits = 2,
  });

  final String label;
  final double consumed;
  final double norm;
  final String unit;
  final int fractionDigits;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final diff = norm - consumed;
    final exceeded = diff < 0;
    final absDiff = diff.abs();
    final progress = norm <= 0 ? 0.0 : (consumed / norm).clamp(0.0, 1.0);
    final valueStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w700,
        );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              Text(
                '${consumed.toStringAsFixed(fractionDigits)} / '
                '${norm.toStringAsFixed(fractionDigits)} $unit',
                style: valueStyle,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          AnimatedProgressBar(
            value: progress,
            backgroundColor: colorScheme.surfaceContainerHighest,
            color: exceeded ? colorScheme.error : colorScheme.primary,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            exceeded
                ? 'Превышено на ${absDiff.toStringAsFixed(fractionDigits)} $unit'
                : 'Осталось ${absDiff.toStringAsFixed(fractionDigits)} $unit',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: exceeded
                      ? colorScheme.error
                      : colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
