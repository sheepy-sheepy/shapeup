import 'package:flutter/material.dart';

import 'package:shapeup/core/design/theme.dart';
import 'package:shapeup/features/photos/presentation/widgets/editable_photo_cell_widget.dart';
import 'package:shapeup/features/photos/presentation/widgets/error_banner_widget.dart';
import 'package:shapeup/features/photos/presentation/widgets/photo_progress_widget.dart';
import 'package:shapeup/features/photos/presentation/widgets/photos_header_widget.dart';

class AddPhotosWidget extends StatelessWidget {
  const AddPhotosWidget({super.key, 
    required this.dayText,
    required this.loadErrorText,
    required this.selectedPhotoNotifiers,
    required this.slotLabel,
    required this.slotHint,
    required this.slotAsset,
    required this.onPickForSlot,
    required this.allPhotosSelected,
    required this.onSave,
    required this.requiredPhotoCount,
    required this.selectedCount,
  });

  final String dayText;
  final String? loadErrorText;
  final Map<int, ValueNotifier<String?>> selectedPhotoNotifiers;
  final String Function(int slot) slotLabel;
  final String Function(int slot) slotHint;
  final String Function(int slot) slotAsset;
  final Future<void> Function(int slot) onPickForSlot;
  final bool Function() allPhotosSelected;
  final Future<void> Function() onSave;
  final int requiredPhotoCount;
  final int Function() selectedCount;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge(selectedPhotoNotifiers.values.toList()),
      builder: (context, _) {
        final selected = selectedCount();
        final canSave = allPhotosSelected();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PhotosHeaderWidget(
                title: 'Фото прогресса за сегодня',
                subtitle: dayText,
                icon: Icons.photo_camera_outlined),
            const SizedBox(height: AppSpacing.md),
            PhotoProgressWidget(
              selectedCount: selected,
              requiredCount: requiredPhotoCount,
            ),
            if (loadErrorText != null) ...[
              const SizedBox(height: AppSpacing.md),
              ErrorBannerWidget(text: loadErrorText!),
            ],
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

                  return EditablePhotoCellWidget(
                    slot: slot,
                    label: slotLabel(slot),
                    hint: slotHint(slot),
                    assetPath: slotAsset(slot),
                    pathNotifier: selectedPhotoNotifiers[slot]!,
                    onTap: () => onPickForSlot(slot),
                  );
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            AnimatedScale(
              duration: const Duration(milliseconds: 180),
              scale: canSave ? 1.0 : 0.98,
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: canSave ? onSave : null,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Сохранить фото'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
