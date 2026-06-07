import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:shapeup/core/shared/errors.dart';
import 'package:shapeup/features/products/domain/usecases/products_usecase.dart';
import 'package:shapeup/features/products/domain/entities/food_entity.dart';

typedef BaseFoodsPagingControllerFactory = BaseFoodsPagingController Function();


class BaseFoodsPagingController extends ChangeNotifier {
  BaseFoodsPagingController({
    required ProductsUseCase productsUseCase,
  }) : _productsUseCase = productsUseCase;

  static const int _foodsPageSize = 150;

  final ProductsUseCase _productsUseCase;

  Timer? _searchDebounce;
  bool _disposed = false;

  TextEditingController? _boundQueryController;
  ScrollController? _boundScrollController;
  VoidCallback? _boundSearchListener;
  VoidCallback? _boundScrollListener;
  VoidCallback? _boundFoodsListener;

  String searchText = '';

  List<FoodEntity> foods = [];
  bool foodsLoading = true;
  bool foodsHasMore = true;
  int foodsOffset = 0;
  String foodsQueryToken = '';
  String? foodsErrorText;

  void bind({
    required TextEditingController queryController,
    ScrollController? scrollController,
    required VoidCallback onFoodsChanged,
    required VoidCallback onSearchAccepted,
    VoidCallback? afterSearchAccepted,
  }) {
    unbind();

    _boundQueryController = queryController;
    _boundScrollController = scrollController;
    _boundFoodsListener = onFoodsChanged;

    _boundSearchListener = () {
      scheduleSearch(
        value: queryController.text,
        onSearchAccepted: onSearchAccepted,
        afterSearchAccepted: () {
          if (scrollController?.hasClients ?? false) {
            scrollController!.jumpTo(0);
          }

          afterSearchAccepted?.call();
        },
      );
    };

    _boundScrollListener = () {
      final controller = _boundScrollController;
      if (controller == null) return;
      onScrollController(controller);
    };

    queryController.addListener(_boundSearchListener!);
    scrollController?.addListener(_boundScrollListener!);
    addListener(_boundFoodsListener!);
  }

  void unbind() {
    final queryController = _boundQueryController;
    final searchListener = _boundSearchListener;
    if (queryController != null && searchListener != null) {
      queryController.removeListener(searchListener);
    }

    final scrollController = _boundScrollController;
    final scrollListener = _boundScrollListener;
    if (scrollController != null && scrollListener != null) {
      scrollController.removeListener(scrollListener);
    }

    final foodsListener = _boundFoodsListener;
    if (foodsListener != null) {
      removeListener(foodsListener);
    }

    _boundQueryController = null;
    _boundScrollController = null;
    _boundSearchListener = null;
    _boundScrollListener = null;
    _boundFoodsListener = null;
  }

  void start() {
    foodsQueryToken = searchText;
    loadFoodsPage(
      query: foodsQueryToken,
      offset: 0,
      replace: true,
      loadingAlreadySet: true,
    );
  }

  void scheduleSearch({
    required String value,
    required VoidCallback onSearchAccepted,
    VoidCallback? afterSearchAccepted,
  }) {
    _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 250), () {
      final next = value.trim();

      if (next == searchText) return;
      if (_disposed) return;

      searchText = next;
      onSearchAccepted();

      foods = [];
      foodsOffset = 0;
      foodsHasMore = true;
      foodsLoading = true;
      foodsErrorText = null;
      foodsQueryToken = next;

      _notify();

      afterSearchAccepted?.call();

      loadFoodsPage(
        query: next,
        offset: 0,
        replace: true,
        loadingAlreadySet: true,
      );
    });
  }

  void onScrollController(ScrollController scrollController) {
    if (!scrollController.hasClients) return;
    if (foodsLoading || !foodsHasMore) return;

    final position = scrollController.position;
    final remaining = position.maxScrollExtent - position.pixels;

    if (remaining < 500) {
      loadNextFoodsPage();
    }
  }

  bool onScrollMetrics(ScrollMetrics metrics) {
    if (metrics.axis != Axis.vertical) return false;
    if (foodsLoading || !foodsHasMore) return false;

    final nearBottom = metrics.extentAfter < 500;

    if (nearBottom) {
      loadNextFoodsPage();
    }

    return false;
  }

  bool onScrollNotification(ScrollNotification notification) {
    return onScrollMetrics(notification.metrics);
  }

  Future<void> loadNextFoodsPage() async {
    if (foodsLoading || !foodsHasMore) return;

    await loadFoodsPage(
      query: foodsQueryToken,
      offset: foodsOffset,
      replace: false,
    );
  }

  Future<void> loadFoodsPage({
    required String query,
    required int offset,
    required bool replace,
    bool loadingAlreadySet = false,
  }) async {
    if (!loadingAlreadySet) {
      if (_disposed) return;

      foodsLoading = true;
      foodsErrorText = null;
      _notify();
    }

    try {
      final loaded = await _productsUseCase.baseFoodsPage(
        query,
        offset: offset,
        limit: _foodsPageSize,
      );

      if (_disposed || query != foodsQueryToken) return;

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
      _notify();
    } catch (e) {
      if (_disposed || query != foodsQueryToken) return;

      foodsLoading = false;
      foodsHasMore = false;
      foodsErrorText = russianErrorMessage(e);
      _notify();
    }
  }

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    unbind();
    _disposed = true;
    super.dispose();
  }
}
