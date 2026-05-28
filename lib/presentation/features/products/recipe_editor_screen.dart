import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_errors.dart';
import '../../../core/extensions.dart';
import '../../../core/app_ui.dart';
import '../../../domain/repositories/products_repository.dart';
import '../../../domain/repositories/recipes_repository.dart';
import '../../../domain/usecases/recipe_editor_usecase.dart';
import '../../controllers/base_foods_paging_controller.dart';
import '../../widgets/products_panel.dart';
import '../../widgets/grams_input_content.dart';

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

  final List<RecipeIngredientInput> items = [];

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
        final recipe = await ref
            .read(recipesRepositoryProvider)
            .recipeById(widget.recipeId!);

        final data = await ref
            .read(recipesRepositoryProvider)
            .ingredients(widget.recipeId!);

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

          items.addAll(
            data.map(
              (e) => RecipeIngredientInput(
                sourceType: e.sourceType,
                sourceId: e.sourceId,
                name: e.nameSnapshot,
                grams: e.grams,
                calories: e.caloriesSnapshot,
                proteins: e.proteinsSnapshot,
                fats: e.fatsSnapshot,
                carbs: e.carbsSnapshot,
              ),
            ),
          );
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
    return RecipeEditorUseCase.positiveNumberFromText(controller.text);
  }

  double? get _tareWeightValue {
    return _positiveDoubleFromController(tareWeight);
  }

  double? get _cookedWithTareWeightValue {
    return _positiveDoubleFromController(cookedWithTareWeight);
  }

  double? get _cookedWeightValue {
    return RecipeEditorUseCase.cookedWeight(
      tareWeightGrams: _tareWeightValue,
      cookedWithTareWeightGrams: _cookedWithTareWeightValue,
    );
  }

  bool get _hasValidCookedWeight {
    return _cookedWeightValue != null;
  }

  bool get _canSaveRecipe {
    return RecipeEditorUseCase.canSaveRecipe(
      loading: loading,
      name: name.text,
      items: items,
      cookedWeightGrams: _cookedWeightValue,
    );
  }

  String? _cookedWithTareValidator(String? value) {
    return RecipeEditorUseCase.cookedWithTareValidator(
      value: value,
      tareWeightGrams: _tareWeightValue,
    );
  }

  Future<void> pickIngredient() async {
    _hideKeyboard();

    final result = await Navigator.of(context).push<_PickedFood>(
      MaterialPageRoute(builder: (_) => const _FoodPickerScreen()),
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
              content: GramsInputContent(
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
        RecipeIngredientInput(
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
              content: GramsInputContent(
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
      items[index] = RecipeIngredientInput(
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
        RecipeEditorUseCase.cookedWeight(
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
      if (widget.isEdit) {
        await ref.read(recipesRepositoryProvider).updateRecipe(
              recipeId: widget.recipeId!,
              name: name.text.trim(),
              ingredients: items,
              tareWeightGrams: tare,
              cookedWithTareWeightGrams: cookedWithTare,
            );
      } else {
        await ref.read(recipesRepositoryProvider).createRecipe(
              name: name.text.trim(),
              ingredients: items,
              tareWeightGrams: tare,
              cookedWithTareWeightGrams: cookedWithTare,
            );
      }

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
    final totals = RecipeEditorUseCase.totalsForInputs(
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
                'Введите название рецепта и добавьте минимум 2 разных продукта.\n\n'
                'Для каждого продукта укажите количество граммов.\n\n'
                'Заполните вес тары и вес готового блюда с тарой, чтобы приложение рассчитало КБЖУ рецепта на 100 г.\n\n'
                'Название рецепта не должно совпадать с уже созданными рецептами.\n\n'
                'При редактировании можно менять граммы продуктов, удалять продукты и сохранять обновлённый рецепт.',
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
              validator: RecipeEditorUseCase.positiveNumberValidator,
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

class _PickedFood {
  final String id;
  final String sourceType;
  final String name;
  final double calories;
  final double proteins;
  final double fats;
  final double carbs;

  const _PickedFood({
    required this.id,
    required this.sourceType,
    required this.name,
    required this.calories,
    required this.proteins,
    required this.fats,
    required this.carbs,
  });
}

class _FoodPickerScreen extends ConsumerStatefulWidget {
  const _FoodPickerScreen();

  @override
  ConsumerState<_FoodPickerScreen> createState() => _FoodPickerScreenState();
}

class _FoodPickerScreenState extends ConsumerState<_FoodPickerScreen> {
  final query = TextEditingController();
  final scrollController = ScrollController();

  late final BaseFoodsPagingController foodsController;
  late Future<List<CustomProduct>> _customFuture;

  @override
  void initState() {
    super.initState();

    foodsController = BaseFoodsPagingController(
      productsRepository: ref.read(productsRepositoryProvider),
    );

    foodsController.bind(
      queryController: query,
      scrollController: scrollController,
      onFoodsChanged: () {
        if (!mounted) return;
        setState(() {});
      },
      onSearchAccepted: () {
        _customFuture = _loadCustomProducts();
      },
    );

    _customFuture = _loadCustomProducts();
    foodsController.start();
  }

  @override
  void dispose() {
    foodsController.dispose();

    query.dispose();
    scrollController.dispose();

    super.dispose();
  }

  Future<List<CustomProduct>> _loadCustomProducts() {
    return ref
        .read(productsRepositoryProvider)
        .customProducts(foodsController.searchText);
  }

  void _popCustomProduct(CustomProduct product) {
    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.pop(
      context,
      _PickedFood(
        id: product.id,
        sourceType: 'custom_product',
        name: product.name,
        calories: product.calories,
        proteins: product.proteins,
        fats: product.fats,
        carbs: product.carbs,
      ),
    );
  }

  void _popFood(Food food) {
    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.pop(
      context,
      _PickedFood(
        id: food.id,
        sourceType: 'food',
        name: food.name,
        calories: food.calories,
        proteins: food.proteins,
        fats: food.fats,
        carbs: food.carbs,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final foods = foodsController.foods;
    final foodsLoading = foodsController.foodsLoading;
    final foodsHasMore = foodsController.foodsHasMore;
    final foodsErrorText = foodsController.foodsErrorText;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Выбрать продукт'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: query,
              decoration: const InputDecoration(labelText: 'Поиск'),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<CustomProduct>>(
              future: _customFuture,
              builder: (context, snapshot) {
                final custom = snapshot.data ?? const <CustomProduct>[];

                return ListView(
                  controller: scrollController,
                  children: [
                    CustomProductsPanel(
                      children: [
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData)
                          const ListTile(
                              title: Text('Загружаем свои продукты...')),
                        if (snapshot.hasData && custom.isEmpty)
                          const ListTile(title: Text('Нет своих продуктов')),
                        ...custom.map(
                          (e) => CustomProductTile(
                            product: e,
                            onTap: () => _popCustomProduct(e),
                          ),
                        ),
                      ],
                    ),
                    CsvProductsPanel(
                      children: [
                        if (foodsErrorText != null)
                          ListTile(
                            title: const Text(baseFoodsLoadErrorTitle),
                            subtitle: Text(foodsErrorText),
                          ),
                        if (foods.isEmpty && !foodsLoading)
                          const ListTile(title: Text(nothingFoundMessage)),
                        ...foods.map(
                          (e) => CsvFoodTile(
                            food: e,
                            onTap: () => _popFood(e),
                          ),
                        ),
                        if (foodsLoading)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          ),
                        if (!foodsLoading && foodsHasMore)
                          const SizedBox(height: 16),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
