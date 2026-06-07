import 'dart:io';

import 'package:flutter/material.dart';

import 'package:shapeup/features/photos/presentation/widgets/photo_slot_frame_widget.dart';

class SavedPhotoCellWidget extends StatelessWidget {
  const SavedPhotoCellWidget({super.key, 
    required this.slot,
    required this.label,
    required this.localPath,
  });

  final int slot;
  final String label;
  final String localPath;

  @override
  Widget build(BuildContext context) {
    final file = File(localPath);

    return PhotoSlotFrameWidget(
      slot: slot,
      label: label,
      completed: file.existsSync(),
      child: file.existsSync()
          ? Image.file(
              file,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            )
          : Center(child: Text('Фото $slot')),
    );
  }
}
