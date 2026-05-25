import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/enums.dart';
import '../../../core/date_utils.dart';
import '../../../core/extensions.dart';
import '../../../core/design.dart';
import '../../../domain/services/nutrition_calculator.dart';
import '../../../core/app_ui.dart';
import '../../../domain/repositories/profile_repository.dart';
import '../../../domain/usecases/profile_settings_loader.dart';
import '../../state/app_refresh.dart';

final _profileSettingsLoadDataProvider =
    FutureProvider.autoDispose<ProfileSettingsLoadData>(
  (ref) => ref.watch(profileSettingsLoaderProvider).load(),
);

class ProfileSettingsForm extends ConsumerStatefulWidget {
  const ProfileSettingsForm({super.key});

  @override
  ConsumerState<ProfileSettingsForm> createState() =>
      _ProfileSettingsFormState();
}

class _ProfileSettingsFormState extends ConsumerState<ProfileSettingsForm> {
  final formKey = GlobalKey<FormState>();

  final name = TextEditingController();
  final height = TextEditingController();
  final deficit = TextEditingController();
  final dob = TextEditingController();


  Sex sex = Sex.male;
  Goal goal = Goal.loseWeight;
  ActivityLevel activity = ActivityLevel.sedentary;

  bool initialized = false;
  bool _initializingControllers = false;
  bool _saving = false;

  String? _initialName;
  double? _initialHeightCm;
  double? _initialDeficitKcal;
  DateTime? _initialDateOfBirth;
  Sex? _initialSex;
  Goal? _initialGoal;
  ActivityLevel? _initialActivity;

  Color get _dropdownBackgroundColor => Colors.white.withValues(alpha: 0.94);

  @override
  void initState() {
    super.initState();


    name.addListener(_onFormChanged);
    height.addListener(_onFormChanged);
    deficit.addListener(_onFormChanged);
    dob.addListener(_onFormChanged);
  }

  @override
  void dispose() {
    name.removeListener(_onFormChanged);
    height.removeListener(_onFormChanged);
    deficit.removeListener(_onFormChanged);
    dob.removeListener(_onFormChanged);

    name.dispose();
    height.dispose();
    deficit.dispose();
    dob.dispose();

    super.dispose();
  }

  double _roundTo(double value, int decimals) {
    var factor = 1.0;
    for (var i = 0; i < decimals; i++) {
      factor *= 10.0;
    }
    return (value * factor).roundToDouble() / factor;
  }

  double _heightValue(double value) => _roundTo(value, 1);
  double _deficitValue(double value) => _roundTo(value, 0);

  String _formatNumber(double value, int decimals) {
    return value.toStringAsFixed(decimals);
  }

  void _onFormChanged() {
    if (_initializingControllers) return;
    if (!mounted) return;
    setState(() {});
  }

  double? _positiveDoubleFromController(TextEditingController controller) {
    final value = double.tryParse(
      controller.text.trim().replaceAll(',', '.'),
    );

    if (value == null || value <= 0) return null;
    return _heightValue(value);
  }

  double? _deficitFromController() {
    final value = double.tryParse(
      deficit.text.trim().replaceAll(',', '.'),
    );

    if (value == null || value < 50 || value > 1000) return null;
    return _deficitValue(value);
  }

  DateTime? _parseDobText(String text) {
    final trimmed = text.trim();

    final match = RegExp(r'^(\d{2})\.(\d{2})\.(\d{4})$').firstMatch(trimmed);
    if (match == null) return null;

    final day = int.tryParse(match.group(1)!);
    final month = int.tryParse(match.group(2)!);
    final year = int.tryParse(match.group(3)!);

    if (day == null || month == null || year == null) return null;

    final parsed = DateTime(year, month, day);

    if (parsed.day != day || parsed.month != month || parsed.year != year) {
      return null;
    }

    return parsed;
  }

  DateTime? _dobFromController() {
    return _parseDobText(dob.text);
  }

