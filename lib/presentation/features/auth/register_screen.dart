import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums.dart';
import '../../../core/app_errors.dart';
import '../../../core/app_ui.dart';
import '../../../core/design.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../widgets/shapeup_logo.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final email = TextEditingController();
  final password = TextEditingController();

  bool loading = false;

  @override
  void initState() {
    super.initState();
    email.addListener(_onFormChanged);
    password.addListener(_onFormChanged);
  }

  bool get _canSubmit {
    return !loading && email.text.trim().isNotEmpty && password.text.isNotEmpty;
  }

  void _onFormChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;

    final userEmail = email.text.trim();
    final userPassword = password.text;

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => loading = true);

    try {
      final repo = ref.read(authRepositoryProvider);

      await repo.signUp(email: userEmail, password: userPassword);

      final user = repo.currentUser;
      if (user != null) {
        await repo.saveLocalStatus(
          userId: user.id,
          email: userEmail,
          status: RegistrationStatus.emailUnconfirmed,
        );
      }

      await ref.read(otpCooldownProvider.notifier).startCooldown();

      if (!mounted) return;
      context.go('/otp', extra: userEmail);
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, russianRegisterErrorMessage(e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    email.removeListener(_onFormChanged);
    password.removeListener(_onFormChanged);
    email.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Регистрация'),
        actions: const [
          ScreenHelpAction(
            title: 'Регистрация',
            message: 
                'Введите действующую почту и пароль, затем нажмите «Зарегистрироваться».\n\n'
                'После регистрации на почту придёт 6-значный код подтверждения.\n\n'
                'Пока почта не подтверждена, вход в личный кабинет будет недоступен.',
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Center(
                        child: ShapeUpLogo(
                          size: 68,
                          circle: true,
                          padding: EdgeInsets.all(3),
                          hero: true,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Регистрация',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Создайте аккаунт и подтвердите почту кодом из письма',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      TextField(
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        enabled: !loading,
                        decoration: const InputDecoration(
                          labelText: 'Почта',
                          prefixIcon: Icon(Icons.mail_outline),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextField(
                        controller: password,
                        obscureText: true,
                        enabled: !loading,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _canSubmit ? _submit() : null,
                        decoration: const InputDecoration(
                          labelText: 'Пароль',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      FilledButton(
                        onPressed: _canSubmit ? _submit : null,
                        child: loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Зарегистрироваться'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed: loading ? null : () => context.go('/login'),
                        child: const Text('Уже есть аккаунт?'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
