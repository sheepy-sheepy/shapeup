import 'package:flutter/material.dart';

import 'package:shapeup/core/design/theme.dart';
import 'package:shapeup/features/photos/presentation/widgets/photos_header_widget.dart';
import 'package:shapeup/features/photos/presentation/widgets/saved_photo_cell_widget.dart';
import 'package:shapeup/features/photos/domain/entities/progress_photo_entity.dart';

class SavedPhotosWidget extends StatelessWidget {
  const SavedPhotosWidget({super.key, 
    required this.photos,
    required this.dayText,
    required this.slotLabel,
    required this.requiredPhotoCount,
  });

  final List<ProgressPhotoEntity> photos;
  final String dayText;
  final String Function(int slot) slotLabel;
  final int requiredPhotoCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PhotosHeaderWidget(
          title: 'Фото за сегодня сохранены',
          subtitle: dayText,
          icon: Icons.check_circle_outline,
        ),
        const SizedBox(height: AppSpacing.lg),
        Expanded(
          child: GridView.builder(
            itemCount: requiredPhotoCount,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.md,
              mainAxisSpacing: AppSpacing.md,
              childAspectRatio: 3 / 4,
            ),
            itemBuilder: (context, index) {
              final slot = index + 1;
              final photo = photos.firstWhere(
                (e) => e.slot == slot,
              );

              return SavedPhotoCellWidget(
                slot: slot,
                label: slotLabel(slot),
                localPath: photo.localPath,
              );
            },
          ),
        ),
      ],
    );
  }
}
