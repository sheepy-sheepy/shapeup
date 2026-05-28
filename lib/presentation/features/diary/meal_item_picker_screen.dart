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
import '../../controllers/base_foods_paging_controller.dart';
import '../../widgets/products_panel.dart';

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
  final query = TextEditingController();
  final scrollController = ScrollController();
  final Map<String, Future<PickedMealSource>> _recipeSourceFutures = {};

  late final BaseFoodsPagingController foodsController;
  late Future<_MealPickerStaticData> _staticFuture;

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
        _staticFuture = _loadStaticData();
        _recipeSourceFutures.clear();
      },
    );

    _staticFuture = _loadStaticData();
    foodsController.start();
  }

  @override
  void dispose() {
    foodsController.dispose();

    query.dispose();
    scrollController.dispose();

    super.dispose();
  }

  Future<_MealPickerStaticData> _loadStaticData() async {
    final productsRepo = ref.read(productsRepositoryProvider);
    final recipesRepo = ref.read(recipesRepositoryProvider);

    final custom =
        await productsRepo.customProducts(foodsController.searchText);

    final allRecipes = await recipesRepo.recipes('');
    final recipes = RecipeSearchService.filterAndSortBySearch(
      allRecipes,
      foodsController.searchText,
    );

    return _MealPickerStaticData(
      customProducts: custom,
      recipes: recipes,
    );
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
    showAppSnackBar(context, text);
  }

  @override
  Widget build(BuildContext context) {
    final foods = foodsController.foods;
    final foodsLoading = foodsController.foodsLoading;
    final foodsHasMore = foodsController.foodsHasMore;
    final foodsErrorText = foodsController.foodsErrorText;

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
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            staticData == null)
                          const ListTile(
                              title: Text('Загружаем свои продукты...')),
                        if (staticData != null && custom.isEmpty)
                          const ListTile(title: Text('Нет своих продуктов')),
                        ...custom.map(
                          (e) => CustomProductTile(
                            product: e,
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
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
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
                                      recipeCookedWeightMissingMessage);
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
                                _showSnackBar(russianErrorMessage(error));
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
                            title: const Text(baseFoodsLoadErrorTitle),
                            subtitle: Text(foodsErrorText),
                          ),
                        if (foods.isEmpty && !foodsLoading)
                          const ListTile(title: Text(nothingFoundMessage)),
                        ...foods.map(
                          (e) => CsvFoodTile(
                            food: e,
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
