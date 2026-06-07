import 'dart:io';
import 'package:drift/drift.dart' as drift;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

import 'package:shapeup/features/auth/domain/repositories/auth_repository.dart' as auth_domain;
import 'package:shapeup/features/photos/domain/repositories/photos_repository.dart' as domain;
import 'package:shapeup/core/shared/errors.dart';
import 'package:shapeup/data/local/database.dart';
import 'package:shapeup/data/local/entity_mappers.dart';
import 'package:shapeup/features/photos/domain/entities/progress_photo_entity.dart';

class PhotosRepositoryImpl implements domain.PhotosRepository {
  PhotosRepositoryImpl(this.db, this.auth, this.photoPicker);

  final AppDatabase db;
  final auth_domain.AuthRepository auth;
  final PhotoPickerAdapter photoPicker;
  final _uuid = const Uuid();

  @override
  Future<String?> pickJpegPath() {
    return photoPicker.pickJpegPath();
  }

  @override
  Future<List<ProgressPhotoEntity>> allPhotos() async {
    final user = auth.currentUser;
    if (user == null) return const [];

    final rows = await (db.select(db.progressPhotos)
          ..where((t) => t.userId.equals(user.id))
          ..orderBy([
            (t) => drift.OrderingTerm.asc(t.dayKey),
            (t) => drift.OrderingTerm.asc(t.slot),
          ]))
        .get();
    return rows.map((row) => row.toEntity()).toList();
  }

  @override
  Future<List<ProgressPhotoEntity>> photosForDay(String dayKey) async {
    final user = auth.currentUser;
    if (user == null) return const [];

    final rows = await (db.select(db.progressPhotos)
          ..where((t) => t.userId.equals(user.id) & t.dayKey.equals(dayKey))
          ..orderBy([
            (t) => drift.OrderingTerm.asc(t.slot),
          ]))
        .get();
    return rows.map((row) => row.toEntity()).toList();
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
      throw ValidationException(photoFileNotFoundMessage(sourcePath));
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
      throw const AppException(unauthorizedMessage);
    }

    if (slotToLocalPath.length != 4) {
      throw const ValidationException(allPhotosRequiredMessage);
    }

    final alreadyCompleted = await hasCompletedPhotosForDay(dayKey);
    if (alreadyCompleted) {
      throw const ValidationException(photosAlreadyAddedTodayMessage);
    }

    for (final slot in [1, 2, 3, 4]) {
      final localPath = slotToLocalPath[slot]?.trim();

      if (localPath == null || localPath.isEmpty) {
        throw ValidationException(photoSlotNotSelectedMessage(slot));
      }

      final file = File(localPath);
      if (!file.existsSync()) {
        throw ValidationException(photoSlotFileNotFoundMessage(slot));
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

class PhotoPickerAdapter {
  PhotoPickerAdapter({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<String?> pickJpegPath() async {
    await _ensurePhotoAccessPermission();

    final XFile? file;
    try {
      file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1800,
        maxHeight: 2400,
        imageQuality: 100,
        requestFullMetadata: false,
      );
    } catch (e) {
      throw ValidationException(
        russianErrorMessage(e, fallback: photoOpenGalleryFailedMessage),
      );
    }

    if (file == null) return null;

    final name = file.name.toLowerCase();
    final path = file.path.toLowerCase();
    final isJpeg = name.endsWith('.jpg') ||
        name.endsWith('.jpeg') ||
        path.endsWith('.jpg') ||
        path.endsWith('.jpeg');

    if (!isJpeg) {
      throw const ValidationException(invalidJpegMessage);
    }

    return file.path;
  }

  Future<void> _ensurePhotoAccessPermission() async {
    if (!Platform.isAndroid && !Platform.isIOS) return;

    if (Platform.isIOS) {
      final status = await _requestIfNeeded(Permission.photos);
      if (_isPhotoPermissionAllowed(status)) return;

      if (status.isPermanentlyDenied || status.isRestricted) {
        await openAppSettings();
        throw const ValidationException(photoAccessSettingsMessage);
      }

      throw const ValidationException(photoAccessDeniedMessage);
    }

    final photosStatus = await _requestIfNeeded(Permission.photos);
    if (_isPhotoPermissionAllowed(photosStatus)) return;

    final storageStatus = await _requestIfNeeded(Permission.storage);
    if (_isPhotoPermissionAllowed(storageStatus)) return;

    if (photosStatus.isPermanentlyDenied ||
        photosStatus.isRestricted ||
        storageStatus.isPermanentlyDenied ||
        storageStatus.isRestricted) {
      await openAppSettings();
      throw const ValidationException(photoAccessSettingsMessage);
    }

    throw const ValidationException(photoAccessDeniedMessage);
  }

  Future<PermissionStatus> _requestIfNeeded(Permission permission) async {
    final status = await permission.status;
    if (_isPhotoPermissionAllowed(status)) return status;

    if (status.isPermanentlyDenied || status.isRestricted) return status;

    return permission.request();
  }

  bool _isPhotoPermissionAllowed(PermissionStatus status) {
    return status.isGranted || status.isLimited;
  }
}
