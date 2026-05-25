import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/app_ui.dart';
import '../../../core/design.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'password_change_form.dart';
import 'profile_settings_form.dart';
import '../../widgets/app_animations.dart';

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
      await ref.read(authRepositoryProvider).signOut();

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
                'имя, рост, дефицит, дату рождения, пол, цель и уровень активности. '
                'Нажмите «Изменить», чтобы сохранить изменения. '
                'В разделе смены пароля введите текущий и новый пароль, затем нажмите «Сохранить». '
                'Кнопка выхода завершает текущий сеанс и возвращает на экран входа.',
          ),
        ],
      ),
      body: AnimatedPageBody(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            const _SettingsSection(
              title: 'Параметры пользователя',
              icon: Icons.person_outline,
              child: ProfileSettingsForm(),
            ),
          const SizedBox(height: AppSpacing.lg),
            const _SettingsSection(
              title: 'Смена пароля',
              icon: Icons.lock_outline,
              child: PasswordChangeForm(),
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

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}
