import 'package:shapeup/features/photos/domain/repositories/photos_repository.dart';
import 'package:shapeup/features/photos/domain/usecases/progress_photos_usecase.dart';


class PhotosUseCase {
  const PhotosUseCase(this._photosRepository);

  final PhotosRepository _photosRepository;

  int get requiredPhotoCount => ProgressPhotosUseCase.requiredPhotoCount;

  bool dayIsCompleted(Iterable<ProgressPhotoEntity> photos) {
    return ProgressPhotosUseCase.dayIsCompleted(photos);
  }

  int selectedCount(
    Map<int, String?> selectedPaths, {
    required bool Function(String path) pathExists,
  }) {
    return ProgressPhotosUseCase.selectedCount(
      selectedPaths,
      pathExists: pathExists,
    );
  }

  bool allPhotosSelected(
    Map<int, String?> selectedPaths, {
    required bool Function(String path) pathExists,
  }) {
    return ProgressPhotosUseCase.allPhotosSelected(
      selectedPaths,
      pathExists: pathExists,
    );
  }

  Map<int, String> selectedPhotosMap(Map<int, String?> selectedPaths) {
    return ProgressPhotosUseCase.selectedPhotosMap(selectedPaths);
  }

  Future<List<ProgressPhotoEntity>> photosForDay(String dayKey) {
    return _photosRepository.photosForDay(dayKey);
  }

  Future<String?> pickJpegPath() {
    return _photosRepository.pickJpegPath();
  }

  Future<List<ProgressPhotoEntity>> savePhotosForDay({
    required String dayKey,
    required Map<int, String> slotToLocalPath,
  }) async {
    await _photosRepository.savePhotosForDay(
      dayKey: dayKey,
      slotToLocalPath: slotToLocalPath,
    );

    return _photosRepository.photosForDay(dayKey);
  }
}
