import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shapeup/core/shared/errors.dart';
import 'package:shapeup/core/design/ui.dart';
import 'package:shapeup/features/auth/presentation/widgets/auth_card_widget.dart';
import 'package:shapeup/features/auth/providers/auth_provider.dart';

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
      final target = await ref.read(authFlowControllerProvider).register(
            email: userEmail,
            password: userPassword,
          );

      if (!mounted) return;
      context.go(target.path, extra: target.extra);
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
                'Введите эл. почту и пароль минимум из 6 символов, затем нажмите «Зарегистрироваться».\n\n'
                'После регистрации на почту придёт код подтверждения из 6 цифр .\n\n'
                'Пока почта не подтверждена, вход в личный кабинет будет недоступен.\n\n'
                'При регистрации вы соглашаетесь с сохранением персональных данных в локальную и облачную базы данных.',
          ),
        ],
      ),
      body: AuthCardWidget(
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
