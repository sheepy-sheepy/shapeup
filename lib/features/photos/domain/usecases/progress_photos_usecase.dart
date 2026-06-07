import 'package:shapeup/features/photos/domain/entities/progress_photo_entity.dart';
class ProgressPhotosUseCase {
  const ProgressPhotosUseCase._();

  static const int requiredPhotoCount = 4;

  static bool dayIsCompleted(Iterable<ProgressPhotoEntity> photos) {
    return photos.map((photo) => photo.slot).toSet().length ==
        requiredPhotoCount;
  }

  static int selectedCount(
    Map<int, String?> selectedPaths, {
    required bool Function(String path) pathExists,
  }) {
    var count = 0;

    for (final path in selectedPaths.values) {
      if (path != null && path.isNotEmpty && pathExists(path)) {
        count++;
      }
    }

    return count;
  }

  static bool allPhotosSelected(
    Map<int, String?> selectedPaths, {
    required bool Function(String path) pathExists,
  }) {
    return selectedCount(selectedPaths, pathExists: pathExists) ==
        requiredPhotoCount;
  }

  static Map<int, String> selectedPhotosMap(Map<int, String?> selectedPaths) {
    return {
      for (final entry in selectedPaths.entries)
        if (entry.value != null) entry.key: entry.value!,
    };
  }
}
