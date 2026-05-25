import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_ui.dart';
import '../../../core/date_utils.dart';
import '../../state/app_refresh.dart';
import 'widgets/diary_content.dart';

class DiaryScreen extends ConsumerStatefulWidget {
  const DiaryScreen({super.key});

  @override
  ConsumerState<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends ConsumerState<DiaryScreen> {
  late final ValueNotifier<DateTime> selectedDate;
  late String _autoTodayKey;
  String? _pendingTodayKey;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    selectedDate = ValueNotifier<DateTime>(now);
    _autoTodayKey = dayKeyFromDate(now);
  }

  @override
  void dispose() {
    selectedDate.dispose();
    super.dispose();
  }

  Future<void> _shift(int delta) async {
    selectedDate.value = selectedDate.value.add(Duration(days: delta));
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString().padLeft(4, '0');

    return '$day.$month.$year';
  }

  void _handleTodayChanged(String nextTodayKey) {
    if (!mounted) return;
    if (nextTodayKey == _autoTodayKey) {
      _pendingTodayKey = null;
      return;
    }

    final selectedDayKey = dayKeyFromDate(selectedDate.value);
    if (selectedDayKey == _autoTodayKey) {
      selectedDate.value = DateTime.now();
    }

    _autoTodayKey = nextTodayKey;
    _pendingTodayKey = null;
  }

  void _scheduleTodayChangeIfNeeded(String nextTodayKey) {
    if (nextTodayKey == _autoTodayKey || nextTodayKey == _pendingTodayKey) {
      return;
    }

    _pendingTodayKey = nextTodayKey;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleTodayChanged(nextTodayKey);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentTodayKey = ref.watch(currentDayKeyProvider);
    _scheduleTodayChangeIfNeeded(currentTodayKey);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: const [
          ScreenHelpAction(
            title: 'Дневник питания',
            message: 'На этом экране можно вести дневник питания по дням. '
                'Стрелками вверху переключайте дату. Добавляйте завтраки, обеды, ужины и перекусы, '
                'выбирая продукты или рецепты и указывая количество граммов. '
                'В карточке воды укажите объем и нажимайте + или -, чтобы изменить выпитое количество. '
                'Нормы КБЖУ и воды рассчитываются по профилю и последним доступным параметрам тела.',
          ),
        ],
        title: ValueListenableBuilder<DateTime>(
          valueListenable: selectedDate,
          builder: (context, date, _) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () => _shift(-1),
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Предыдущий день',
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(date),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _shift(1),
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Следующий день',
                ),
              ],
            );
          },
        ),
      ),
      body: DiaryContent(selectedDate: selectedDate),
    );
  }
}
