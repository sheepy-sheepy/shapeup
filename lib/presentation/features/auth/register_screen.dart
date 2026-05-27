import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums.dart';
import '../../../core/app_errors.dart';
import '../../../core/app_ui.dart';
import '../../../domain/repositories/auth_repository.dart';
import 'widgets/auth_form_card.dart';

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
      body: AuthFormCard(
        title: 'Регистрация',
        subtitle: 'Создайте аккаунт и подтвердите почту кодом из письма',
        emailController: email,
        passwordController: password,
        loading: loading,
        canSubmit: _canSubmit,
        onSubmit: _submit,
        submitText: 'Зарегистрироваться',
        bottomText: 'Уже есть аккаунт?',
        onBottomPressed: () => context.go('/login'),
      ),
    );
  }
}