  bool _sameDate(DateTime? a, DateTime? b) {
    if (a == null || b == null) return a == b;

    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _sameDouble(double? a, double? b) {
    if (a == null || b == null) return a == b;
    return (a - b).abs() < 0.001;
  }

  bool _hasChanges() {
    final currentHeight = _positiveDoubleFromController(height);
    final currentDeficit = _deficitFromController();
    final currentDob = _dobFromController();

    return name.text.trim() != (_initialName ?? '') ||
        !_sameDouble(currentHeight, _initialHeightCm) ||
        !_sameDouble(currentDeficit, _initialDeficitKcal) ||
        !_sameDate(currentDob, _initialDateOfBirth) ||
        sex != _initialSex ||
        goal != _initialGoal ||
        activity != _initialActivity;
  }

  bool _calorieNormIsValid({
    required ProfileSettingsLoadData data,
    required double heightCm,
    required double deficitKcal,
    required DateTime dateOfBirth,
  }) {
    if (goal != Goal.loseWeight) return true;

    final measurement = data.latestMeasurement;
    if (measurement == null) return true;

    final norms = NutritionCalculator.dailyNorms(
      sex: sex,
      goal: goal,
      activityLevel: activity,
      weightKg: measurement.weightKg,
      heightCm: heightCm,
      dob: dateOfBirth,
      deficitKcal: deficitKcal,
      today: DateTime.now(),
    );

    return norms.calories > 0;
  }

  bool _canSaveProfile(ProfileSettingsLoadData data) {
    if (_saving) return false;

    final currentName = name.text.trim();
    if (currentName.isEmpty) return false;

    final heightCm = _positiveDoubleFromController(height);
    if (heightCm == null) return false;

    final deficitKcal = _deficitFromController();
    if (deficitKcal == null) return false;

    final dateOfBirth = _dobFromController();
    if (dateOfBirth == null) return false;

    if (!_hasChanges()) return false;

    return _calorieNormIsValid(
      data: data,
      heightCm: heightCm,
      deficitKcal: deficitKcal,
      dateOfBirth: dateOfBirth,
    );
  }

  String? _deficitValidator(String? value) {
    final parsed = double.tryParse(
      (value ?? '').trim().replaceAll(',', '.'),
    );

    if (parsed == null) return 'Введите число';
    if (parsed < 50 || parsed > 1000) {
      return 'Дефицит должен быть от 50 до 1000';
    }

    return null;
  }

  String? _dobValidator(String? value) {
    if (_parseDobText(value ?? '') == null) {
      return 'Введите дату в формате ДД.ММ.ГГГГ';
    }

    return null;
  }

  void _initializeFromUser(LocalUser user) {
    if (initialized) return;

    _initializingControllers = true;

    final formattedHeight = user.heightCm == null
        ? ''
        : _formatNumber(_heightValue(user.heightCm!), 1);
    final formattedDeficit = _formatNumber(_deficitValue(user.deficitKcal), 0);

    name.text = user.name ?? '';
    height.text = formattedHeight;
    deficit.text = formattedDeficit;

    if (user.dateOfBirth != null) {
      dob.text = toRuDate(user.dateOfBirth!);
    } else {
      dob.text = '';
    }

    if (user.sex != null) {
      sex = Sex.values.firstWhere((e) => e.name == user.sex);
    }

    if (user.goal != null) {
      goal = Goal.values.firstWhere((e) => e.name == user.goal);
    }

    if (user.activityLevel != null) {
      activity = ActivityLevel.values.firstWhere(
        (e) => e.name == user.activityLevel,
      );
    }

    _initialName = name.text.trim();
    _initialHeightCm =
        user.heightCm == null ? null : _heightValue(user.heightCm!);
    _initialDeficitKcal = _deficitValue(user.deficitKcal);
    _initialDateOfBirth = user.dateOfBirth;
    _initialSex = sex;
    _initialGoal = goal;
    _initialActivity = activity;

    initialized = true;
    _initializingControllers = false;
  }

  Future<void> _saveProfile(ProfileSettingsLoadData data) async {
    if (!_canSaveProfile(data)) return;

    if (!formKey.currentState!.validate()) return;

    final heightCm = _positiveDoubleFromController(height);
    final deficitKcal = _deficitFromController();
    final dateOfBirth = _dobFromController();

    if (heightCm == null || deficitKcal == null || dateOfBirth == null) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _saving = true);

    try {
      await ref.read(profileRepositoryProvider).updateProfileSettings(
            name: name.text.trim(),
            sex: sex.name,
            goal: goal.name,
            activityLevel: activity.name,
            heightCm: _heightValue(heightCm),
            deficitKcal: _deficitValue(deficitKcal),
            dateOfBirth: dateOfBirth,
          );

      if (!mounted) return;

      final savedHeightCm = _heightValue(heightCm);
      final savedDeficitKcal = _deficitValue(deficitKcal);

      _initializingControllers = true;
      height.text = _formatNumber(savedHeightCm, 1);
      deficit.text = _formatNumber(savedDeficitKcal, 0);
      _initializingControllers = false;

      setState(() {
        _initialName = name.text.trim();
        _initialHeightCm = savedHeightCm;
        _initialDeficitKcal = savedDeficitKcal;
        _initialDateOfBirth = dateOfBirth;
        _initialSex = sex;
        _initialGoal = goal;
        _initialActivity = activity;
      });

      ref.invalidate(_profileSettingsLoadDataProvider);
      notifyAppDataChanged(ref);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Данные пользователя были успешно сохранены'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }


  Widget _selectedDropdownText(String text) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _dropdownMenuText(String text) {
    return Text(
      text,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _sexDropdown() {
    return DropdownButtonFormField<Sex>(
      dropdownColor: _dropdownBackgroundColor,
      initialValue: sex,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Пол'),
      selectedItemBuilder: (context) {
        return Sex.values
            .map((e) => _selectedDropdownText(e.label))
            .toList();
      },
      items: Sex.values
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: _dropdownMenuText(e.label),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v == null) return;
        setState(() => sex = v);
      },
    );
  }

  Widget _goalDropdown() {
    return DropdownButtonFormField<Goal>(
      dropdownColor: _dropdownBackgroundColor,
      initialValue: goal,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Цель'),
      selectedItemBuilder: (context) {
        return Goal.values
            .map((e) => _selectedDropdownText(e.label))
            .toList();
      },
      items: Goal.values
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: _dropdownMenuText(e.label),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v == null) return;
        setState(() => goal = v);
      },
    );
  }

