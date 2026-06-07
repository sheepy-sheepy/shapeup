
import 'package:shapeup/features/home/domain/repositories/home_repository.dart' as domain;

class HomeRepositoryImpl implements domain.HomeRepository {
  const HomeRepositoryImpl();

  @override
  int get initialIndex => 0;

  @override
  int get totalPages => 6;

  @override
  bool canSelectPage({
    required int currentIndex,
    required int selectedIndex,
  }) {
    return selectedIndex != currentIndex &&
        selectedIndex >= 0 &&
        selectedIndex < totalPages;
  }

  @override
  Set<int> visitedPagesAfterSelect({
    required Set<int> visitedPages,
    required int selectedIndex,
  }) {
    return {...visitedPages, selectedIndex};
  }
}
