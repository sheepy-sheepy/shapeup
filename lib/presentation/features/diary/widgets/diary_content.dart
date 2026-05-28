import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/app_errors.dart';
import '../../../../core/date_utils.dart';
import '../../../../domain/services/nutrition_calculator.dart';
import '../../../../domain/entities/local_entities.dart';
import '../../../../domain/usecases/diary_day_loader.dart';
import '../../../state/app_refresh.dart';
import 'diary_summary_section.dart';
import 'meal_card.dart';

class DiaryContent extends ConsumerStatefulWidget {
  const DiaryContent({
    super.key,
    required this.selectedDate,
  });

  final ValueNotifier<DateTime> selectedDate;

  @override
  ConsumerState<DiaryContent> createState() => _DiaryContentState();
}

class _DiaryContentState extends ConsumerState<DiaryContent> {
  final waterAmountController = TextEditingController(text: '250');

  final ValueNotifier<int> totalsRefreshTick = ValueNotifier<int>(0);

  String? _dayKey;
  List<Meal> _meals = const [];
  MacroNorms? _norms;

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

  Future<DiaryDayData> _loadDayData(String dayKey, DateTime date) {
    return ref.read(diaryDayLoaderProvider).loadDay(
          dayKey: dayKey,
          date: date,
        );
  }

  @override
  Widget build(BuildContext context) {
    final refreshTick = ref.watch(appRefreshTickProvider);
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
        DiarySummarySection(
          dayKey: dayKey,
          norms: _norms,
          waterAmountController: waterAmountController,
          totalsRefreshTick: totalsRefreshTick,
        ),
        ..._meals.map(
          (meal) => MealCard(
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
