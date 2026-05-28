import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../entities/local_entities.dart';
import '../../core/app_errors.dart';

export '../entities/local_entities.dart' show ProgressPhoto;

final photosRepositoryProvider = Provider<PhotosRepository>((ref) {
  throw UnimplementedError(photosRepositoryNotConnectedMessage);
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
