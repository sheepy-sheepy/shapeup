import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_errors.dart';

import '../../../core/extensions.dart';
import '../../../core/app_ui.dart';
import '../../../domain/entities/local_entities.dart';
import '../../../domain/repositories/products_repository.dart';
import '../../../domain/repositories/recipes_repository.dart';
import '../../services/recipe_search_service.dart';
import '../../../domain/usecases/recipe_nutrition_usecase.dart';
import '../../../domain/usecases/product_form_usecase.dart';
import '../../controllers/base_foods_paging_controller.dart';
import 'recipe_editor_screen.dart';
import '../../widgets/products_panel.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen>
    with SingleTickerProviderStateMixin {
  final query = TextEditingController();
  final ScrollController _productsScrollController = ScrollController();

  late final TabController tabController;
  late final BaseFoodsPagingController foodsController;

  late Future<_ProductsTabData> _productsFuture;
  late Future<List<Recipe>> _recipesFuture;

  final Map<String, Future<List<RecipeIngredient>>> _recipeIngredientsFutures =
      {};

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 2, vsync: this);
    foodsController = BaseFoodsPagingController(
      productsRepository: ref.read(productsRepositoryProvider),
    );

    foodsController.bind(
      queryController: query,
      scrollController: _productsScrollController,
      onFoodsChanged: () {
        if (!mounted) return;
        setState(() {});
      },
      onSearchAccepted: () {
        _productsFuture = _loadProducts();
        _recipesFuture = _loadRecipes();
        _recipeIngredientsFutures.clear();
      },
    );

    _productsFuture = _loadProducts();
    _recipesFuture = _loadRecipes();
    foodsController.start();
  }

  @override
  void dispose() {
    foodsController.dispose();

    query.dispose();
    _productsScrollController.dispose();

    tabController.dispose();

    super.dispose();
  }

  Future<_ProductsTabData> _loadProducts() async {
    final productsRepo = ref.read(productsRepositoryProvider);

    final custom =
        await productsRepo.customProducts(foodsController.searchText);

    return _ProductsTabData(
      customProducts: custom,
    );
  }

  Future<List<Recipe>> _loadRecipes() async {
    final allRecipes = await ref.read(recipesRepositoryProvider).recipes('');

    return RecipeSearchService.filterAndSortBySearch(
      allRecipes,
      foodsController.searchText,
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
      return recipeCookedWeightMissingMessage;
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
    final foods = foodsController.foods;
    final foodsLoading = foodsController.foodsLoading;
    final foodsHasMore = foodsController.foodsHasMore;
    final foodsErrorText = foodsController.foodsErrorText;

    final productsRepo = ref.watch(productsRepositoryProvider);
    final recipesRepo = ref.watch(recipesRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Продукты и рецепты'),
        actions: const [
          ScreenHelpAction(
            title: 'Продукты и рецепты',
            message: 'На этом экране можно создавать свои продукты и рецепты.\n\n'
                'Во вкладке «Продукты» добавляйте свои продукты: название и КБЖУ на 100 г.\n\n'
                'Название своего продукта не должно совпадать с уже созданными продуктами и продуктами из встроенной базы.\n\n'
                'Во вкладке «Рецепты» создавайте блюда из разных продуктов, указывайте граммовку ингредиентов, вес тары и вес готового блюда с тарой.\n\n'
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
                          errorWithTitle(
                              productsLoadErrorTitle, snapshot.error),
                        ),
                      );
                    }

                    final data = snapshot.data;
                    if (data == null) {
                      return const SizedBox.shrink();
                    }

                    final custom = data.customProducts;

                    return NotificationListener<ScrollNotification>(
                      onNotification: foodsController.onScrollNotification,
                      child: ListView(
                        key: const PageStorageKey<String>('products_tab_list'),
                        controller: _productsScrollController,
                        children: [
                          CustomProductsPanel(
                            children: [
                              if (custom.isEmpty)
                                const ListTile(
                                    title: Text('Нет своих продуктов')),
                              ...custom.map(
                                (e) => CustomProductTile(
                                  product: e,
                                  onTap: () async {
                                    await showDialog(
                                      context: context,
                                      builder: (_) =>
                                          _ProductDialog(product: e),
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
                              if (foodsErrorText != null)
                                ListTile(
                                  title: const Text(baseFoodsLoadErrorTitle),
                                  subtitle: Text(foodsErrorText),
                                ),
                              if (foods.isEmpty && !foodsLoading)
                                const ListTile(
                                    title: Text(nothingFoundMessage)),
                              ...foods.map(
                                (e) => CsvFoodTile(food: e),
                              ),
                              if (foodsLoading)
                                const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(
                                      child: CircularProgressIndicator()),
                                ),
                              if (!foodsLoading && foodsHasMore)
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
                          errorWithTitle(recipesLoadErrorTitle, snapshot.error),
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

                                    final ingredients =
                                        ingredientsSnapshot.data!;

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
    return ProductFormUseCase.nonNegativeNumberFromText(controller.text);
  }

  double? _caloriesFromMacros() {
    return ProductFormUseCase.caloriesFromMacros(
      proteins: _nonNegativeDouble(proteins),
      fats: _nonNegativeDouble(fats),
      carbs: _nonNegativeDouble(carbs),
    );
  }

  String? _macroCaloriesText() {
    final calculated = _caloriesFromMacros();

    if (calculated == null) {
      return null;
    }

    return 'Калории по БЖУ: ${calculated.toStringAsFixed(2)} ккал';
  }

  bool get _canSaveProduct {
    return ProductFormUseCase.canSaveProduct(
      name: name.text,
      calories: _nonNegativeDouble(calories),
      proteins: _nonNegativeDouble(proteins),
      fats: _nonNegativeDouble(fats),
      carbs: _nonNegativeDouble(carbs),
    );
  }

  String _cleanErrorText(Object error) {
    return russianErrorMessage(error);
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
