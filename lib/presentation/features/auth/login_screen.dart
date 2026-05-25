import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/enums.dart';
import '../../../core/app_errors.dart';
import '../../../core/app_ui.dart';
import '../../../core/design.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../widgets/shapeup_logo.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
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

  bool _isEmailNotConfirmed(AuthException error) {
    final message = error.message.toLowerCase();
    return message.contains('email not confirmed') ||
        message.contains('email_not_confirmed') ||
        message.contains('confirm your email') ||
        message.contains('подтверд');
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;

    final userEmail = email.text.trim();
    final userPassword = password.text;

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => loading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);

      // Сначала всегда проверяем локально сохраненные аккаунты.
      // Если аккаунт уже был на этом устройстве, обязательно сверяем пароль
      // с локально сохраненным хэшем. Если пароль верный — открываем аккаунт
      // даже без интернета. При наличии интернета Supabase-сессия восстановится
      // в фоне, чтобы настройки дальше могли сохраняться в Supabase.
      final localStatus = await authRepo.signInLocalIfExists(
        email: userEmail,
        password: userPassword,
        warmUpRemoteSession: true,
      );

      if (!mounted) return;

      if (localStatus != null) {
        await _goByStatus(localStatus, email: userEmail);
        return;
      }

      // Если локально аккаунта нет, только тогда проверяем Supabase.
      await authRepo.signIn(
        email: userEmail,
        password: userPassword,
      );

      final status = await authRepo.fetchRemoteProfileAndSaveLocal();

      if (!mounted) return;
      await _goByStatus(status, email: userEmail);
    } on AuthException catch (e) {
      if (!mounted) return;

      if (_isEmailNotConfirmed(e)) {
        await ref.read(otpCooldownProvider.notifier).startCooldown();
        if (!mounted) return;
        context.go('/otp', extra: userEmail);
        return;
      }

      showAppSnackBar(context, russianLoginErrorMessage(e));
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, russianLoginErrorMessage(e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _goByStatus(
    RegistrationStatus? status, {
    required String email,
  }) async {
    switch (status) {
      case RegistrationStatus.emailUnconfirmed:
        await ref.read(otpCooldownProvider.notifier).startCooldown();
        if (!mounted) return;
        context.go('/otp', extra: email);
        return;

      case RegistrationStatus.onboardingNotDone:
        context.go('/onboarding');
        return;

      case RegistrationStatus.fullyRegistered:
        context.go('/home');
        return;

      case null:
        showAppSnackBar(context, 'Статус регистрации не найден');
        return;
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
        title: const Text('Вход'),
        actions: const [
          ScreenHelpAction(
            title: 'Вход',
            message: 
                'Введите почту и пароль, указанные при регистрации, и нажмите «Войти».\n\n'
                'Если почта ещё не подтверждена, приложение откроет экран ввода кода.\n\n'
                'Если onboarding не завершён, приложение откроет экран заполнения параметров.\n\n'
                'Если аккаунт полностью зарегистрирован, откроется личный кабинет.',
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
                        'Вход',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Войдите, чтобы продолжить работу с ShapeUp',
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
                            : const Text('Войти'),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton(
                        onPressed: loading ? null : () => context.go('/register'),
                        child: const Text('Еще нет аккаунта?'),
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
