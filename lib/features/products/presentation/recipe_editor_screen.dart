import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shapeup/core/shared/errors.dart';
import 'package:shapeup/core/shared/extensions.dart';
import 'package:shapeup/core/design/ui.dart';
import 'package:shapeup/core/shared/validators.dart';
import 'package:shapeup/features/products/domain/entities/recipe_ingredient_input_entity.dart';
import 'package:shapeup/presentation/widgets/grams_input_widget.dart';
import 'package:shapeup/features/products/presentation/food_picker_screen.dart';
import 'package:shapeup/features/products/domain/entities/picked_food_entity.dart';
import 'package:shapeup/features/products/providers/products_provider.dart';

class RecipeEditorScreen extends ConsumerStatefulWidget {
  const RecipeEditorScreen({super.key, this.recipeId, this.initialName});

  final String? recipeId;
  final String? initialName;

  bool get isEdit => recipeId != null;

  @override
  ConsumerState<RecipeEditorScreen> createState() => _RecipeEditorScreenState();
}

class _RecipeEditorScreenState extends ConsumerState<RecipeEditorScreen> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController name;
  late final TextEditingController tareWeight;
  late final TextEditingController cookedWithTareWeight;

  final List<RecipeIngredientInputEntity> items = [];

  bool loading = false;

  @override
  void initState() {
    super.initState();

    name = TextEditingController(text: widget.initialName ?? '');
    tareWeight = TextEditingController();
    cookedWithTareWeight = TextEditingController();

    name.addListener(_onRecipeFormChanged);
    tareWeight.addListener(_onRecipeFormChanged);
    cookedWithTareWeight.addListener(_onRecipeFormChanged);

    if (widget.isEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final initialData = await ref
            .read(recipeEditorControllerProvider)
            .loadInitialData(widget.recipeId!);
        final recipe = initialData.recipe;
        final data = initialData.ingredients;

        if (!mounted) return;

        setState(() {
          if (recipe != null) {
            if (recipe.tareWeightGrams > 0) {
              tareWeight.text = recipe.tareWeightGrams.toStringAsFixed(1);
            }

            if (recipe.cookedWithTareWeightGrams > 0) {
              cookedWithTareWeight.text =
                  recipe.cookedWithTareWeightGrams.toStringAsFixed(1);
            }
          }

          items.addAll(data);
        });
      });
    }
  }

  @override
  void dispose() {
    name.removeListener(_onRecipeFormChanged);
    tareWeight.removeListener(_onRecipeFormChanged);
    cookedWithTareWeight.removeListener(_onRecipeFormChanged);

    name.dispose();
    tareWeight.dispose();
    cookedWithTareWeight.dispose();

    super.dispose();
  }

  void _onRecipeFormChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
    FocusScope.of(context).unfocus();
  }

  void _hideKeyboardAfterFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _hideKeyboard();
    });
  }

  double? _positiveDoubleFromController(TextEditingController controller) {
    return ref.read(recipeEditorControllerProvider).positiveNumberFromText(controller.text);
  }

  double? get _tareWeightValue {
    return _positiveDoubleFromController(tareWeight);
  }

  double? get _cookedWithTareWeightValue {
    return _positiveDoubleFromController(cookedWithTareWeight);
  }

  double? get _cookedWeightValue {
    return ref.read(recipeEditorControllerProvider).cookedWeight(
      tareWeightGrams: _tareWeightValue,
      cookedWithTareWeightGrams: _cookedWithTareWeightValue,
    );
  }

  bool get _hasValidCookedWeight {
    return _cookedWeightValue != null;
  }

  bool get _canSaveRecipe {
    return ref.read(recipeEditorControllerProvider).canSaveRecipe(
      loading: loading,
      name: name.text,
      items: items,
      cookedWeightGrams: _cookedWeightValue,
    );
  }

  String? _cookedWithTareValidator(String? value) {
    return ref.read(recipeEditorControllerProvider).cookedWithTareValidator(
      value: value,
      tareWeightGrams: _tareWeightValue,
    );
  }

  Future<void> pickIngredient() async {
    _hideKeyboard();

    final result = await Navigator.of(context).push<PickedFoodEntity>(
      MaterialPageRoute(builder: (_) => const FoodPickerScreen()),
    );

    if (result == null) return;

    await Future<void>.delayed(const Duration(milliseconds: 80));

    if (!mounted) return;

    final gramsController = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) {
        bool canAdd() {
          return _positiveDoubleFromController(gramsController) != null;
        }

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(result.name),
              content: GramsInputWidget(
                controller: gramsController,
                setDialogState: setDialogState,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    Navigator.pop(context, false);
                  },
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: canAdd()
                      ? () {
                          FocusScope.of(context).unfocus();
                          Navigator.pop(context, true);
                        }
                      : null,
                  child: const Text('Добавить'),
                ),
              ],
            );
          },
        );
      },
    );

    if (ok != true) {
      _hideKeyboardAfterFrame();
      return;
    }

    _hideKeyboard();

    final grams = _positiveDoubleFromController(gramsController);
    if (grams == null) return;

    setState(() {
      items.add(
        RecipeIngredientInputEntity(
          sourceType: result.sourceType,
          sourceId: result.id,
          name: result.name,
          grams: grams,
          calories: result.calories,
          proteins: result.proteins,
          fats: result.fats,
          carbs: result.carbs,
        ),
      );
    });

    _hideKeyboardAfterFrame();
  }

  Future<void> _editIngredientGrams(int index) async {
    final current = items[index];
    final controller =
        TextEditingController(text: current.grams.toStringAsFixed(1));

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) {
        bool canSave() {
          return _positiveDoubleFromController(controller) != null;
        }

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Изменить граммы: ${current.name}'),
              content: GramsInputWidget(
                controller: controller,
                setDialogState: setDialogState,
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    FocusScope.of(context).unfocus();
                    Navigator.pop(context, false);
                  },
                  child: const Text('Отмена'),
                ),
                ElevatedButton(
                  onPressed: canSave()
                      ? () {
                          FocusScope.of(context).unfocus();
                          Navigator.pop(context, true);
                        }
                      : null,
                  child: const Text('Сохранить'),
                ),
              ],
            );
          },
        );
      },
    );

    if (ok != true) {
      _hideKeyboardAfterFrame();
      return;
    }

    _hideKeyboard();

    final grams = _positiveDoubleFromController(controller);
    if (grams == null) return;

    setState(() {
      items[index] = RecipeIngredientInputEntity(
        sourceType: current.sourceType,
        sourceId: current.sourceId,
        name: current.name,
        grams: grams,
        calories: current.calories,
        proteins: current.proteins,
        fats: current.fats,
        carbs: current.carbs,
      );
    });

    _hideKeyboardAfterFrame();
  }

  Future<void> save() async {
    if (!_canSaveRecipe) {
      showAppSnackBar(context, recipeFormRequiredMessage);
      return;
    }

    if (!formKey.currentState!.validate()) return;

    final tare = _tareWeightValue;
    final cookedWithTare = _cookedWithTareWeightValue;

    if (tare == null ||
        cookedWithTare == null ||
        ref.read(recipeEditorControllerProvider).cookedWeight(
              tareWeightGrams: tare,
              cookedWithTareWeightGrams: cookedWithTare,
            ) ==
            null) {
      showAppSnackBar(context, cookedWeightPositiveMessage);
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() => loading = true);

    try {
      await ref.read(recipeEditorControllerProvider).saveRecipe(
            recipeId: widget.recipeId,
            name: name.text.trim(),
            ingredients: items,
            tareWeightGrams: tare,
            cookedWithTareWeightGrams: cookedWithTare,
          );

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, russianErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cookedWeight = _cookedWeightValue ?? 0;
    final totals = ref.read(recipeEditorControllerProvider).totalsForInputs(
      items,
      cookedWeightGrams: cookedWeight,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Редактировать рецепт' : 'Новый рецепт'),
        actions: const [
          ScreenHelpAction(
            title: 'Рецепт',
            message:
                'Введите название рецепта и добавьте минимум 2 продукта.\n\n'
                'Для каждого продукта укажите количество граммов.\n\n'
                'Заполните вес тары и вес готового блюда с тарой, чтобы приложение рассчитало КБЖУ рецепта на 100 г.\n\n'
                'Название рецепта не должно совпадать с уже созданными рецептами.\n\n'
                'При редактировании можно менять граммы продуктов, тар, удалять продукты и сохранять обновлённый рецепт.',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: pickIngredient,
        child: const Icon(Icons.add),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: name,
              decoration: const InputDecoration(labelText: 'Название'),
              validator: Validators.requiredText,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: tareWeight,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Вес тары, г',
              ),
              validator: ref.read(recipeEditorControllerProvider).positiveNumberValidator,
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: cookedWithTareWeight,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Вес готового блюда с тарой, г',
              ),
              validator: _cookedWithTareValidator,
            ),
            const SizedBox(height: 12),
            if (_hasValidCookedWeight)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    kbzhuPer100Text(
                      calories: totals.caloriesPer100,
                      proteins: totals.proteinsPer100,
                      fats: totals.fatsPer100,
                      carbs: totals.carbsPer100,
                    ),
                  ),
                ),
              ),
            ...items.asMap().entries.map(
                  (entry) => ListTile(
                    onTap: () => _editIngredientGrams(entry.key),
                    title: Text(entry.value.name),
                    subtitle: Text(
                      kbzhuForGramsText(
                        grams: entry.value.grams,
                        caloriesPer100: entry.value.calories,
                        proteinsPer100: entry.value.proteins,
                        fatsPer100: entry.value.fats,
                        carbsPer100: entry.value.carbs,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => setState(
                        () => items.removeAt(entry.key),
                      ),
                    ),
                  ),
                ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _canSaveRecipe ? save : null,
              child: const Text('Сохранить рецепт'),
            ),
          ],
        ),
      ),
    );
  }
}
