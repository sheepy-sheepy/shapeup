import 'package:shapeup/features/photos/domain/entities/progress_photo_entity.dart';

export 'package:shapeup/features/photos/domain/entities/progress_photo_entity.dart' show ProgressPhotoEntity;


abstract class PhotosRepository {
  Future<String?> pickJpegPath();
  Future<List<ProgressPhotoEntity>> allPhotos();
  Future<List<ProgressPhotoEntity>> photosForDay(String dayKey);
  Future<bool> hasCompletedPhotosForDay(String dayKey);
  Future<void> savePhotosForDay({
    required String dayKey,
    required Map<int, String> slotToLocalPath,
  });
}
