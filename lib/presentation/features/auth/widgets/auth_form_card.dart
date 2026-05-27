import 'package:flutter/material.dart';

import '../../../../core/design.dart';
import '../../../widgets/shapeup_logo.dart';

class AuthFormCard extends StatelessWidget {
  const AuthFormCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.emailController,
    required this.passwordController,
    required this.loading,
    required this.canSubmit,
    required this.onSubmit,
    required this.submitText,
    required this.bottomText,
    required this.onBottomPressed,
  });

  final String title;
  final String subtitle;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final bool loading;
  final bool canSubmit;
  final VoidCallback onSubmit;
  final String submitText;
  final String bottomText;
  final VoidCallback onBottomPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
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
                      title,
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    TextField(
                      controller: emailController,
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
                      controller: passwordController,
                      obscureText: true,
                      enabled: !loading,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => canSubmit ? onSubmit() : null,
                      decoration: const InputDecoration(
                        labelText: 'Пароль',
                        prefixIcon: Icon(Icons.lock_outline),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    FilledButton(
                      onPressed: canSubmit ? onSubmit : null,
                      child: loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(submitText),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    TextButton(
                      onPressed: loading ? null : onBottomPressed,
                      child: Text(bottomText),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
