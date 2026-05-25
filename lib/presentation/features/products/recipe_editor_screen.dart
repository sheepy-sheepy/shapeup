import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions.dart';
import '../../../core/app_ui.dart';
import '../../../domain/repositories/products_repository.dart';
import '../../../domain/repositories/recipes_repository.dart';
import '../../../domain/usecases/recipe_nutrition_usecase.dart';
import '../../widgets/csv_products_panel.dart';

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
    final value = double.tryParse(
      controller.text.trim().replaceAll(',', '.'),
    );

    if (value == null || value <= 0) return null;
    return value;
  }

  double? get _tareWeightValue {
    return _positiveDoubleFromController(tareWeight);
  }

  double? get _cookedWithTareWeightValue {
    return _positiveDoubleFromController(cookedWithTareWeight);
  }

  double? get _cookedWeightValue {
    final tare = _tareWeightValue;
    final cookedWithTare = _cookedWithTareWeightValue;

    if (tare == null || cookedWithTare == null) return null;

    final cookedWeight = cookedWithTare - tare;
    if (cookedWeight <= 0) return null;

    return cookedWeight;
  }

  bool get _hasValidCookedWeight {
    return _cookedWeightValue != null;
  }

  bool get _hasTwoDifferentProducts {
    final distinct =
        items.map((item) => '${item.sourceType}:${item.sourceId}').toSet();

    return distinct.length >= 2;
  }

  bool get _canSaveRecipe {
    return !loading &&
        name.text.trim().isNotEmpty &&
        items.length >= 2 &&
        _hasTwoDifferentProducts &&
        _hasValidCookedWeight;
  }

  String? _positiveNumberValidator(String? value) {
    final parsed = double.tryParse(
      (value ?? '').trim().replaceAll(',', '.'),
    );

    if (parsed == null || parsed <= 0) {
      return 'Введите положительное число';
    }

    return null;
  }

  String? _cookedWithTareValidator(String? value) {
    final parsed = double.tryParse(
      (value ?? '').trim().replaceAll(',', '.'),
    );

    if (parsed == null || parsed <= 0) {
      return 'Введите положительное число';
    }

    final tare = _tareWeightValue;
    if (tare != null && parsed <= tare) {
      return 'Вес готового блюда с тарой должен быть больше веса тары';
    }

    return null;
  }


  Widget _gramsDialogContent(
    TextEditingController controller,
    StateSetter setDialogState,
  ) {
    const quickGrams = [50, 100, 150, 200];

    void setQuickGrams(int grams) {
      controller.text = grams.toString();
      controller.selection = TextSelection.collapsed(
        offset: controller.text.length,
      );
      setDialogState(() {});
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Граммы'),
          onChanged: (_) => setDialogState(() {}),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            for (final grams in quickGrams)
              ActionChip(
                label: Text('$grams г'),
                onPressed: () => setQuickGrams(grams),
              ),
          ],
        ),
      ],
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
          final grams = _positiveDoubleFromController(gramsController);
          return grams != null && grams > 0;
        }

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(result.name),
              content: _gramsDialogContent(gramsController, setDialogState),
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
          final grams = _positiveDoubleFromController(controller);
          return grams != null && grams > 0;
        }

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Изменить граммы: ${current.name}'),
              content: _gramsDialogContent(controller, setDialogState),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Укажите название, минимум 2 разных продукта, вес тары и вес готового блюда с тарой',
          ),
        ),
      );
      return;
    }

    if (!formKey.currentState!.validate()) return;

    final tare = _tareWeightValue;
    final cookedWithTare = _cookedWithTareWeightValue;

    if (tare == null || cookedWithTare == null || cookedWithTare - tare <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Итоговый вес готового блюда должен быть больше 0'),
        ),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cookedWeight = _cookedWeightValue ?? 0;
    final totals = RecipeNutritionUseCase.totalsForInputs(
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
                'Введите название рецепта и добавьте минимум 2 разных продукта. '
                'Для каждого продукта укажите количество граммов. '
                'Заполните вес тары и вес готового блюда с тарой, чтобы приложение рассчитало КБЖУ рецепта на 100 г. '
                'Название рецепта не должно совпадать с уже созданными рецептами. '
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
                  validator: _positiveNumberValidator,
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
  static const int _foodsPageSize = 150;

  final query = TextEditingController();
  final scrollController = ScrollController();

  Timer? _searchDebounce;

  String _searchText = '';

  late Future<List<CustomProduct>> _customFuture;

  List<Food> foods = [];
  bool foodsLoading = true;
  bool foodsHasMore = true;
  int foodsOffset = 0;
  String foodsQueryToken = '';
  String? foodsErrorText;

  @override
  void initState() {
    super.initState();

    query.addListener(_onSearchChanged);
    scrollController.addListener(_onScroll);

    _customFuture = _loadCustomProducts();

    foodsQueryToken = _searchText;
    _loadFoodsPage(
      query: foodsQueryToken,
      offset: 0,
      replace: true,
      loadingAlreadySet: true,
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();

    query.removeListener(_onSearchChanged);
    query.dispose();

    scrollController.removeListener(_onScroll);
    scrollController.dispose();

    super.dispose();
  }

  Future<List<CustomProduct>> _loadCustomProducts() {
    return ref.read(productsRepositoryProvider).customProducts(_searchText);
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      final next = query.text.trim();

      if (next == _searchText) return;
      if (!mounted) return;

      setState(() {
        _searchText = next;
        _customFuture = _loadCustomProducts();

        foods = [];
        foodsOffset = 0;
        foodsHasMore = true;
        foodsLoading = true;
        foodsErrorText = null;
        foodsQueryToken = next;
      });

      if (scrollController.hasClients) {
        scrollController.jumpTo(0);
      }

      _loadFoodsPage(
        query: next,
        offset: 0,
        replace: true,
        loadingAlreadySet: true,
      );
    });
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    if (foodsLoading || !foodsHasMore) return;

    final position = scrollController.position;
    final remaining = position.maxScrollExtent - position.pixels;

    if (remaining < 500) {
      _loadNextFoodsPage();
    }
  }

  Future<void> _loadNextFoodsPage() async {
    if (foodsLoading || !foodsHasMore) return;

    await _loadFoodsPage(
      query: foodsQueryToken,
      offset: foodsOffset,
      replace: false,
    );
  }

  Future<void> _loadFoodsPage({
    required String query,
    required int offset,
    required bool replace,
    bool loadingAlreadySet = false,
  }) async {
    if (!loadingAlreadySet) {
      if (!mounted) return;

      setState(() {
        foodsLoading = true;
        foodsErrorText = null;
      });
    }

    try {
      final loaded = await ref.read(productsRepositoryProvider).baseFoodsPage(
            query,
            offset: offset,
            limit: _foodsPageSize,
          );

      if (!mounted || query != foodsQueryToken) return;

      setState(() {
        if (replace) {
          foods = loaded;
          foodsOffset = loaded.length;
        } else {
          final existingIds = foods.map((e) => e.id).toSet();

          final uniqueLoaded = loaded.where((e) {
            if (existingIds.contains(e.id)) return false;
            existingIds.add(e.id);
            return true;
          }).toList();

          foods = [...foods, ...uniqueLoaded];

          foodsOffset += loaded.length;
        }

        foodsHasMore = loaded.length == _foodsPageSize;
        foodsLoading = false;
        foodsErrorText = null;
      });
    } catch (e) {
      if (!mounted || query != foodsQueryToken) return;

      setState(() {
        foodsLoading = false;
        foodsHasMore = false;
        foodsErrorText = e.toString();
      });
    }
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
                        if (snapshot.connectionState == ConnectionState.waiting &&
                            !snapshot.hasData)
                          const ListTile(title: Text('Загружаем свои продукты...')),
                        if (snapshot.hasData && custom.isEmpty)
                          const ListTile(title: Text('Нет своих продуктов')),
                        ...custom.map(
                          (e) => ListTile(
                            title: CustomProductNameLabel(name: e.name),
                            subtitle: Text(
                              kbzhuPer100Text(
                                calories: e.calories,
                                proteins: e.proteins,
                                fats: e.fats,
                                carbs: e.carbs,
                              ),
                            ),
                            onTap: () => _popCustomProduct(e),
                          ),
                        ),
                      ],
                    ),
                    CsvProductsPanel(
                      children: [
                        if (foodsErrorText != null)
                          ListTile(
                            title: const Text('Ошибка загрузки базы продуктов'),
                            subtitle: Text(foodsErrorText!),
                          ),
                        if (foods.isEmpty && !foodsLoading)
                          const ListTile(title: Text('Ничего не найдено')),
                        ...foods.map(
                          (e) => ListTile(
                            title: CsvFoodNameLabel(name: e.name),
                            subtitle: Text(
                              kbzhuPer100Text(
                                calories: e.calories,
                                proteins: e.proteins,
                                fats: e.fats,
                                carbs: e.carbs,
                              ),
                            ),
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
