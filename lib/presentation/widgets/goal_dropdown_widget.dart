import 'package:flutter/material.dart';

import 'package:shapeup/core/shared/enums.dart';
import 'package:shapeup/core/shared/extensions.dart';
import 'package:shapeup/presentation/widgets/dropdown_menu_widget.dart';
import 'package:shapeup/presentation/widgets/dropdown_text_widget.dart';

class GoalDropdownWidget extends StatelessWidget {
  const GoalDropdownWidget({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.dropdownColor,
  });

  final Goal value;
  final ValueChanged<Goal> onChanged;
  final bool enabled;
  final Color? dropdownColor;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Goal>(
      dropdownColor: dropdownColor,
      initialValue: value,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Цель'),
      selectedItemBuilder: (context) {
        return Goal.values.map((e) => DropdownTextWidget(text: e.label)).toList();
      },
      items: Goal.values
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
