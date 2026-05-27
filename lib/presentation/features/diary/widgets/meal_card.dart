import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions.dart';
import '../../../../core/app_ui.dart';
import '../../../../core/design.dart';
import '../../../../core/number_utils.dart';
import '../../../../domain/repositories/diary_repository.dart';
import '../../../widgets/grams_input_content.dart';
import '../meal_item_picker_screen.dart';

class MealCard extends ConsumerStatefulWidget {
  const MealCard({
    super.key,
    required this.meal,
    required this.dayKey,
    required this.totalsRefreshTick,
  });

  final Meal meal;
  final String dayKey;
  final ValueNotifier<int> totalsRefreshTick;

  @override
  ConsumerState<MealCard> createState() => _MealCardState();
}

class _MealCardState extends ConsumerState<MealCard> {
  bool initialLoading = true;
  String? errorText;
  List<MealItem> items = [];

  @override
  void initState() {
    super.initState();
    _loadInitialItems();
  }

  @override
  void didUpdateWidget(covariant MealCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.meal.id != widget.meal.id ||
        oldWidget.dayKey != widget.dayKey) {
      _refreshItemsSilently();
    }
  }

  _MealTotals _mealTotals() {
    double calories = 0;
    double proteins = 0;
    double fats = 0;
    double carbs = 0;

    for (final item in items) {
      final ratio = item.grams / 100.0;

      calories += item.caloriesSnapshot * ratio;
      proteins += item.proteinsSnapshot * ratio;
      fats += item.fatsSnapshot * ratio;
      carbs += item.carbsSnapshot * ratio;
    }

    return _MealTotals(
      calories: calories,
      proteins: proteins,
      fats: fats,
      carbs: carbs,
    );
  }

  Future<void> _loadInitialItems() async {
    try {
      final loaded =
          await ref.read(diaryRepositoryProvider).mealItems(widget.meal.id);

      if (!mounted) return;

      setState(() {
        items = loaded;
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

  Future<void> _refreshItemsSilently() async {
    final loaded =
        await ref.read(diaryRepositoryProvider).mealItems(widget.meal.id);

    if (!mounted) return;

    setState(() {
      items = loaded;
      errorText = null;
      initialLoading = false;
    });
  }

  Future<void> _addToMeal() async {
    final picked = await Navigator.of(context).push<PickedMealSource>(
      MaterialPageRoute(builder: (_) => const MealItemPickerScreen()),
    );

    if (picked == null) return;

    await Future<void>.delayed(const Duration(milliseconds: 80));

    if (!mounted) return;

    final gramsController = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) {
        bool canAdd() {
          final grams = double.tryParse(
            gramsController.text.trim().replaceAll(',', '.'),
          );
          return grams != null && grams > 0;
        }

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(picked.name),
              content: GramsInputContent(
                controller: gramsController,
                setDialogState: setDialogState,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed:
                      canAdd() ? () => Navigator.pop(context, true) : null,
                  child: const Text('Добавить'),
                ),
              ],
            );
          },
        );
      },
    );

    if (ok != true) return;

    FocusManager.instance.primaryFocus?.unfocus();

    final parsedGrams =
        double.tryParse(gramsController.text.replaceAll(',', '.'));
    final grams = parsedGrams == null ? null : roundGrams(parsedGrams);

    if (grams == null || grams <= 0) {
      if (mounted) {
        showAppSnackBar(context, 'Граммы должны быть больше 0');
      }
      return;
    }

    await ref.read(diaryRepositoryProvider).addMealItem(
          mealId: widget.meal.id,
          sourceType: picked.sourceType,
          sourceId: picked.id,
          name: picked.name,
          grams: grams,
          calories: picked.calories,
          proteins: picked.proteins,
          fats: picked.fats,
          carbs: picked.carbs,
        );

    if (!mounted) return;

    await _refreshItemsSilently();

    widget.totalsRefreshTick.value++;
  }

  Future<void> _editItem(String id, double currentGrams) async {
    final controller =
        TextEditingController(text: currentGrams.toStringAsFixed(1));

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) {
        bool canSave() {
          final grams = double.tryParse(
            controller.text.trim().replaceAll(',', '.'),
          );
          return grams != null && grams > 0;
        }

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Изменить граммы'),
              content: GramsInputContent(
                controller: controller,
                setDialogState: setDialogState,
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed:
                      canSave() ? () => Navigator.pop(context, true) : null,
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );

    if (ok != true) return;

    FocusManager.instance.primaryFocus?.unfocus();

    final parsedGrams = double.tryParse(controller.text.replaceAll(',', '.'));
    final grams = parsedGrams == null ? null : roundGrams(parsedGrams);

    if (grams == null || grams <= 0) {
      if (mounted) {
        showAppSnackBar(context, 'Граммы должны быть больше 0');
      }
      return;
    }

    await ref.read(diaryRepositoryProvider).updateMealItemGrams(
          mealItemId: id,
          grams: grams,
        );

    if (!mounted) return;

    await _refreshItemsSilently();

    widget.totalsRefreshTick.value++;
  }

  Future<void> _deleteItem(String id) async {
    await ref.read(diaryRepositoryProvider).deleteMealItem(id);

    if (!mounted) return;

    setState(() {
      items = items.where((item) => item.id != id).toList();
    });

    widget.totalsRefreshTick.value++;
  }

  @override
  Widget build(BuildContext context) {
    final totals = _mealTotals();

    return Card(
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        key: PageStorageKey<String>(
          'meal_expansion_${widget.dayKey}_${widget.meal.mealType}',
        ),
        maintainState: true,
        title: LayoutBuilder(
          builder: (context, constraints) {
            final titleWidth = constraints.maxWidth < 320 ? 82.0 : 96.0;

            return Row(
              children: [
                SizedBox(
                  width: titleWidth,
                  child: Row(
                    children: [
                      Icon(
                        _mealIcon(widget.meal.mealType),
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          _mealLabel(widget.meal.mealType),
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
                if (items.isNotEmpty) ...[
                  const SizedBox(width: 2),
                  Expanded(
                    child: _MealTotalsFixedLine(
                      calories: roundKbju(totals.calories),
                      proteins: roundKbju(totals.proteins),
                      fats: roundKbju(totals.fats),
                      carbs: roundKbju(totals.carbs),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
        children: [
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: FilledButton.tonalIcon(
                onPressed: _addToMeal,
                icon: const Icon(Icons.add),
                label: const Text('Добавить блюдо'),
              ),
            ),
          ),
          if (initialLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Загружаем прием пищи...'),
            )
          else if (errorText != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Ошибка загрузки приема пищи: $errorText'),
            )
          else if (items.isEmpty)
            const ListTile(
              title: Text('Пока пусто'),
              subtitle: Text('Добавьте продукт или рецепт в этот прием пищи'),
            )
          else
            Column(
              children: items
                  .map(
                    (i) => ListTile(
                      key: ValueKey(i.id),
                      onTap: () => _editItem(i.id, i.grams),
                      title: Text(
                        i.nameSnapshot,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Text(
                        kbzhuForGramsText(
                          grams: i.grams,
                          caloriesPer100: i.caloriesSnapshot,
                          proteinsPer100: i.proteinsSnapshot,
                          fatsPer100: i.fatsSnapshot,
                          carbsPer100: i.carbsSnapshot,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteItem(i.id),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  IconData _mealIcon(String value) {
    switch (value) {
      case 'breakfast':
        return Icons.free_breakfast_outlined;
      case 'lunch':
        return Icons.lunch_dining_outlined;
      case 'dinner':
        return Icons.dinner_dining_outlined;
      case 'snack':
        return Icons.cookie_outlined;
      default:
        return Icons.restaurant_outlined;
    }
  }

  String _mealLabel(String value) {
    switch (value) {
      case 'breakfast':
        return 'Завтрак';
      case 'lunch':
        return 'Обед';
      case 'dinner':
        return 'Ужин';
      case 'snack':
        return 'Перекус';
      default:
        return value;
    }
  }
}

class _MealTotalsFixedLine extends StatelessWidget {
  const _MealTotalsFixedLine({
    required this.calories,
    required this.proteins,
    required this.fats,
    required this.carbs,
    required this.style,
  });

  final double calories;
  final double proteins;
  final double fats;
  final double carbs;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 36,
          child: _FixedKbzhuCell(
            text: 'К: ${calories.toStringAsFixed(2)}',
            style: style,
          ),
        ),
        Expanded(
          flex: 30,
          child: _FixedKbzhuCell(
            text: 'Б:${proteins.toStringAsFixed(2)}',
            style: style,
          ),
        ),
        Expanded(
          flex: 30,
          child: _FixedKbzhuCell(
            text: 'Ж:${fats.toStringAsFixed(2)}',
            style: style,
          ),
        ),
        Expanded(
          flex: 30,
          child: _FixedKbzhuCell(
            text: 'У:${carbs.toStringAsFixed(2)}',
            style: style,
          ),
        ),
      ],
    );
  }
}

class _FixedKbzhuCell extends StatelessWidget {
  const _FixedKbzhuCell({
    required this.text,
    required this.style,
  });

  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            text,
            maxLines: 1,
            softWrap: false,
            style: style,
          ),
        ),
      ),
    );
  }
}

class _MealTotals {
  const _MealTotals({
    required this.calories,
    required this.proteins,
    required this.fats,
    required this.carbs,
  });

  final double calories;
  final double proteins;
  final double fats;
  final double carbs;
}
