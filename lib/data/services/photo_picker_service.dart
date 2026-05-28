import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/app_errors.dart';

final photoPickerServiceProvider = Provider<PhotoPickerService>((ref) {
  return PhotoPickerService();
});

class PhotoPickerService {
  PhotoPickerService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  Future<XFile?> pickJpeg() async {
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
          russianErrorMessage(e, fallback: photoOpenGalleryFailedMessage));
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

    return file;
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
