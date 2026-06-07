import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shapeup/core/shared/errors.dart';
import 'package:shapeup/core/design/ui.dart';
import 'package:shapeup/features/auth/presentation/widgets/auth_card_widget.dart';
import 'package:shapeup/features/auth/providers/auth_provider.dart';

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

  Future<void> _submit() async {
    if (!_canSubmit) return;

    final userEmail = email.text.trim();
    final userPassword = password.text;

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => loading = true);

    try {
      final target = await ref.read(authFlowControllerProvider).login(
            email: userEmail,
            password: userPassword,
          );

      if (!mounted) return;
      context.go(target.path, extra: target.extra);
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, russianLoginErrorMessage(e));
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
        title: const Text('Вход'),
        actions: const [
          ScreenHelpAction(
            title: 'Вход',
            message:
                'Введите почту и пароль, указанные при регистрации, и нажмите «Войти».\n\n'
                'Если почта ещё не подтверждена, приложение откроет экран ввода кода.\n\n'
                'Если ввод первоначальных данных не завершён, приложение откроет экран заполнения этих данных.\n\n'
                'Если аккаунт полностью зарегистрирован, откроется личный кабинет.',
          ),
        ],
      ),
      body: AuthCardWidget(
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
