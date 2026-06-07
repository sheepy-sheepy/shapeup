import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shapeup/core/shared/errors.dart';
import 'package:shapeup/core/design/theme.dart';
import 'package:shapeup/features/diary/presentation/controllers/diary_controller.dart';
import 'package:shapeup/features/diary/presentation/widgets/norm_row_widget.dart';
import 'package:shapeup/features/diary/providers/diary_provider.dart';

class NormsCardWidget extends ConsumerStatefulWidget {
  const NormsCardWidget({
    super.key,
    required this.dayKey,
    required this.norms,
    required this.totalsRefreshTick,
  });

  final String dayKey;
  final MacroNormsEntity? norms;
  final ValueNotifier<int> totalsRefreshTick;

  @override
  ConsumerState<NormsCardWidget> createState() => _NormsCardWidgetState();
}

class _NormsCardWidgetState extends ConsumerState<NormsCardWidget> {
  DiaryTotalsEntity? totals;
  String? errorText;
  bool initialLoading = true;

  @override
  void initState() {
    super.initState();
    widget.totalsRefreshTick.addListener(_refreshTotals);
    _loadInitialTotals();
  }

  @override
  void didUpdateWidget(covariant NormsCardWidget oldWidget) {
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
          await ref.read(diaryControllerProvider).totalsForDay(widget.dayKey);

      if (!mounted) return;

      setState(() {
        totals = loaded;
        errorText = null;
        initialLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorText = russianErrorMessage(e);
        initialLoading = false;
      });
    }
  }

  Future<void> _refreshTotals() async {
    try {
      final loaded =
          await ref.read(diaryControllerProvider).totalsForDay(widget.dayKey);

      if (!mounted) return;

      setState(() {
        totals = loaded;
        errorText = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorText = russianErrorMessage(e);
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
          child: Text(errorWithTitle(diaryTotalsLoadErrorTitle, errorText)),
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
    final frameStyle = ref.read(diaryControllerProvider).normFrameStyle(
          colors: Theme.of(context).colorScheme,
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
              NormRowWidget(
                label: 'Калории',
                consumed: currentTotals.calories,
                norm: norms.calories,
                unit: 'ккал',
              ),
              NormRowWidget(
                label: 'Белки',
                consumed: currentTotals.proteins,
                norm: norms.proteins,
                unit: 'г',
              ),
              NormRowWidget(
                label: 'Жиры',
                consumed: currentTotals.fats,
                norm: norms.fats,
                unit: 'г',
              ),
              NormRowWidget(
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
