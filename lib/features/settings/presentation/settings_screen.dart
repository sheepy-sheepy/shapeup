import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shapeup/core/design/ui.dart';
import 'package:shapeup/core/design/theme.dart';
import 'package:shapeup/features/settings/presentation/widgets/password_change_form_widget.dart';
import 'package:shapeup/features/settings/presentation/widgets/profile_form_widget.dart';
import 'package:shapeup/presentation/widgets/animated_page_body_widget.dart';
import 'package:shapeup/features/settings/presentation/widgets/settings_section_widget.dart';
import 'package:shapeup/features/auth/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _signingOut = false;

  Future<void> _signOut() async {
    if (_signingOut) return;

    setState(() => _signingOut = true);

    try {
      await ref.read(authFlowControllerProvider).signOut();

      if (!mounted) return;
      context.go('/login');
    } finally {
      if (mounted) {
        setState(() => _signingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Настройки'),
        actions: const [
          ScreenHelpAction(
            title: 'Настройки',
            message:
                'На этом экране можно изменить параметры пользователя, которые влияют на расчет КБЖУ и воды: '
                'имя, рост, дефицит, дату рождения, пол, цель и уровень активности.\n\n'
                'Нажмите «Изменить», чтобы сохранить изменения.\n\n'
                'В разделе смены пароля введите текущий и новый пароли минимум из 6 символов, затем нажмите «Сохранить».\n\n'
                'Изменения данных пользователя и пароля требует подключения к сети Интернет.\n\n'
                'Кнопка выхода возвращает на экран входа.',
          ),
        ],
      ),
      body: AnimatedPageBodyWidget(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const SettingsSectionWidget(
              title: 'Параметры пользователя',
              icon: Icons.person_outline,
              child: ProfileFormWidget(),
            ),
            const SizedBox(height: AppSpacing.lg),
            const SettingsSectionWidget(
              title: 'Смена пароля',
              icon: Icons.lock_outline,
              child: PasswordChangeFormWidget(),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.tonalIcon(
              onPressed: _signingOut ? null : _signOut,
              icon: const Icon(Icons.logout),
              label: _signingOut
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Выход из аккаунта'),
            ),
          ],
        ),
      ),
    );
  }
}
