import 'package:flutter/material.dart';

import 'package:shapeup/core/shared/enums.dart';
import 'package:shapeup/core/shared/extensions.dart';
import 'package:shapeup/presentation/widgets/dropdown_menu_widget.dart';
import 'package:shapeup/presentation/widgets/dropdown_text_widget.dart';

class ActivityDropdownWidget extends StatelessWidget {
  const ActivityDropdownWidget({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.dropdownColor,
  });

  final ActivityLevel value;
  final ValueChanged<ActivityLevel> onChanged;
  final bool enabled;
  final Color? dropdownColor;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<ActivityLevel>(
      dropdownColor: dropdownColor,
      initialValue: value,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Образ жизни'),
      selectedItemBuilder: (context) {
        return ActivityLevel.values
            .map((e) => DropdownTextWidget(text: e.label))
            .toList();
      },
      items: ActivityLevel.values
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: DropdownMenuWidget(text: e.label),
            ),
          )
          .toList(),
      onChanged: enabled
          ? (value) {
              if (value == null) return;
              onChanged(value);
            }
          : null,
    );
  }
}
