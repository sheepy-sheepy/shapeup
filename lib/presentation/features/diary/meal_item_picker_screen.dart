import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/extensions.dart';
import '../../../core/app_ui.dart';
import '../../../domain/entities/local_entities.dart';
import '../../../domain/repositories/products_repository.dart';
import '../../../domain/repositories/recipes_repository.dart';
import '../../../domain/usecases/recipe_nutrition_usecase.dart';
import '../../widgets/csv_products_panel.dart';

class PickedMealSource {
  final String id;
  final String sourceType;
  final String name;
  final double calories;
  final double proteins;
  final double fats;
  final double carbs;

  const PickedMealSource({
    required this.id,
    required this.sourceType,
    required this.name,
    required this.calories,
    required this.proteins,
    required this.fats,
    required this.carbs,
  });
}

class MealItemPickerScreen extends ConsumerStatefulWidget {
  const MealItemPickerScreen({super.key});

  @override
  ConsumerState<MealItemPickerScreen> createState() =>
      _MealItemPickerScreenState();
}

class _MealItemPickerScreenState extends ConsumerState<MealItemPickerScreen> {
  static const int _foodsPageSize = 150;

  final query = TextEditingController();
  final scrollController = ScrollController();
  final Map<String, Future<PickedMealSource>> _recipeSourceFutures = {};

  Timer? _searchDebounce;
  String _searchText = '';

  late Future<_MealPickerStaticData> _staticFuture;

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

    _staticFuture = _loadStaticData();

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

  Future<_MealPickerStaticData> _loadStaticData() async {
    final productsRepo = ref.read(productsRepositoryProvider);
    final recipesRepo = ref.read(recipesRepositoryProvider);

    final custom = await productsRepo.customProducts(_searchText);

    final allRecipes = await recipesRepo.recipes('');
    final recipes = _filterAndSortRecipesBySearch(allRecipes, _searchText);

    return _MealPickerStaticData(
      customProducts: custom,
      recipes: recipes,
    );
  }

  void _onSearchChanged() {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      final next = query.text.trim();

      if (next == _searchText) return;
      if (!mounted) return;

      setState(() {
        _searchText = next;
        _staticFuture = _loadStaticData();
        _recipeSourceFutures.clear();

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

  Future<PickedMealSource> _recipeToPickedSource(Recipe recipe) async {
    final ingredients =
        await ref.read(recipesRepositoryProvider).ingredients(recipe.id);
    final per100 = RecipeNutritionUseCase.per100ForRecipe(
      recipe: recipe,
      ingredients: ingredients,
    );

    return PickedMealSource(
      id: recipe.id,
      sourceType: 'recipe',
      name: recipe.name,
      calories: per100.calories,
      proteins: per100.proteins,
      fats: per100.fats,
      carbs: per100.carbs,
    );
  }

  Future<PickedMealSource> _recipeSourceFuture(Recipe recipe) {
    return _recipeSourceFutures.putIfAbsent(
      recipe.id,
      () => _recipeToPickedSource(recipe),
    );
  }

  void _popPickedSource(PickedMealSource source) {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.pop(context, source);
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить в прием пищи'),
        actions: const [
          ScreenHelpAction(
            title: 'Добавление в приём пищи',
            message: 'Найдите продукт или рецепт через поиск.\n\n'
                'Сначала отображаются ваши продукты и рецепты, затем продукты из встроенной базы.\n\n'
                'Выберите нужный элемент, укажите количество граммов больше 0 и добавьте его в приём пищи.',
          ),
        ],
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
            child: FutureBuilder<_MealPickerStaticData>(
              future: _staticFuture,
              builder: (context, snapshot) {
                final staticData = snapshot.data;
                final custom =
                    staticData?.customProducts ?? const <CustomProduct>[];
                final recipes = staticData?.recipes ?? const <Recipe>[];

                return ListView(
                  controller: scrollController,
                  children: [
                    CustomProductsPanel(
                      children: [
                        if (snapshot.connectionState == ConnectionState.waiting &&
                            staticData == null)
                          const ListTile(title: Text('Загружаем свои продукты...')),
                        if (staticData != null && custom.isEmpty)
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
                            onTap: () {
                              _popPickedSource(
                                PickedMealSource(
                                  id: e.id,
                                  sourceType: 'custom_product',
                                  name: e.name,
                                  calories: e.calories,
                                  proteins: e.proteins,
                                  fats: e.fats,
                                  carbs: e.carbs,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    CustomRecipesPanel(
                      children: [
                        if (snapshot.connectionState == ConnectionState.waiting &&
                            staticData == null)
                          const ListTile(title: Text('Загружаем рецепты...')),
                        if (staticData != null && recipes.isEmpty)
                          const ListTile(title: Text('Нет рецептов')),
                        ...recipes.map(
                          (e) => ListTile(
                            title: CustomRecipeNameLabel(name: e.name),
                            subtitle: FutureBuilder<PickedMealSource>(
                              future: _recipeSourceFuture(e),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return const Text(
                                    'Не указан итоговый вес готового блюда',
                                  );
                                }

                                if (!snapshot.hasData) {
                                  return const Text('Загрузка КБЖУ...');
                                }

                                final recipe = snapshot.data!;

                                return Text(
                                  kbzhuPer100Text(
                                    calories: recipe.calories,
                                    proteins: recipe.proteins,
                                    fats: recipe.fats,
                                    carbs: recipe.carbs,
                                  ),
                                );
                              },
                            ),
                            onTap: () async {
                              try {
                                final picked = await _recipeSourceFuture(e);

                                if (!mounted) return;
                                _popPickedSource(picked);
                              } catch (error) {
                                if (!mounted) return;
                                _showSnackBar(error.toString());
                              }
                            },
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
                            onTap: () {
                              _popPickedSource(
                                PickedMealSource(
                                  id: e.id,
                                  sourceType: 'food',
                                  name: e.name,
                                  calories: e.calories,
                                  proteins: e.proteins,
                                  fats: e.fats,
                                  carbs: e.carbs,
                                ),
                              );
                            },
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

class _MealPickerStaticData {
  const _MealPickerStaticData({
    required this.customProducts,
    required this.recipes,
  });

  final List<CustomProduct> customProducts;
  final List<Recipe> recipes;
}
