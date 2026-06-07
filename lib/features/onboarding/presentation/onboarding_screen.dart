import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shapeup/core/shared/enums.dart';
import 'package:shapeup/core/shared/errors.dart';
import 'package:shapeup/core/design/theme.dart';
import 'package:shapeup/core/design/ui.dart';
import 'package:shapeup/core/shared/validators.dart';
import 'package:shapeup/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:shapeup/presentation/widgets/animated_page_body_widget.dart';
import 'package:shapeup/presentation/widgets/activity_dropdown_widget.dart';
import 'package:shapeup/presentation/widgets/field_spacing_widget.dart';
import 'package:shapeup/presentation/widgets/goal_dropdown_widget.dart';
import 'package:shapeup/presentation/widgets/sex_dropdown_widget.dart';
import 'package:shapeup/features/onboarding/providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with WidgetsBindingObserver {
  final formKey = GlobalKey<FormState>();

  final name = TextEditingController();
  final height = TextEditingController();
  final weight = TextEditingController();
  final neck = TextEditingController();
  final hips = TextEditingController();
  final waist = TextEditingController();
  final dob = TextEditingController();

  Sex sex = Sex.male;
  Goal goal = Goal.loseWeight;
  ActivityLevel activity = ActivityLevel.sedentary;

  bool loading = false;
  bool _leftAppDuringOnboarding = false;
  bool _openingLoginAfterExit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    for (final controller in _requiredControllers) {
      controller.addListener(_onFormChanged);
    }

    unawaited(
      ref.read(onboardingControllerProvider).markOnboardingStarted(),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _leftAppDuringOnboarding = true;
      return;
    }

    if (state == AppLifecycleState.resumed && _leftAppDuringOnboarding) {
      _openLoginAfterInterruptedOnboarding();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    for (final controller in _requiredControllers) {
      controller.removeListener(_onFormChanged);
    }

    name.dispose();
    height.dispose();
    weight.dispose();
    neck.dispose();
    hips.dispose();
    waist.dispose();
    dob.dispose();

    super.dispose();
  }

  List<TextEditingController> get _requiredControllers => [
        name,
        height,
        weight,
        neck,
        hips,
        waist,
        dob,
      ];

  bool get _canSave {
    if (loading || _openingLoginAfterExit) return false;

    return ref.read(onboardingControllerProvider).canSubmit(
      name: name.text,
      heightCm: height.text,
      weightKg: weight.text,
      neckCm: neck.text,
      hipsCm: hips.text,
      waistCm: waist.text,
      dateOfBirth: dob.text,
      loading: loading,
      openingLoginAfterExit: _openingLoginAfterExit,
    );
  }

  void _onFormChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _openLoginAfterInterruptedOnboarding() async {
    if (_openingLoginAfterExit) return;

    _leftAppDuringOnboarding = false;
    _openingLoginAfterExit = true;

    FocusManager.instance.primaryFocus?.unfocus();

    try {
      await ref.read(onboardingControllerProvider).signOutAfterInterruptedOnboarding();
    } catch (_) {}

    if (!mounted) return;
    context.go('/login');
  }

  String? _dobValidator(String? value) {
    return ref.read(onboardingControllerProvider).dateOfBirthValidationMessage(value);
  }

  BodyFatResultEntity _bodyFatValidationResult() {
    return ref.read(onboardingControllerProvider).validateBodyFatFromText(
      sex: sex,
      heightCm: height.text,
      neckCm: neck.text,
      waistCm: waist.text,
      hipsCm: hips.text,
    );
  }

  Future<void> _save() async {
    if (!_canSave) return;
    if (!formKey.currentState!.validate()) return;

    final bodyFatValidation = _bodyFatValidationResult();
    if (!bodyFatValidation.isValid) {
      showAppSnackBar(context, bodyFatValidation.message);
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => loading = true);

    try {
      final onboardingData = ref.read(onboardingControllerProvider).onboardingDataFromText(
        name: name.text,
        heightCm: height.text,
        weightKg: weight.text,
        neckCm: neck.text,
        hipsCm: hips.text,
        waistCm: waist.text,
        sex: sex,
        goal: goal,
        activity: activity,
        dateOfBirth: dob.text,
      );

      if (onboardingData == null) return;

      await ref.read(onboardingControllerProvider).completeOnboarding(
            onboardingData,
          );

      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;

      showAppSnackBar(
        context,
        russianErrorMessage(
          e,
          fallback: onboardingSaveFailedMessage,
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Widget _numberField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      enabled: !loading && !_openingLoginAfterExit,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(labelText: label),
      validator: Validators.positiveNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Первичные данные'),
        actions: const [
          ScreenHelpAction(
            title: 'Первичные данные',
            message:
                'Заполните имя, рост, вес, обхваты, пол, цель, активность и дату рождения.\n\n'
                'Все числовые параметры должны быть больше 0. Дата рождения вводится в формате ДД.ММ.ГГГГ.\n\n'
                'После сохранения приложение рассчитает % жира, норму КБЖУ и воды, затем откроет личный кабинет.',
          ),
        ],
      ),
      body: AnimatedPageBodyWidget(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              FieldSpacingWidget(
                children: [
              TextFormField(
                controller: name,
                enabled: !loading && !_openingLoginAfterExit,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(labelText: 'Имя'),
                validator: Validators.requiredText,
              ),
              _numberField(controller: height, label: 'Рост'),
              _numberField(controller: weight, label: 'Вес'),
              _numberField(controller: neck, label: 'Шея'),
              _numberField(controller: hips, label: 'Бедра'),
              _numberField(controller: waist, label: 'Талия'),
              TextFormField(
                controller: dob,
                enabled: !loading && !_openingLoginAfterExit,
                keyboardType: TextInputType.datetime,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _canSave ? _save() : null,
                decoration: const InputDecoration(
                  labelText: 'Дата рождения ДД.ММ.ГГГГ',
                ),
                validator: _dobValidator,
              ),
              SexDropdownWidget(
                value: sex,
                enabled: !loading && !_openingLoginAfterExit,
                dropdownColor: Colors.white.withValues(alpha: 0.94),
                onChanged: (value) => setState(() => sex = value),
              ),
              GoalDropdownWidget(
                value: goal,
                enabled: !loading && !_openingLoginAfterExit,
                dropdownColor: Colors.white.withValues(alpha: 0.94),
                onChanged: (value) => setState(() => goal = value),
              ),
              ActivityDropdownWidget(
                value: activity,
                enabled: !loading && !_openingLoginAfterExit,
                dropdownColor: Colors.white.withValues(alpha: 0.94),
                onChanged: (value) => setState(() => activity = value),
              ),
              const SizedBox(height: AppSpacing.sm),
              ElevatedButton(
                onPressed: _canSave ? _save : null,
                child: loading || _openingLoginAfterExit
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Сохранить'),
              ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
