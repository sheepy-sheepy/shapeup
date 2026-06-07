import 'dart:io';

import 'package:flutter/material.dart';
import 'package:shapeup/core/shared/photo_labels.dart';
import 'package:shapeup/features/photos/domain/entities/progress_photo_entity.dart';

class PhotoCompareWidget extends StatelessWidget {
  const PhotoCompareWidget({super.key, 
    required this.startPhotos,
    required this.endPhotos,
    required this.startDay,
    required this.endDay,
  });

  final List<ProgressPhotoEntity> startPhotos;
  final List<ProgressPhotoEntity> endPhotos;
  final String startDay;
  final String endDay;

  Widget _photoCell(BuildContext context, ProgressPhotoEntity? photo) {
    final colors = Theme.of(context).colorScheme;

    final hasPhoto = photo != null &&
        photo.localPath.isNotEmpty &&
        File(photo.localPath).existsSync();

    return AspectRatio(
      aspectRatio: 3 / 4,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.82),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.7),
              ),
            ),
            child: hasPhoto
                ? Image.file(
                    File(photo.localPath),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final startBySlot = {for (final p in startPhotos) p.slot: p};
    final endBySlot = {for (final p in endPhotos) p.slot: p};

    const orderedSlots = [1, 2, 3, 4];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                startDay,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                endDay,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...orderedSlots.map((slot) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                Text(
                  photoSlotLabel(slot),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _photoCell(context, startBySlot[slot])),
                    const SizedBox(width: 12),
                    Expanded(child: _photoCell(context, endBySlot[slot])),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
