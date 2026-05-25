import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions.dart';
import '../../../core/app_ui.dart';
import '../../../domain/entities/local_entities.dart';
import '../../../domain/repositories/products_repository.dart';
import '../../../domain/repositories/recipes_repository.dart';
import '../../../domain/usecases/recipe_nutrition_usecase.dart';
import 'recipe_editor_screen.dart';
import '../../widgets/csv_products_panel.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen>
    with SingleTickerProviderStateMixin {
  static const int _foodsPageSize = 150;

  final query = TextEditingController();
  final ScrollController _productsScrollController = ScrollController();

  late final TabController tabController;

  Timer? _searchDebounce;
  String _searchText = '';

  late Future<_ProductsTabData> _productsFuture;
  late Future<List<Recipe>> _recipesFuture;

  final Map<String, Future<List<RecipeIngredient>>> _recipeIngredientsFutures =
      {};

  List<Food> _foods = [];
  bool _foodsLoading = true;
  bool _foodsHasMore = true;
  int _foodsOffset = 0;
  String _foodsQueryToken = '';
  String? _foodsErrorText;

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 2, vsync: this);
    query.addListener(_onSearchChanged);
    _productsScrollController.addListener(_onProductsScroll);

    _productsFuture = _loadProducts();
    _recipesFuture = _loadRecipes();

    _foodsQueryToken = _searchText;
    _loadFoodsPage(
      query: _foodsQueryToken,
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

    _productsScrollController.removeListener(_onProductsScroll);
    _productsScrollController.dispose();

    tabController.dispose();

    super.dispose();
  }

  bool _onProductsScrollNotification(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;
    if (_foodsLoading || !_foodsHasMore) return false;

    final nearBottom = notification.metrics.extentAfter < 500;

    if (nearBottom) {
      _loadNextFoodsPage();
    }

    return false;
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      final next = query.text.trim();

      if (next == _searchText) return;
      if (!mounted) return;

      setState(() {
        _searchText = next;
        _productsFuture = _loadProducts();
        _recipesFuture = _loadRecipes();
        _recipeIngredientsFutures.clear();

        _foods = [];
        _foodsOffset = 0;
        _foodsHasMore = true;
        _foodsLoading = true;
        _foodsErrorText = null;
        _foodsQueryToken = next;
      });

      if (_productsScrollController.hasClients) {
        _productsScrollController.jumpTo(0);
      }

      _loadFoodsPage(
        query: next,
        offset: 0,
        replace: true,
        loadingAlreadySet: true,
      );
    });
  }

  void _onProductsScroll() {
    if (!_productsScrollController.hasClients) return;
    if (_foodsLoading || !_foodsHasMore) return;

    final position = _productsScrollController.position;
    final remaining = position.maxScrollExtent - position.pixels;

    if (remaining < 500) {
      _loadNextFoodsPage();
    }
  }

  Future<void> _loadNextFoodsPage() async {
    if (_foodsLoading || !_foodsHasMore) return;

    await _loadFoodsPage(
      query: _foodsQueryToken,
      offset: _foodsOffset,
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
        _foodsLoading = true;
        _foodsErrorText = null;
      });
    }

    try {
      final loaded = await ref.read(productsRepositoryProvider).baseFoodsPage(
            query,
            offset: offset,
            limit: _foodsPageSize,
          );

      if (!mounted || query != _foodsQueryToken) return;

      setState(() {
        if (replace) {
          _foods = loaded;
          _foodsOffset = loaded.length;
        } else {
          final existingIds = _foods.map((e) => e.id).toSet();

          final uniqueLoaded = loaded.where((e) {
            if (existingIds.contains(e.id)) return false;
            existingIds.add(e.id);
            return true;
          }).toList();

          _foods = [..._foods, ...uniqueLoaded];

          // offset увеличиваем на loaded.length, а не uniqueLoaded.length,
          // чтобы не зациклиться, если база вдруг вернула дубль.
          _foodsOffset += loaded.length;
        }

        _foodsHasMore = loaded.length == _foodsPageSize;
        _foodsLoading = false;
        _foodsErrorText = null;
      });
    } catch (e) {
      if (!mounted || query != _foodsQueryToken) return;

      setState(() {
        _foodsLoading = false;
        _foodsHasMore = false;
        _foodsErrorText = e.toString();
      });
    }
  }

  Future<_ProductsTabData> _loadProducts() async {
    final productsRepo = ref.read(productsRepositoryProvider);

    final custom = await productsRepo.customProducts(_searchText);

    return _ProductsTabData(
      customProducts: custom,
    );
  }

  String _normalizeSearch(String value) {
    return value.trim().toLowerCase();
  }

  List<Recipe> _filterAndSortRecipesBySearch(
    List<Recipe> recipes,
    String query,
  ) {
    final q = _normalizeSearch(query);

    if (q.isEmpty) {
      return recipes;
    }

    final startsWith = <Recipe>[];
    final contains = <Recipe>[];

    for (final recipe in recipes) {
      final name = _normalizeSearch(recipe.name);

      if (name.startsWith(q)) {
        startsWith.add(recipe);
      } else if (name.contains(q)) {
        contains.add(recipe);
      }
    }

    startsWith.sort(
      (a, b) => _normalizeSearch(a.name).compareTo(_normalizeSearch(b.name)),
    );

    contains.sort(
      (a, b) => _normalizeSearch(a.name).compareTo(_normalizeSearch(b.name)),
    );

    return [
      ...startsWith,
      ...contains,
    ];
  }

  Future<List<Recipe>> _loadRecipes() async {
    final allRecipes = await ref.read(recipesRepositoryProvider).recipes('');

    return _filterAndSortRecipesBySearch(
      allRecipes,
      _searchText,
    );
  }

  Future<List<RecipeIngredient>> _recipeIngredientsFuture(String recipeId) {
    return _recipeIngredientsFutures.putIfAbsent(
      recipeId,
      () => ref.read(recipesRepositoryProvider).ingredients(recipeId),
    );
  }

  String _recipeKbzhuPer100Text(
    Recipe recipe,
    List<RecipeIngredient> ingredients,
  ) {
    try {
      final per100 = RecipeNutritionUseCase.per100ForRecipe(
        recipe: recipe,
        ingredients: ingredients,
      );

      return kbzhuPer100Text(
        calories: per100.calories,
        proteins: per100.proteins,
        fats: per100.fats,
        carbs: per100.carbs,
      );
    } catch (_) {
      return 'Не указан итоговый вес готового блюда';
    }
  }

  void _reloadProducts() {
    setState(() {
      _productsFuture = _loadProducts();
    });
  }

  void _reloadRecipes() {
    setState(() {
      _recipesFuture = _loadRecipes();
      _recipeIngredientsFutures.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final productsRepo = ref.watch(productsRepositoryProvider);
    final recipesRepo = ref.watch(recipesRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Продукты и рецепты'),
        actions: const [
          ScreenHelpAction(
            title: 'Продукты и рецепты',
            message: 'На этом экране можно создавать свои продукты и рецепты. '
                'Во вкладке «Продукты» добавляйте свои продукты: название и КБЖУ на 100 г. '
                'Название своего продукта не должно совпадать с уже созданными продуктами и продуктами из встроенной базы. '
                'Во вкладке «Рецепты» создавайте блюда из разных продуктов, указывайте граммовку ингредиентов, вес тары и вес готового блюда с тарой. '
                'Поиск сверху помогает быстро найти свои продукты, рецепты и продукты из встроенной базы.',
          ),
        ],
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Продукты'),
            Tab(text: 'Рецепты'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (tabController.index == 0) {
            await showDialog(
              context: context,
              builder: (_) => const _ProductDialog(),
            );

            if (!mounted) return;
            _reloadProducts();
          } else {
            final result = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (_) => const RecipeEditorScreen(),
              ),
            );

            if (result == true && mounted) {
              _reloadRecipes();
            }
          }
        },
        child: const Icon(Icons.add),
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
            child: TabBarView(
              controller: tabController,
              children: [
                FutureBuilder<_ProductsTabData>(
                  future: _productsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Ошибка загрузки продуктов: ${snapshot.error}',
                        ),
                      );
                    }

                    final data = snapshot.data;
                    if (data == null) {
                      return const SizedBox.shrink();
                    }

                    final custom = data.customProducts;

                    return NotificationListener<ScrollNotification>(
                      onNotification: _onProductsScrollNotification,
                      child: ListView(
                        key: const PageStorageKey<String>('products_tab_list'),
                        controller: _productsScrollController,
                        children: [
                          CustomProductsPanel(
                            children: [
                              if (custom.isEmpty)
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
                                  onTap: () async {
                                    await showDialog(
                                      context: context,
                                      builder: (_) => _ProductDialog(product: e),
                                    );

                                    if (!mounted) return;
                                    _reloadProducts();
                                  },
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      await productsRepo.deleteProduct(e.id);

                                      if (!mounted) return;
                                      _reloadProducts();
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          CsvProductsPanel(
                            children: [
                              if (_foodsErrorText != null)
                                ListTile(
                                  title: const Text('Ошибка загрузки базы продуктов'),
                                  subtitle: Text(_foodsErrorText!),
                                ),
                              if (_foods.isEmpty && !_foodsLoading)
                                const ListTile(title: Text('Ничего не найдено')),
                              ..._foods.map(
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
                                ),
                              ),
                              if (_foodsLoading)
                                const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(child: CircularProgressIndicator()),
                                ),
                              if (!_foodsLoading && _foodsHasMore)
                                const SizedBox(height: 16),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
                FutureBuilder<List<Recipe>>(
                  future: _recipesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting &&
                        !snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Ошибка загрузки рецептов: ${snapshot.error}',
                        ),
                      );
                    }

                    final recipes = snapshot.data ?? const <Recipe>[];

                    return ListView(
                      key: const PageStorageKey<String>('recipes_tab_list'),
                      children: [
                        CustomRecipesPanel(
                          children: [
                            if (recipes.isEmpty)
                              const ListTile(title: Text('Нет рецептов')),
                            ...recipes.map(
                              (e) => ListTile(
                                title: CustomRecipeNameLabel(name: e.name),
                                subtitle: FutureBuilder<List<RecipeIngredient>>(
                                  future: _recipeIngredientsFuture(e.id),
                                  builder: (context, ingredientsSnapshot) {
                                    if (!ingredientsSnapshot.hasData) {
                                      return const Text('Загрузка КБЖУ...');
                                    }

                                    final ingredients = ingredientsSnapshot.data!;

                                    return Text(
                                      _recipeKbzhuPer100Text(e, ingredients),
                                    );
                                  },
                                ),
                                onTap: () async {
                                  final result =
                                      await Navigator.of(context).push<bool>(
                                    MaterialPageRoute(
                                      builder: (_) => RecipeEditorScreen(
                                        recipeId: e.id,
                                        initialName: e.name,
                                      ),
                                    ),
                                  );

                                  if (result == true && mounted) {
                                    _reloadRecipes();
                                  }
                                },
                                trailing: IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () async {
                                    await recipesRepo.deleteRecipe(e.id);

                                    if (!mounted) return;
                                    _reloadRecipes();
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _ProductsTabData {
  const _ProductsTabData({
    required this.customProducts,
  });

  final List<CustomProduct> customProducts;
}

class _ProductDialog extends ConsumerStatefulWidget {
  const _ProductDialog({this.product});

  final CustomProduct? product;

  @override
  ConsumerState<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends ConsumerState<_ProductDialog> {
  final formKey = GlobalKey<FormState>();

  late final TextEditingController name;
  late final TextEditingController calories;
  late final TextEditingController proteins;
  late final TextEditingController fats;
  late final TextEditingController carbs;
  final GlobalKey<ScaffoldMessengerState> _dialogMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  String _formatNumber(double value, int decimals) {
    return value.toStringAsFixed(decimals);
  }

  @override
  void initState() {
    super.initState();

    name = TextEditingController(text: widget.product?.name ?? '');
    calories = TextEditingController(
      text: widget.product == null
          ? ''
          : _formatNumber(widget.product!.calories, 2),
    );
    proteins = TextEditingController(
      text: widget.product == null
          ? ''
          : _formatNumber(widget.product!.proteins, 2),
    );
    fats = TextEditingController(
      text:
          widget.product == null ? '' : _formatNumber(widget.product!.fats, 2),
    );
    carbs = TextEditingController(
      text:
          widget.product == null ? '' : _formatNumber(widget.product!.carbs, 2),
    );
  }

  @override
  void dispose() {
    name.dispose();
    calories.dispose();
    proteins.dispose();
    fats.dispose();
    carbs.dispose();
    super.dispose();
  }

  double d(TextEditingController c) {
    return _nonNegativeDouble(c)!;
  }

  double? _nonNegativeDouble(TextEditingController controller) {
    final value = double.tryParse(
      controller.text.trim().replaceAll(',', '.'),
    );

    if (value == null || value < 0) return null;
    return value;
  }

  double? _caloriesFromMacros() {
    final p = _nonNegativeDouble(proteins);
    final f = _nonNegativeDouble(fats);
    final c = _nonNegativeDouble(carbs);

    if (p == null || f == null || c == null) return null;

    return (p * 4) + (f * 9) + (c * 4);
  }

  String? _macroCaloriesText() {
    final calculated = _caloriesFromMacros();

    if (calculated == null) {
      return null;
    }

    return 'Калории по БЖУ: ${calculated.toStringAsFixed(2)} ккал';
  }

  bool get _canSaveProduct {
    return name.text.trim().isNotEmpty &&
        _nonNegativeDouble(calories) != null &&
        _nonNegativeDouble(proteins) != null &&
        _nonNegativeDouble(fats) != null &&
        _nonNegativeDouble(carbs) != null;
  }

  String _cleanErrorText(Object error) {
    final text = error.toString();
    const exceptionPrefix = 'Exception: ';

    if (text.startsWith(exceptionPrefix)) {
      return text.substring(exceptionPrefix.length);
    }

    return text;
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return ScaffoldMessenger(
      key: _dialogMessengerKey,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: Center(
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              void refreshButton() {
                _dialogMessengerKey.currentState?.hideCurrentSnackBar();
                setDialogState(() {});
              }

              void showProductError(Object error) {
                final messenger = _dialogMessengerKey.currentState;
                if (messenger == null) return;

                messenger
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(_cleanErrorText(error)),
                    ),
                  );
              }

              return AlertDialog(
                title: Text(isEdit ? 'Редактировать продукт' : 'Новый продукт'),
                content: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      spacing: 9,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: name,
                          decoration:
                              const InputDecoration(labelText: 'Название'),
                          validator: Validators.requiredText,
                          onChanged: (_) => refreshButton(),
                        ),
                        TextFormField(
                          controller: calories,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration:
                              const InputDecoration(labelText: 'Калории'),
                          validator: Validators.nonNegativeNumber,
                          onChanged: (_) => refreshButton(),
                        ),
                        if (_macroCaloriesText() != null) ...[
                          
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              
                              _macroCaloriesText()!,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                        TextFormField(
                          controller: proteins,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(labelText: 'Белки'),
                          validator: Validators.nonNegativeNumber,
                          onChanged: (_) => refreshButton(),
                        ),
                        TextFormField(
                          controller: fats,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(labelText: 'Жиры'),
                          validator: Validators.nonNegativeNumber,
                          onChanged: (_) => refreshButton(),
                        ),
                        TextFormField(
                          controller: carbs,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration:
                              const InputDecoration(labelText: 'Углеводы'),
                          validator: Validators.nonNegativeNumber,
                          onChanged: (_) => refreshButton(),
                        ),
                      ],
                    ),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Отмена'),
                  ),
                  ElevatedButton(
                    onPressed: _canSaveProduct
                        ? () async {
                            if (!formKey.currentState!.validate()) return;

                            FocusManager.instance.primaryFocus?.unfocus();

                            try {
                              if (isEdit) {
                                await ref
                                    .read(productsRepositoryProvider)
                                    .updateProduct(
                                      id: widget.product!.id,
                                      name: name.text.trim(),
                                      calories: d(calories),
                                      proteins: d(proteins),
                                      fats: d(fats),
                                      carbs: d(carbs),
                                    );
                              } else {
                                await ref
                                    .read(productsRepositoryProvider)
                                    .createProduct(
                                      name: name.text.trim(),
                                      calories: d(calories),
                                      proteins: d(proteins),
                                      fats: d(fats),
                                      carbs: d(carbs),
                                    );
                              }

                              if (context.mounted) Navigator.pop(context);
                            } catch (e) {
                              if (!context.mounted) return;

                              showProductError(e);
                            }
                          }
                        : null,
                    child: const Text('Сохранить'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
