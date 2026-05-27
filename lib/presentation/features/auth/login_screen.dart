import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/enums.dart';
import '../../../core/app_errors.dart';
import '../../../core/app_ui.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'widgets/auth_form_card.dart';

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
      body: AuthFormCard(
        title: 'Вход',
        subtitle: 'Войдите, чтобы продолжить работу с ShapeUp',
        emailController: email,
        passwordController: password,
        loading: loading,
        canSubmit: _canSubmit,
        onSubmit: _submit,
        submitText: 'Войти',
        bottomText: 'Еще нет аккаунта?',
        onBottomPressed: () => context.go('/register'),
      ),
    );
  }
}
