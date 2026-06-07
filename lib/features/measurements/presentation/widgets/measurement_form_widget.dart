import 'package:flutter/material.dart';

import 'package:shapeup/core/design/theme.dart';
import 'package:shapeup/features/measurements/presentation/widgets/body_fat_preview_widget.dart';
import 'package:shapeup/features/measurements/presentation/widgets/body_field_widget.dart';

class MeasurementFormWidget extends StatelessWidget {
  const MeasurementFormWidget({super.key, 
    required this.formKey,
    required this.weight,
    required this.neck,
    required this.waist,
    required this.hips,
    required this.bodyFatPreview,
    required this.canSave,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController weight;
  final TextEditingController neck;
  final TextEditingController waist;
  final TextEditingController hips;
  final double? bodyFatPreview;
  final bool canSave;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Новый замер',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  BodyFieldWidget(
                    controller: weight,
                    label: 'Вес',
                    suffix: 'кг',
                    icon: Icons.accessibility_new_outlined,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  BodyFieldWidget(
                    controller: neck,
                    label: 'Шея',
                    suffix: 'см',
                    icon: Icons.straighten_outlined,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  BodyFieldWidget(
                    controller: waist,
                    label: 'Талия',
                    suffix: 'см',
                    icon: Icons.straighten_outlined,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  BodyFieldWidget(
                    controller: hips,
                    label: 'Бедра',
                    suffix: 'см',
                    icon: Icons.straighten_outlined,
                  ),
                ],
              ),
            ),
          ),
          if (bodyFatPreview != null) ...[
            const SizedBox(height: AppSpacing.lg),
            BodyFatPreviewWidget(value: bodyFatPreview!),
          ],
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: canSave ? onSave : null,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Сохранить параметры'),
            ),
          ),
        ],
      ),
    );
  }
}
