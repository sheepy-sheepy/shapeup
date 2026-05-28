import 'package:flutter/material.dart';

import 'app_errors.dart';

class Validators {
  static String? requiredText(String? value) {
    if (value == null || value.trim().isEmpty) return requiredFieldMessage;
    return null;
  }

  static String? positiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) return requiredFieldMessage;
    final d = double.tryParse(value.replaceAll(',', '.'));
    if (d == null) return enterNumberMessage;
    if (d <= 0) return positiveValueMessage;
    return null;
  }

  static String? nonNegativeNumber(String? value) {
    if (value == null || value.trim().isEmpty) return requiredFieldMessage;
    final d = double.tryParse(value.replaceAll(',', '.'));
    if (d == null) return enterNumberMessage;
    if (d < 0) return nonNegativeValueMessage;
    return null;
  }
}

void showAppSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
}

class ScreenHelpAction extends StatelessWidget {
  const ScreenHelpAction({
    super.key,
    required this.title,
    required this.message,
  });

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Подсказка',
      icon: const Icon(Icons.help_outline),
      onPressed: () => showScreenHelpDialog(
        context,
        title: title,
        message: message,
      ),
    );
  }
}

Future<void> showScreenHelpDialog(
  BuildContext context, {
  required String title,
  required String message,
}) {
  final colorScheme = Theme.of(context).colorScheme;

  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        icon: Icon(Icons.tips_and_updates_outlined, color: colorScheme.primary),
        title: Text(title),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: SingleChildScrollView(
            child: Text(message, style: const TextStyle(height: 1.35)),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Понятно'),
          ),
        ],
      );
    },
  );
}
