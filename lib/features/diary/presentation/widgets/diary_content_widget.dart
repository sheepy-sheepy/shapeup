import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shapeup/core/shared/errors.dart';
import 'package:shapeup/core/shared/dates.dart';
import 'package:shapeup/presentation/providers/app_providers.dart' as app_providers;
import 'package:shapeup/features/diary/presentation/controllers/diary_controller.dart';
import 'package:shapeup/features/diary/presentation/widgets/diary_summary_widget.dart';
import 'package:shapeup/features/diary/presentation/widgets/meal_card_widget.dart';
import 'package:shapeup/features/diary/providers/diary_provider.dart';

class DiaryContentWidget extends ConsumerStatefulWidget {
  const DiaryContentWidget({
    super.key,
    required this.selectedDate,
  });

  final ValueNotifier<DateTime> selectedDate;

  @override
  ConsumerState<DiaryContentWidget> createState() => _DiaryContentState();
}

class _DiaryContentState extends ConsumerState<DiaryContentWidget> {
  final waterAmountController = TextEditingController(text: '250');

  final ValueNotifier<int> totalsRefreshTick = ValueNotifier<int>(0);

  String? _dayKey;
  List<MealEntity> _meals = const [];
  MacroNormsEntity? _norms;

  bool _initialLoading = true;
  String? _errorText;
  int _loadSerial = 0;
  int _lastRefreshTick = 0;
  int? _pendingRefreshTick;

  @override
  void initState() {
    super.initState();

    _dayKey = dayKeyFromDate(widget.selectedDate.value);
    widget.selectedDate.addListener(_onDateChanged);

    _loadDay(
      dayKey: _dayKey!,
      date: widget.selectedDate.value,
      initial: true,
    );
  }

  @override
  void dispose() {
    widget.selectedDate.removeListener(_onDateChanged);
    waterAmountController.dispose();
    totalsRefreshTick.dispose();
    super.dispose();
  }

  void _onDateChanged() {
    final nextDayKey = dayKeyFromDate(widget.selectedDate.value);
    if (nextDayKey == _dayKey) return;

    _loadDay(
      dayKey: nextDayKey,
      date: widget.selectedDate.value,
      initial: false,
    );
  }

  void _scheduleDataRefreshIfNeeded(int refreshTick) {
    if (refreshTick == _lastRefreshTick || refreshTick == _pendingRefreshTick) {
      return;
    }

    _pendingRefreshTick = refreshTick;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _lastRefreshTick = refreshTick;
      _pendingRefreshTick = null;

      final dayKey = _dayKey;
      if (dayKey == null) return;

      _loadDay(
        dayKey: dayKey,
        date: widget.selectedDate.value,
        initial: false,
      );
    });
  }

  Future<void> _loadDay({
    required String dayKey,
    required DateTime date,
    required bool initial,
  }) async {
    final serial = ++_loadSerial;

    if (initial) {
      setState(() {
        _initialLoading = true;
        _errorText = null;
      });
    } else {
      setState(() {
        _errorText = null;
      });
    }

    try {
      final loaded = await _loadDayData(dayKey, date);

      if (!mounted || serial != _loadSerial) return;

      setState(() {
        _dayKey = loaded.dayKey;
        _meals = loaded.meals;
        _norms = loaded.norms;
        _initialLoading = false;
        _errorText = null;
      });

      totalsRefreshTick.value++;
    } catch (e) {
      if (!mounted || serial != _loadSerial) return;

      setState(() {
        _initialLoading = false;
        _errorText = russianErrorMessage(e);
      });
    }
  }

  Future<DiaryDayEntity> _loadDayData(String dayKey, DateTime date) {
    return ref.read(diaryControllerProvider).loadDay(
          dayKey: dayKey,
          date: date,
        );
  }

  @override
  Widget build(BuildContext context) {
    final refreshTick = ref.watch(app_providers.appRefreshTickProvider);
    _scheduleDataRefreshIfNeeded(refreshTick);

    if (_initialLoading && _dayKey == null) {
      return const SizedBox.shrink();
    }

    if (_errorText != null && _dayKey == null) {
      return Center(
        child: Text(errorWithTitle(diaryLoadErrorTitle, _errorText)),
      );
    }

    final dayKey = _dayKey;

    if (dayKey == null) {
      return const SizedBox.shrink();
    }

    return ListView(
      key: const PageStorageKey<String>('diary_content_scroll_position'),
      padding: const EdgeInsets.all(16),
      children: [
        DiarySummaryWidget(
          dayKey: dayKey,
          norms: _norms,
          waterAmountController: waterAmountController,
          totalsRefreshTick: totalsRefreshTick,
        ),
        ..._meals.map(
          (meal) => MealCardWidget(
            key: PageStorageKey<String>('meal_${meal.mealType}'),
            meal: meal,
            dayKey: dayKey,
            totalsRefreshTick: totalsRefreshTick,
          ),
        ),
      ],
    );
  }
}
