import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shapeup/core/shared/errors.dart';
import 'package:shapeup/core/shared/extensions.dart';
import 'package:shapeup/core/design/ui.dart';
import 'package:shapeup/features/products/presentation/controllers/base_foods_paging_controller.dart';
import 'package:shapeup/features/products/presentation/widgets/base_food_tile_widget.dart';
import 'package:shapeup/features/products/presentation/widgets/base_foods_panel_widget.dart';
import 'package:shapeup/features/products/presentation/widgets/product_tile_widget.dart';
import 'package:shapeup/features/products/presentation/widgets/products_panel_widget.dart';
import 'package:shapeup/features/products/presentation/widgets/recipe_label_widget.dart';
import 'package:shapeup/features/products/presentation/widgets/recipes_panel_widget.dart';

import 'package:shapeup/features/diary/domain/entities/meal_picker_data_entity.dart';
import 'package:shapeup/features/diary/domain/entities/picked_meal_source_entity.dart';
import 'package:shapeup/features/products/domain/entities/custom_product_entity.dart';
import 'package:shapeup/features/products/domain/entities/recipe_entity.dart';
import 'package:shapeup/features/products/providers/products_provider.dart';

class MealItemPickerScreen extends ConsumerStatefulWidget {
  const MealItemPickerScreen({super.key});

  @override
  ConsumerState<MealItemPickerScreen> createState() =>
      _MealItemPickerScreenState();
}

class _MealItemPickerScreenState extends ConsumerState<MealItemPickerScreen> {
  final query = TextEditingController();
  final scrollController = ScrollController();
  final Map<String, Future<PickedMealSourceEntity>> _recipeSourceFutures = {};

  late final BaseFoodsPagingController foodsController;
  late Future<MealPickerDataEntity> _staticFuture;

  @override
  void initState() {
    super.initState();

    foodsController = ref.read(baseFoodsPagingControllerFactoryProvider)();

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

  Future<MealPickerDataEntity> _loadStaticData() async {
    final productsController = ref.read(productsControllerProvider);

    final custom =
        await productsController.customProducts(foodsController.searchText);

    final recipes = await productsController.recipes(
      foodsController.searchText,
    );

    return MealPickerDataEntity(
      customProducts: custom,
      recipes: recipes,
    );
  }

  Future<PickedMealSourceEntity> _recipeToPickedSource(RecipeEntity recipe) async {
    final per100 = await ref.read(productsControllerProvider).recipePer100(recipe);

    return PickedMealSourceEntity(
      id: recipe.id,
      sourceType: 'recipe',
      name: recipe.name,
      calories: per100.calories,
      proteins: per100.proteins,
      fats: per100.fats,
      carbs: per100.carbs,
    );
  }

  Future<PickedMealSourceEntity> _recipeSourceFuture(RecipeEntity recipe) {
    return _recipeSourceFutures.putIfAbsent(
      recipe.id,
      () => _recipeToPickedSource(recipe),
    );
  }

  void _popPickedSource(PickedMealSourceEntity source) {
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
            title: 'Добавление в прием пищи',
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
            child: FutureBuilder<MealPickerDataEntity>(
              future: _staticFuture,
              builder: (context, snapshot) {
                final staticData = snapshot.data;
                final custom =
                    staticData?.customProducts ?? const <CustomProductEntity>[];
                final recipes = staticData?.recipes ?? const <RecipeEntity>[];

                return ListView(
                  controller: scrollController,
                  children: [
                    ProductsPanelWidget(
                      children: [
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            staticData == null)
                          const ListTile(
                              title: Text('Загружаем свои продукты...')),
                        if (staticData != null && custom.isEmpty)
                          const ListTile(title: Text('Нет своих продуктов')),
                        ...custom.map(
                          (e) => ProductTileWidget(
                            product: e,
                            onTap: () {
                              _popPickedSource(
                                PickedMealSourceEntity(
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
                    RecipesPanelWidget(
                      children: [
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            staticData == null)
                          const ListTile(title: Text('Загружаем рецепты...')),
                        if (staticData != null && recipes.isEmpty)
                          const ListTile(title: Text('Нет рецептов')),
                        ...recipes.map(
                          (e) => ListTile(
                            title: RecipeLabelWidget(name: e.name),
                            subtitle: FutureBuilder<PickedMealSourceEntity>(
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
                    BaseFoodsPanelWidget(
                      children: [
                        if (foodsErrorText != null)
                          ListTile(
                            title: const Text(baseFoodsLoadErrorTitle),
                            subtitle: Text(foodsErrorText),
                          ),
                        if (foods.isEmpty && !foodsLoading)
                          const ListTile(title: Text(nothingFoundMessage)),
                        ...foods.map(
                          (e) => BaseFoodTileWidget(
                            food: e,
                            onTap: () {
                              _popPickedSource(
                                PickedMealSourceEntity(
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
