import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shapeup/core/shared/errors.dart';
import 'package:shapeup/features/diary/presentation/controllers/diary_controller.dart';
import 'package:shapeup/features/diary/presentation/widgets/water_card_widget.dart';
import 'package:shapeup/features/diary/providers/diary_provider.dart';

class WaterLoaderWidget extends ConsumerStatefulWidget {
  const WaterLoaderWidget({
    super.key,
    required this.dayKey,
    required this.waterAmountController,
    required this.waterNorm,
  });

  final String dayKey;
  final TextEditingController waterAmountController;
  final double? waterNorm;

  @override
  ConsumerState<WaterLoaderWidget> createState() =>
      _WaterLoaderWidgetState();
}

class _WaterLoaderWidgetState extends ConsumerState<WaterLoaderWidget> {
  DiaryTotalsEntity? totals;
  String? errorText;
  bool initialLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWater();
  }

  @override
  void didUpdateWidget(covariant WaterLoaderWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.dayKey != widget.dayKey) {
      _loadWater();
    }
  }

  Future<void> _loadWater() async {
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

  @override
  Widget build(BuildContext context) {
    if (initialLoading && totals == null) {
      return const SizedBox.shrink();
    }

    if (errorText != null && totals == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(errorWithTitle(waterLoadErrorTitle, errorText)),
        ),
      );
    }

    final currentTotals = totals;

    if (currentTotals == null) {
      return const SizedBox.shrink();
    }

    return WaterCardWidget(
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
