import 'package:flutter/material.dart';
import '../../core/design.dart';
import '../../core/enums.dart';
import '../../core/extensions.dart';

Widget _selectedDropdownText(String text) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );
}

Widget _dropdownMenuText(String text) {
  return Text(
    text,
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  );
}

class ProfileSexDropdown extends StatelessWidget {
  const ProfileSexDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.dropdownColor,
  });

  final Sex value;
  final ValueChanged<Sex> onChanged;
  final bool enabled;
  final Color? dropdownColor;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Sex>(
      dropdownColor: dropdownColor,
      initialValue: value,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Пол'),
      selectedItemBuilder: (context) {
        return Sex.values.map((e) => _selectedDropdownText(e.label)).toList();
      },
      items: Sex.values
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: _dropdownMenuText(e.label),
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

class ProfileGoalDropdown extends StatelessWidget {
  const ProfileGoalDropdown({
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
        return Goal.values.map((e) => _selectedDropdownText(e.label)).toList();
      },
      items: Goal.values
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: _dropdownMenuText(e.label),
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

class ProfileActivityDropdown extends StatelessWidget {
  const ProfileActivityDropdown({
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
            .map((e) => _selectedDropdownText(e.label))
            .toList();
      },
      items: ActivityLevel.values
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: _dropdownMenuText(e.label),
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

List<Widget> withProfileFieldSpacing(List<Widget> children) {
  return [
    for (var i = 0; i < children.length; i++) ...[
      children[i],
      if (i != children.length - 1) const SizedBox(height: AppSpacing.md),
    ],
  ];
}
