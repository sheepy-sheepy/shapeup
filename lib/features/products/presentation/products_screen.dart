import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shapeup/core/shared/errors.dart';
import 'package:shapeup/core/design/ui.dart';
import 'package:shapeup/features/products/presentation/controllers/base_foods_paging_controller.dart';
import 'package:shapeup/features/products/presentation/recipe_editor_screen.dart';
import 'package:shapeup/features/products/presentation/widgets/base_food_tile_widget.dart';
import 'package:shapeup/features/products/presentation/widgets/base_foods_panel_widget.dart';
import 'package:shapeup/features/products/presentation/widgets/product_tile_widget.dart';
import 'package:shapeup/features/products/presentation/widgets/products_panel_widget.dart';
import 'package:shapeup/features/products/presentation/widgets/recipe_label_widget.dart';
import 'package:shapeup/features/products/presentation/widgets/recipes_panel_widget.dart';
import 'package:shapeup/features/products/presentation/widgets/product_dialog_widget.dart';
import 'package:shapeup/features/products/domain/entities/products_tab_entity.dart';
import 'package:shapeup/features/products/domain/entities/recipe_entity.dart';
import 'package:shapeup/features/products/domain/entities/recipe_ingredient_entity.dart';
import 'package:shapeup/features/products/providers/products_provider.dart';

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

  late Future<ProductsTabEntity> _productsFuture;
  late Future<List<RecipeEntity>> _recipesFuture;

  final Map<String, Future<List<RecipeIngredientEntity>>>
      _recipeIngredientsFutures = {};

  @override
  void initState() {
    super.initState();

    tabController = TabController(length: 2, vsync: this);
    foodsController = ref.read(baseFoodsPagingControllerFactoryProvider)();

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

  Future<ProductsTabEntity> _loadProducts() async {
    final custom = await ref
        .read(productsControllerProvider)
        .customProducts(foodsController.searchText);

    return ProductsTabEntity(
      customProducts: custom,
    );
  }

  Future<List<RecipeEntity>> _loadRecipes() async {
    return ref.read(productsControllerProvider).recipes(
          foodsController.searchText,
        );
  }

  Future<List<RecipeIngredientEntity>> _recipeIngredientsFuture(
      String recipeId) {
    return _recipeIngredientsFutures.putIfAbsent(
      recipeId,
      () => ref.read(productsControllerProvider).recipeIngredients(recipeId),
    );
  }

  String _recipeKbzhuPer100Text(
    RecipeEntity recipe,
    List<RecipeIngredientEntity> ingredients,
  ) {
    return ref
        .read(productsControllerProvider)
        .recipeKbzhuPer100TextFromIngredients(
          recipe: recipe,
          ingredients: ingredients,
        );
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Продукты и рецепты'),
        actions: const [
          ScreenHelpAction(
            title: 'Продукты и рецепты',
            message:
                'На этом экране можно создавать свои продукты и рецепты.\n\n'
                'Во вкладке «Продукты» добавляйте/редактируйте свои продукты по название и КБЖУ на 100 г, просматривайте базовые продукты.\n\n'
                'Название своего продукта не должно совпадать с уже созданными продуктами и продуктами из встроенной базы.\n\n'
                'Во вкладке «Рецепты» создавайте блюда из разных продуктов, указывайте граммовку ингредиентов, вес тары и вес готового блюда с тарой.\n\n'
                'Свои продукты и рецепты можно удалять при нажатии на значок корзины рядом.\n\n'
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
              builder: (_) => const ProductDialogWidget(),
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
                FutureBuilder<ProductsTabEntity>(
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
                          ProductsPanelWidget(
                            children: [
                              if (custom.isEmpty)
                                const ListTile(
                                    title: Text('Нет своих продуктов')),
                              ...custom.map(
                                (e) => ProductTileWidget(
                                  product: e,
                                  onTap: () async {
                                    await showDialog(
                                      context: context,
                                      builder: (_) =>
                                          ProductDialogWidget(product: e),
                                    );

                                    if (!mounted) return;
                                    _reloadProducts();
                                  },
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () async {
                                      await ref
                                          .read(productsControllerProvider)
                                          .deleteProduct(e.id);

                                      if (!mounted) return;
                                      _reloadProducts();
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          BaseFoodsPanelWidget(
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
                                (e) => BaseFoodTileWidget(food: e),
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
                FutureBuilder<List<RecipeEntity>>(
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

                    final recipes = snapshot.data ?? const <RecipeEntity>[];

                    return ListView(
                      key: const PageStorageKey<String>('recipes_tab_list'),
                      children: [
                        RecipesPanelWidget(
                          children: [
                            if (recipes.isEmpty)
                              const ListTile(title: Text('Нет рецептов')),
                            ...recipes.map(
                              (e) => ListTile(
                                title: RecipeLabelWidget(name: e.name),
                                subtitle:
                                    FutureBuilder<List<RecipeIngredientEntity>>(
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
                                    await ref
                                        .read(productsControllerProvider)
                                        .deleteRecipe(e.id);

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
