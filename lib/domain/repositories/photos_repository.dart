import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../entities/local_entities.dart';

export '../entities/local_entities.dart' show ProgressPhoto;

final photosRepositoryProvider = Provider<PhotosRepository>((ref) {
  throw UnimplementedError('PhotosRepository должен быть подключен в data-слое');
});

abstract class PhotosRepository {
  Future<XFile?> pickJpeg();
  Future<List<ProgressPhoto>> allPhotos();
  Future<List<ProgressPhoto>> photosForDay(String dayKey);
  Future<bool> hasCompletedPhotosForDay(String dayKey);
  Future<void> savePhotosForDay({
    required String dayKey,
    required Map<int, String> slotToLocalPath,
  });
}
