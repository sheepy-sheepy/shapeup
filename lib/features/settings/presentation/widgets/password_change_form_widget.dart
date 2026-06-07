import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shapeup/core/design/ui.dart';
import 'package:shapeup/core/shared/errors.dart';
import 'package:shapeup/core/design/theme.dart';
import 'package:shapeup/features/settings/providers/settings_provider.dart';

class PasswordChangeFormWidget extends ConsumerStatefulWidget {
  const PasswordChangeFormWidget({super.key});

  @override
  ConsumerState<PasswordChangeFormWidget> createState() => _PasswordChangeFormState();
}

class _PasswordChangeFormState extends ConsumerState<PasswordChangeFormWidget> {
  final oldPassword = TextEditingController();
  final newPassword = TextEditingController();

  bool loading = false;

  @override
  void initState() {
    super.initState();

    oldPassword.addListener(_onFormChanged);
    newPassword.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    oldPassword.removeListener(_onFormChanged);
    newPassword.removeListener(_onFormChanged);

    oldPassword.dispose();
    newPassword.dispose();

    super.dispose();
  }

  void _onFormChanged() {
    if (!mounted) return;
    setState(() {});
  }

  bool get _canSavePassword {
    return !loading &&
        oldPassword.text.trim().isNotEmpty &&
        newPassword.text.trim().isNotEmpty;
  }

  Future<void> _changePassword() async {
    if (!_canSavePassword) return;

    FocusManager.instance.primaryFocus?.unfocus();

    setState(() => loading = true);

    try {
      await ref.read(profileSettingsControllerProvider).changePassword(
            currentPassword: oldPassword.text,
            newPassword: newPassword.text,
          );

      if (!mounted) return;

      oldPassword.clear();
      newPassword.clear();

      showAppSnackBar(context, passwordChangedMessage);
    } catch (e) {
      if (!mounted) return;

      showAppSnackBar(context, russianErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: oldPassword,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Старый пароль',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: newPassword,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Новый пароль',
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ElevatedButton(
          onPressed: _canSavePassword ? _changePassword : null,
          child: loading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Сохранить'),
        ),
      ],
    );
  }
}
