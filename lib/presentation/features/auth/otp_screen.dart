import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums.dart';
import '../../../core/app_ui.dart';
import '../../../domain/repositories/auth_repository.dart';

class OtpScreen extends ConsumerStatefulWidget {
  const OtpScreen({super.key});

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  static const int otpLifetimeMinutes = 5;
  static const int _codeLength = 6;

  final TextEditingController _codeController = TextEditingController();
  final FocusNode _codeFocusNode = FocusNode();

  bool loading = false;
  String? email;

  String get _codeText => _codeController.text;

  bool get _isCodeComplete => RegExp(r'^\d{6}$').hasMatch(_codeText);

  bool get _canVerify => !loading && _isCodeComplete;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_onCodeChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final extra = GoRouterState.of(context).extra;
    if (extra is String && extra.isNotEmpty) {
      email = extra;
    }
  }

  @override
  void dispose() {
    _codeController.removeListener(_onCodeChanged);
    _codeController.dispose();
    _codeFocusNode.dispose();
    super.dispose();
  }

  void _onCodeChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _focusCodeField() {
    if (loading) return;

    _codeController.selection = TextSelection.collapsed(
      offset: _codeController.text.length,
    );

    _codeFocusNode.requestFocus();
  }

  String _otpErrorMessage(Object error) {
    final text = error.toString().toLowerCase();

    final isNetworkError = text.contains('socketexception') ||
        text.contains('failed host lookup') ||
        text.contains('network is unreachable') ||
        text.contains('connection') ||
        text.contains('timeoutexception');

    if (isNetworkError) {
      return 'Нет интернет-соединения. Проверьте подключение и повторите попытку.';
    }

    return 'Код неверный или срок действия кода истек. Попробуйте проверить правильность кода или нажать на "Отправить код повторно".';
  }

  String _resendErrorMessage(Object error) {
    final text = error.toString().toLowerCase();

    final isRateLimited = text.contains('rate limit') ||
        text.contains('60 seconds') ||
        text.contains('wait') ||
        text.contains('too many requests');

    if (isRateLimited) {
      return 'Повторная отправка доступна не чаще одного раза в 60 секунд.';
    }

    if (text.contains('socketexception') ||
        text.contains('failed host lookup') ||
        text.contains('network is unreachable') ||
        text.contains('connection') ||
        text.contains('timeoutexception')) {
      return 'Нет интернет-соединения. Проверьте подключение и повторите попытку.';
    }

    return 'Не удалось отправить код повторно. Повторите попытку.';
  }

  Future<void> _verify() async {
    final userCode = _codeText;

    if (email == null || email!.isEmpty) {
      showAppSnackBar(context, 'Не удалось определить почту пользователя.');
      return;
    }

    if (!_isCodeComplete) {
      showAppSnackBar(context, 'Введите полный 6-значный код из цифр.');
      return;
    }

    setState(() => loading = true);

    try {
      final repo = ref.read(authRepositoryProvider);

      await repo.verifyOtp(
        email: email!,
        token: userCode,
      );

      await repo.updateStatusRemoteThenLocal(
        RegistrationStatus.onboardingNotDone,
      );

      await ref.read(otpCooldownProvider.notifier).clear();

      if (!mounted) return;
      context.go('/onboarding');
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, _otpErrorMessage(e));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _resend() async {
    final cooldownState = ref.read(otpCooldownProvider);
    if (!cooldownState.canResend) return;

    if (email == null || email!.isEmpty) {
      showAppSnackBar(context, 'Не удалось определить почту пользователя.');
      return;
    }

    try {
      await ref.read(authRepositoryProvider).resendOtp(email: email!);
      await ref.read(otpCooldownProvider.notifier).startCooldown();

      if (!mounted) return;
      showAppSnackBar(context, 'Код отправлен повторно.');
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, _resendErrorMessage(e));
    }
  }

  Widget _codeCells(BuildContext context) {
    final theme = Theme.of(context);
    final codeText = _codeText;
    final focusedIndex = codeText.length.clamp(0, _codeLength - 1).toInt();

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _focusCodeField,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 1,
            height: 1,
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: _codeController,
                focusNode: _codeFocusNode,
                enabled: !loading,
                autofocus: true,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(_codeLength),
                ],
                onSubmitted: (_) {
                  if (_canVerify) _verify();
                },
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(_codeLength, (index) {
              final value = index < codeText.length ? codeText[index] : '';
              final isActive = _codeFocusNode.hasFocus &&
                  (index == focusedIndex ||
                      (codeText.length == _codeLength &&
                          index == _codeLength - 1));

              return AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                width: 46,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                    width: isActive ? 2 : 1,
                  ),
                ),
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cooldownState = ref.watch(otpCooldownProvider);

    final resendText = cooldownState.canResend
        ? 'Отправить код повторно'
        : 'Отправить код повторно через ${cooldownState.secondsLeft} сек';

    final emailText = email == null || email!.isEmpty
        ? 'Почта не определена'
        : 'Письмо с кодом отправлено на:\n$email';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Подтверждение почты'),
        actions: const [
          ScreenHelpAction(
            title: 'Подтверждение почты',
            message:
                'Введите 6-значный код из письма. Каждая цифра отображается в отдельной ячейке. '
                'При стирании код удаляется как обычный текст, поэтому не нужно вручную нажимать на каждую ячейку. '
                'Если код не пришел, дождитесь окончания таймера и нажмите «Отправить код повторно». '
                'Код действует ограниченное время, поэтому при истечении срока запросите новый код.',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: !cooldownState.initialized
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    emailText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Введите 6-значный код. Код действует $otpLifetimeMinutes минут.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  _codeCells(context),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _canVerify ? _verify : null,
                    child: loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Подтвердить'),
                  ),
                  TextButton(
                    onPressed:
                        (!loading && cooldownState.canResend) ? _resend : null,
                    child: Text(resendText),
                  ),
                ],
              ),
      ),
    );
  }
}
