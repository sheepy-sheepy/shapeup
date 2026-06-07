


abstract class HomeRepository {
  int get initialIndex;
  int get totalPages;

  bool canSelectPage({
    required int currentIndex,
    required int selectedIndex,
  });

  Set<int> visitedPagesAfterSelect({
    required Set<int> visitedPages,
    required int selectedIndex,
  });
}
