import 'package:shapeup/features/home/domain/repositories/home_repository.dart';


class HomeNavigationUseCase {
  const HomeNavigationUseCase(this._homeRepository);

  final HomeRepository _homeRepository;

  int get initialIndex => _homeRepository.initialIndex;
  int get totalPages => _homeRepository.totalPages;

  bool canSelectPage({
    required int currentIndex,
    required int selectedIndex,
  }) {
    return _homeRepository.canSelectPage(
      currentIndex: currentIndex,
      selectedIndex: selectedIndex,
    );
  }

  Set<int> visitedPagesAfterSelect({
    required Set<int> visitedPages,
    required int selectedIndex,
  }) {
    return _homeRepository.visitedPagesAfterSelect(
      visitedPages: visitedPages,
      selectedIndex: selectedIndex,
    );
  }
}
