import 'package:shapeup/features/photos/domain/usecases/photos_usecase.dart';
import 'package:shapeup/features/photos/domain/entities/progress_photo_entity.dart';


class PhotosController {
  const PhotosController(this._photosUseCase);

  final PhotosUseCase _photosUseCase;

  int get requiredPhotoCount => _photosUseCase.requiredPhotoCount;

  bool dayIsCompleted(Iterable<ProgressPhotoEntity> photos) {
    return _photosUseCase.dayIsCompleted(photos);
  }

  int selectedCount(
    Map<int, String?> selectedPaths, {
    required bool Function(String path) pathExists,
  }) {
    return _photosUseCase.selectedCount(
      selectedPaths,
      pathExists: pathExists,
    );
  }

  bool allPhotosSelected(
    Map<int, String?> selectedPaths, {
    required bool Function(String path) pathExists,
  }) {
    return _photosUseCase.allPhotosSelected(
      selectedPaths,
      pathExists: pathExists,
    );
  }

  Map<int, String> selectedPhotosMap(Map<int, String?> selectedPaths) {
    return _photosUseCase.selectedPhotosMap(selectedPaths);
  }

  Future<List<ProgressPhotoEntity>> photosForDay(String dayKey) {
    return _photosUseCase.photosForDay(dayKey);
  }

  Future<String?> pickJpegPath() {
    return _photosUseCase.pickJpegPath();
  }

  Future<List<ProgressPhotoEntity>> savePhotosForDay({
    required String dayKey,
    required Map<int, String> slotToLocalPath,
  }) {
    return _photosUseCase.savePhotosForDay(
      dayKey: dayKey,
      slotToLocalPath: slotToLocalPath,
    );
  }
}
