import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shapeup/core/shared/errors.dart';

import 'package:shapeup/core/shared/extensions.dart';
import 'package:shapeup/core/design/ui.dart';
import 'package:shapeup/core/design/theme.dart';
import 'package:shapeup/core/shared/numbers.dart';
import 'package:shapeup/features/diary/presentation/controllers/diary_controller.dart';
import 'package:shapeup/presentation/widgets/grams_input_widget.dart';
import 'package:shapeup/features/diary/presentation/meal_item_picker_screen.dart';
import 'package:shapeup/features/diary/presentation/widgets/meal_totals_line_widget.dart';
import 'package:shapeup/features/diary/domain/entities/picked_meal_source_entity.dart';
import 'package:shapeup/features/diary/providers/diary_provider.dart';

class MealCardWidget extends ConsumerStatefulWidget {
  const MealCardWidget({
    super.key,
    required this.meal,
    required this.dayKey,
    required this.totalsRefreshTick,
  });

  final MealEntity meal;
  final String dayKey;
  final ValueNotifier<int> totalsRefreshTick;

  @override
  ConsumerState<MealCardWidget> createState() => _MealCardState();
}

class _MealCardState extends ConsumerState<MealCardWidget> {
  bool initialLoading = true;
  String? errorText;
  List<MealItemEntity> items = [];

  @override
  void initState() {
    super.initState();
    _loadInitialItems();
  }

  @override
  void didUpdateWidget(covariant MealCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.meal.id != widget.meal.id ||
        oldWidget.dayKey != widget.dayKey) {
      _refreshItemsSilently();
    }
  }

  Future<void> _loadInitialItems() async {
    try {
      final loaded =
          await ref.read(diaryControllerProvider).mealItems(widget.meal.id);

      if (!mounted) return;

      setState(() {
        items = loaded;
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

  Future<void> _refreshItemsSilently() async {
    final loaded =
        await ref.read(diaryControllerProvider).mealItems(widget.meal.id);

    if (!mounted) return;

    setState(() {
      items = loaded;
      errorText = null;
      initialLoading = false;
    });
  }

  Future<void> _addToMeal() async {
    final picked = await Navigator.of(context).push<PickedMealSourceEntity>(
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
          return ref.read(diaryControllerProvider).canSubmitGrams(gramsController.text);
        }

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(picked.name),
              content: GramsInputWidget(
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

    final grams = ref.read(diaryControllerProvider).positiveGramsFromText(
      gramsController.text,
    );

    if (grams == null || grams <= 0) {
      if (mounted) {
        showAppSnackBar(context, gramsPositiveMessage);
      }
      return;
    }

    await ref.read(diaryControllerProvider).addMealItem(
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
          return ref.read(diaryControllerProvider).canSubmitGrams(controller.text);
        }

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Изменить граммы'),
              content: GramsInputWidget(
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

    final grams = ref.read(diaryControllerProvider).positiveGramsFromText(
      controller.text,
    );

    if (grams == null || grams <= 0) {
      if (mounted) {
        showAppSnackBar(context, gramsPositiveMessage);
      }
      return;
    }

    await ref.read(diaryControllerProvider).updateMealItemGrams(
          mealItemId: id,
          grams: grams,
        );

    if (!mounted) return;

    await _refreshItemsSilently();

    widget.totalsRefreshTick.value++;
  }

  Future<void> _deleteItem(String id) async {
    await ref.read(diaryControllerProvider).deleteMealItem(id);

    if (!mounted) return;

    setState(() {
      items = items.where((item) => item.id != id).toList();
    });

    widget.totalsRefreshTick.value++;
  }

  @override
  Widget build(BuildContext context) {
    final totals = ref.read(diaryControllerProvider).mealTotals(items);

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
                    child: MealTotalsLineWidget(
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
              child: Text(errorWithTitle(mealLoadErrorTitle, errorText)),
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

