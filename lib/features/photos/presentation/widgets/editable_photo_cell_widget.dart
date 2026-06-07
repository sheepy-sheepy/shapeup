import 'dart:io';

import 'package:flutter/material.dart';

import 'package:shapeup/core/design/theme.dart';
import 'package:shapeup/features/photos/presentation/widgets/empty_photo_widget.dart';
import 'package:shapeup/features/photos/presentation/widgets/photo_check_badge_widget.dart';
import 'package:shapeup/features/photos/presentation/widgets/photo_slot_frame_widget.dart';

class EditablePhotoCellWidget extends StatelessWidget {
  const EditablePhotoCellWidget({super.key, 
    required this.slot,
    required this.label,
    required this.hint,
    required this.assetPath,
    required this.pathNotifier,
    required this.onTap,
  });

  final int slot;
  final String label;
  final String hint;
  final String assetPath;
  final ValueNotifier<String?> pathNotifier;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: pathNotifier,
      builder: (context, path, _) {
        final file = path == null ? null : File(path);
        final hasPhoto = file != null && file.existsSync();

        return AnimatedScale(
          duration: const Duration(milliseconds: 180),
          scale: hasPhoto ? 1.0 : 0.985,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: PhotoSlotFrameWidget(
              slot: slot,
              label: label,
              completed: hasPhoto,
              child: hasPhoto
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          file,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        const Positioned(
                          right: AppSpacing.sm,
                          top: AppSpacing.sm,
                          child: PhotoCheckBadgeWidget(),
                        ),
                      ],
                    )
                  : EmptyPhotoWidget(
                      label: label,
                      hint: hint,
                      assetPath: assetPath,
                    ),
            ),
          ),
        );
      },
    );
  }
}
