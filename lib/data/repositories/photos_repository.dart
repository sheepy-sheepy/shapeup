import 'dart:io';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../domain/repositories/auth_repository.dart' as auth_domain;
import '../../domain/repositories/photos_repository.dart' as domain;
import '../../core/app_errors.dart';
import '../local/app_database.dart';
import '../services/photo_picker_service.dart';

final photosRepositoryProvider = Provider<domain.PhotosRepository>((ref) {
  return PhotosRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(auth_domain.authRepositoryProvider),
    ref.watch(photoPickerServiceProvider),
  );
});

class PhotosRepository implements domain.PhotosRepository {
  PhotosRepository(this.db, this.auth, this.photoPicker);

  final AppDatabase db;
  final auth_domain.AuthRepository auth;
  final PhotoPickerService photoPicker;
  final _uuid = const Uuid();

  @override
  Future<XFile?> pickJpeg() {
    return photoPicker.pickJpeg();
  }

  @override
  Future<List<ProgressPhoto>> allPhotos() async {
    final user = auth.currentUser;
    if (user == null) return const [];

    return (db.select(db.progressPhotos)
          ..where((t) => t.userId.equals(user.id))
          ..orderBy([
            (t) => drift.OrderingTerm.asc(t.dayKey),
            (t) => drift.OrderingTerm.asc(t.slot),
          ]))
        .get();
  }

  @override
  Future<List<ProgressPhoto>> photosForDay(String dayKey) async {
    final user = auth.currentUser;
    if (user == null) return const [];

    return (db.select(db.progressPhotos)
          ..where((t) => t.userId.equals(user.id) & t.dayKey.equals(dayKey))
          ..orderBy([
            (t) => drift.OrderingTerm.asc(t.slot),
          ]))
        .get();
  }

  @override
  Future<bool> hasCompletedPhotosForDay(String dayKey) async {
    final items = await photosForDay(dayKey);
    final slots = items.map((e) => e.slot).toSet();

    return slots.length == 4;
  }

  Future<Directory> _photosDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final photosDir = Directory(p.join(appDir.path, 'progress_photos'));

    if (!photosDir.existsSync()) {
      photosDir.createSync(recursive: true);
    }

    return photosDir;
  }

  Future<String> _copyPhotoToPermanentStorage({
    required String userId,
    required String dayKey,
    required int slot,
    required String sourcePath,
  }) async {
    final sourceFile = File(sourcePath);

    if (!sourceFile.existsSync()) {
      throw ValidationException('Файл фото не найден: $sourcePath');
    }

    final photosDir = await _photosDirectory();

    final targetPath = p.join(
      photosDir.path,
      '${userId}_${dayKey}_$slot.jpg',
    );

    try {
      final copied = await sourceFile.copy(targetPath);
      return copied.path;
    } on FileSystemException {
      final bytes = await sourceFile.readAsBytes();
      await File(targetPath).writeAsBytes(bytes);
      return targetPath;
    }
  }

  @override
  Future<void> savePhotosForDay({
    required String dayKey,
    required Map<int, String> slotToLocalPath,
  }) async {
    final user = auth.currentUser;
    if (user == null) {
      throw Exception('Пользователь не авторизован');
    }

    if (slotToLocalPath.length != 4) {
      throw const ValidationException('Нужно добавить все 4 фото');
    }

    final alreadyCompleted = await hasCompletedPhotosForDay(dayKey);
    if (alreadyCompleted) {
      throw const ValidationException('Фото за текущий день уже добавлены');
    }

    for (final slot in [1, 2, 3, 4]) {
      final localPath = slotToLocalPath[slot]?.trim();

      if (localPath == null || localPath.isEmpty) {
        throw ValidationException('Не выбрано фото $slot');
      }

      final file = File(localPath);
      if (!file.existsSync()) {
        throw ValidationException('Файл фото $slot не найден');
      }
    }

    final permanentPaths = <int, String>{};

    for (final slot in [1, 2, 3, 4]) {
      final sourcePath = slotToLocalPath[slot]!.trim();

      final permanentPath = await _copyPhotoToPermanentStorage(
        userId: user.id,
        dayKey: dayKey,
        slot: slot,
        sourcePath: sourcePath,
      );

      permanentPaths[slot] = permanentPath;
    }

    await db.transaction(() async {
      for (final slot in [1, 2, 3, 4]) {
        final permanentPath = permanentPaths[slot]!;

        final existing = await (db.select(db.progressPhotos)
              ..where(
                (t) =>
                    t.userId.equals(user.id) &
                    t.dayKey.equals(dayKey) &
                    t.slot.equals(slot),
              ))
            .get();

        final photoId = existing.isNotEmpty ? existing.first.id : _uuid.v4();

        if (existing.isNotEmpty) {
          final keep = existing.first;

          await (db.update(db.progressPhotos)
                ..where((t) => t.id.equals(keep.id)))
              .write(
            ProgressPhotosCompanion(
              localPath: drift.Value(permanentPath),
            ),
          );

          for (final duplicate in existing.skip(1)) {
            await (db.delete(db.progressPhotos)
                  ..where((t) => t.id.equals(duplicate.id)))
                .go();
          }
        } else {
          await db.into(db.progressPhotos).insert(
                ProgressPhotosCompanion.insert(
                  id: photoId,
                  userId: user.id,
                  dayKey: dayKey,
                  slot: slot,
                  localPath: permanentPath,
                ),
              );
        }
      }
    });
  }
}