  Widget _activityDropdown() {
    return DropdownButtonFormField<ActivityLevel>(
      dropdownColor: _dropdownBackgroundColor,
      initialValue: activity,
      isExpanded: true,
      decoration: const InputDecoration(labelText: 'Образ жизни'),
      selectedItemBuilder: (context) {
        return ActivityLevel.values
            .map((e) => _selectedDropdownText(e.label))
            .toList();
      },
      items: ActivityLevel.values
          .map(
            (e) => DropdownMenuItem(
              value: e,
              child: _dropdownMenuText(e.label),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v == null) return;
        setState(() => activity = v);
      },
    );
  }

  List<Widget> _withFieldSpacing(List<Widget> children) {
    return [
      for (var i = 0; i < children.length; i++) ...[
        children[i],
        if (i != children.length - 1) const SizedBox(height: AppSpacing.md),
      ],
    ];
  }

  @override
  Widget build(BuildContext context) {
    final loadData = ref.watch(_profileSettingsLoadDataProvider);

    return loadData.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Text('Ошибка загрузки профиля: $error'),
      data: (data) {
        final user = data.user;

        if (user == null) {
          return const Text(
            'Локальный профиль не найден. Выполните вход заново.',
          );
        }

        if (!initialized) {
          _initializeFromUser(user);
        }

        final canSave = _canSaveProfile(data);

        return Form(
          key: formKey,
          child: Column(
            children: _withFieldSpacing([
              TextFormField(
                controller: name,
                decoration: const InputDecoration(labelText: 'Имя'),
                validator: Validators.requiredText,
              ),
              TextFormField(
                controller: height,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Рост, см'),
                validator: Validators.positiveNumber,
              ),
              TextFormField(
                controller: deficit,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Дефицит / Профицит, ккал'),
                validator: _deficitValidator,
              ),
              TextFormField(
                controller: dob,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(
                  labelText: 'Дата рождения ДД.ММ.ГГГГ',
                ),
                validator: _dobValidator,
              ),
              _sexDropdown(),
              _goalDropdown(),
              _activityDropdown(),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: canSave ? () => _saveProfile(data) : null,
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Сохранить'),
              ),
            ]),
          ),
        );
      },
    );
  }
}

