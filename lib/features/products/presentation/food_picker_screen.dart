import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shapeup/core/shared/errors.dart';
import 'package:shapeup/features/products/presentation/controllers/base_foods_paging_controller.dart';
import 'package:shapeup/features/products/presentation/widgets/base_food_tile_widget.dart';
import 'package:shapeup/features/products/presentation/widgets/base_foods_panel_widget.dart';
import 'package:shapeup/features/products/presentation/widgets/product_tile_widget.dart';
import 'package:shapeup/features/products/presentation/widgets/products_panel_widget.dart';

import 'package:shapeup/features/products/domain/entities/picked_food_entity.dart';
import 'package:shapeup/features/products/domain/entities/custom_product_entity.dart';
import 'package:shapeup/features/products/domain/entities/food_entity.dart';
import 'package:shapeup/features/products/providers/products_provider.dart';

class FoodPickerScreen extends ConsumerStatefulWidget {
  const FoodPickerScreen({super.key});

  @override
  ConsumerState<FoodPickerScreen> createState() => _FoodPickerScreenState();
}

class _FoodPickerScreenState extends ConsumerState<FoodPickerScreen> {
  final query = TextEditingController();
  final scrollController = ScrollController();

  late final BaseFoodsPagingController foodsController;
  late Future<List<CustomProductEntity>> _customFuture;

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

  Future<List<CustomProductEntity>> _loadCustomProducts() {
    return ref
        .read(productsControllerProvider)
        .customProducts(foodsController.searchText);
  }

  void _popCustomProduct(CustomProductEntity product) {
    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.pop(
      context,
      PickedFoodEntity(
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

  void _popFood(FoodEntity food) {
    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.pop(
      context,
      PickedFoodEntity(
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
            child: FutureBuilder<List<CustomProductEntity>>(
              future: _customFuture,
              builder: (context, snapshot) {
                final custom = snapshot.data ?? const <CustomProductEntity>[];

                return ListView(
                  controller: scrollController,
                  children: [
                    ProductsPanelWidget(
                      children: [
                        if (snapshot.connectionState ==
                                ConnectionState.waiting &&
                            !snapshot.hasData)
                          const ListTile(
                              title: Text('Загружаем свои продукты...')),
                        if (snapshot.hasData && custom.isEmpty)
                          const ListTile(title: Text('Нет своих продуктов')),
                        ...custom.map(
                          (e) => ProductTileWidget(
                            product: e,
                            onTap: () => _popCustomProduct(e),
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
