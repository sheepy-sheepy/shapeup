import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/date_utils.dart';
import '../../../core/enums.dart';
import '../../../core/app_errors.dart';
import '../../../core/design.dart';
import '../../../core/app_ui.dart';
import '../../../domain/services/nutrition_calculator.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/repositories/profile_repository.dart';
import '../../widgets/app_animations.dart';
import '../../widgets/profile_form_fields.dart';

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

    if (name.text.trim().isEmpty) return false;
    if (_positiveDouble(height) == null) return false;
    if (_positiveDouble(weight) == null) return false;
    if (_positiveDouble(neck) == null) return false;
    if (_positiveDouble(hips) == null) return false;
    if (_positiveDouble(waist) == null) return false;
    if (_validDobFromText(dob.text) == null) return false;

    return true;
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
      await ref.read(authRepositoryProvider).signOut(explicit: true);
    } catch (_) {}

    if (!mounted) return;
    context.go('/login');
  }

  double _d(TextEditingController controller) {
    return double.parse(controller.text.trim().replaceAll(',', '.'));
  }

  double? _positiveDouble(TextEditingController controller) {
    final value = double.tryParse(controller.text.trim().replaceAll(',', '.'));
    if (value == null || value <= 0 || !value.isFinite) return null;
    return value;
  }

  DateTime? _validDobFromText(String value) {
    final parsed = tryParseRuDate(value);
    if (parsed == null) return null;
    if (!parsed.isBefore(DateTime.now())) return null;

    return parsed;
  }

  String? _dobValidator(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Обязательное поле';

    if (!hasRuDateFormat(text)) return 'Введите дату в формате ДД.ММ.ГГГГ';

    if (_validDobFromText(text) == null) {
      return 'Введите корректную дату';
    }

    return null;
  }

  bool _bodyFatIsValid() {
    final heightCm = _positiveDouble(height);
    final neckCm = _positiveDouble(neck);
    final waistCm = _positiveDouble(waist);
    final hipsCm = _positiveDouble(hips);

    if (heightCm == null ||
        neckCm == null ||
        waistCm == null ||
        hipsCm == null) {
      return false;
    }

    try {
      final bodyFat = NutritionCalculator.bodyFatPercent(
        sex: sex,
        heightCm: heightCm,
        neckCm: neckCm,
        waistCm: waistCm,
        hipsCm: hipsCm,
      );

      return bodyFat.isFinite && bodyFat > 0;
    } catch (_) {
      return false;
    }
  }

  String _bodyFatValidationMessage() {
    try {
      final heightCm = _positiveDouble(height);
      final neckCm = _positiveDouble(neck);
      final waistCm = _positiveDouble(waist);
      final hipsCm = _positiveDouble(hips);

      if (heightCm == null ||
          neckCm == null ||
          waistCm == null ||
          hipsCm == null) {
        return 'Для расчета процента жира все параметры тела должны быть числами больше 0.';
      }

      final bodyFat = NutritionCalculator.bodyFatPercent(
        sex: sex,
        heightCm: heightCm,
        neckCm: neckCm,
        waistCm: waistCm,
        hipsCm: hipsCm,
      );

      if (!bodyFat.isFinite || bodyFat <= 0) {
        return 'Процент жира должен быть числом больше 0. Проверьте рост и обхваты.';
      }
    } catch (e) {
      final text = e.toString();
      if (text.contains('талия должна быть больше шеи')) {
        return 'Для мужчин талия должна быть больше шеи.';
      }
      if (text.contains('сумма талии и бедер должна быть больше шеи')) {
        return 'Для женщин сумма талии и бедер должна быть больше шеи.';
      }
      if (text.contains('% жира должен быть больше 0')) {
        return 'Процент жира должен быть числом больше 0. Проверьте рост и обхваты.';
      }
    }

    return 'Процент жира должен быть числом больше 0. Проверьте введенные параметры.';
  }

  Future<void> _save() async {
    if (!_canSave) return;
    if (!formKey.currentState!.validate()) return;

    if (!_bodyFatIsValid()) {
      showAppSnackBar(context, _bodyFatValidationMessage());
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => loading = true);

    try {
      await ref.read(profileRepositoryProvider).completeOnboarding(
            OnboardingData(
              name: name.text.trim(),
              heightCm: _d(height),
              weightKg: _d(weight),
              neckCm: _d(neck),
              hipsCm: _d(hips),
              waistCm: _d(waist),
              sex: sex,
              goal: goal,
              activityLevel: activity,
              dateOfBirth: parseRuDate(dob.text.trim()),
            ),
          );

      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (!mounted) return;

      showAppSnackBar(
        context,
        russianErrorMessage(
          e,
          fallback:
              'Не удалось сохранить данные onboarding. Повторите попытку.',
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
            title: 'Первичная настройка',
            message:
                'Заполните имя, рост, вес, обхваты, пол, цель, активность и дату рождения.\n\n'
                'Все числовые параметры должны быть больше 0. Дата рождения вводится в формате ДД.ММ.ГГГГ.\n\n'
                'После сохранения приложение рассчитает % жира, норму КБЖУ и воды, затем откроет личный кабинет.',
          ),
        ],
      ),
      body: AnimatedPageBody(
        child: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: withProfileFieldSpacing([
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
              ProfileSexDropdown(
                value: sex,
                enabled: !loading && !_openingLoginAfterExit,
                dropdownColor: Colors.white.withValues(alpha: 0.94),
                onChanged: (value) => setState(() => sex = value),
              ),
              ProfileGoalDropdown(
                value: goal,
                enabled: !loading && !_openingLoginAfterExit,
                dropdownColor: Colors.white.withValues(alpha: 0.94),
                onChanged: (value) => setState(() => goal = value),
              ),
              ProfileActivityDropdown(
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
            ]),
          ),
        ),
      ),
    );
  }
}
