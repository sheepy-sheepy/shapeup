import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shapeup/core/design/ui.dart';
import 'package:shapeup/core/shared/dates.dart';
import 'package:shapeup/core/shared/today_scheduler.dart';
import 'package:shapeup/presentation/providers/app_providers.dart' as app_providers;
import 'package:shapeup/features/diary/presentation/widgets/diary_content_widget.dart';

class DiaryScreen extends ConsumerStatefulWidget {
  const DiaryScreen({super.key});

  @override
  ConsumerState<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends ConsumerState<DiaryScreen>
    with TodayChangeScheduler<DiaryScreen> {
  late final ValueNotifier<DateTime> selectedDate;
  late String _autoTodayKey;

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
    if (!mounted || nextTodayKey == _autoTodayKey) return;

    final selectedDayKey = dayKeyFromDate(selectedDate.value);
    if (selectedDayKey == _autoTodayKey) {
      selectedDate.value = DateTime.now();
    }

    _autoTodayKey = nextTodayKey;
  }

  @override
  Widget build(BuildContext context) {
    final currentTodayKey = ref.watch(app_providers.currentDayKeyProvider);
    scheduleTodayChangeIfNeeded(
      currentTodayKey: _autoTodayKey,
      nextTodayKey: currentTodayKey,
      onTodayChanged: _handleTodayChanged,
    );

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: const [
          ScreenHelpAction(
            title: 'Дневник питания',
            message: 'На этом экране ведется дневник питания по дням.\n\n'
                'Стрелками вверху переключайте дату. Добавляйте завтраки, обеды, ужины и перекусы, '
                'выбирая блюда и указывая количество граммов.\n\n'
                'В карточке воды укажите объем и нажимайте + или -, чтобы изменить выпитое количество.\n\n'
                'Нормы КБЖУ и воды рассчитываются по данным пользователя и последним доступным параметрам тела.',
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
      body: DiaryContentWidget(selectedDate: selectedDate),
    );
  }
}
