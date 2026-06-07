import 'package:flutter/material.dart';

import 'package:shapeup/core/shared/validators.dart';

class BodyFieldWidget extends StatelessWidget {
  const BodyFieldWidget({super.key, 
    required this.controller,
    required this.label,
    required this.suffix,
    required this.icon,
  });

  final TextEditingController controller;
  final String label;
  final String suffix;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixText: suffix,
      ),
      validator: Validators.positiveNumber,
    );
  }
}
