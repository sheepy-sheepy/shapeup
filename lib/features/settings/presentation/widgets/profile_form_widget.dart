import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shapeup/core/shared/errors.dart';
import 'package:shapeup/core/shared/enums.dart';
import 'package:shapeup/core/shared/dates.dart';
import 'package:shapeup/core/design/ui.dart';
import 'package:shapeup/core/shared/validators.dart';
import 'package:shapeup/features/settings/presentation/controllers/profile_settings_controller.dart';
import 'package:shapeup/presentation/providers/app_providers.dart' as app_providers;
import 'package:shapeup/presentation/widgets/activity_dropdown_widget.dart';
import 'package:shapeup/presentation/widgets/field_spacing_widget.dart';
import 'package:shapeup/presentation/widgets/goal_dropdown_widget.dart';
import 'package:shapeup/presentation/widgets/sex_dropdown_widget.dart';
import 'package:shapeup/features/settings/domain/entities/local_user_entity.dart';
import 'package:shapeup/features/settings/providers/settings_provider.dart';

class ProfileFormWidget extends ConsumerStatefulWidget {
  const ProfileFormWidget({super.key});

  @override
  ConsumerState<ProfileFormWidget> createState() =>
      _ProfileSettingsFormState();
}

class _ProfileSettingsFormState extends ConsumerState<ProfileFormWidget> {
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

  String _formatNumber(double value, int decimals) {
    return value.toStringAsFixed(decimals);
  }

  void _onFormChanged() {
    if (_initializingControllers) return;
    if (!mounted) return;
    setState(() {});
  }

  ProfileSettingsDraftEntity _profileDraft() {
    return ref.read(profileSettingsControllerProvider).draftFromText(
      name: name.text,
      heightCm: height.text,
      deficitKcal: deficit.text,
      dateOfBirth: dob.text,
      sex: sex,
      goal: goal,
      activity: activity,
    );
  }

  ProfileSettingsInitialEntity _initialValues() {
    return ProfileSettingsInitialEntity(
      name: _initialName ?? '',
      heightCm: _initialHeightCm,
      deficitKcal: _initialDeficitKcal,
      dateOfBirth: _initialDateOfBirth,
      sex: _initialSex,
      goal: _initialGoal,
      activity: _initialActivity,
    );
  }

  bool _canSaveProfile(ProfileSettingsDataEntity data) {
    return ref.read(profileSettingsControllerProvider).canSave(
      saving: _saving,
      draft: _profileDraft(),
      initial: _initialValues(),
      latestMeasurement: data.latestMeasurement,
    );
  }

  String? _deficitValidator(String? value) {
    return ref.read(profileSettingsControllerProvider).deficitValidationMessage(value);
  }

  String? _dobValidator(String? value) {
    return ref.read(profileSettingsControllerProvider).dateOfBirthValidationMessage(value);
  }

  void _initializeFromUser(LocalUserEntity user) {
    if (initialized) return;

    _initializingControllers = true;

    sex = ref.read(profileSettingsControllerProvider).sexFromUser(user, fallback: sex);
    goal = ref.read(profileSettingsControllerProvider).goalFromUser(user, fallback: goal);
    activity = ref.read(profileSettingsControllerProvider).activityFromUser(
      user,
      fallback: activity,
    );

    final initialValues = ref.read(profileSettingsControllerProvider).initialValuesFromUser(
      user: user,
      sex: sex,
      goal: goal,
      activity: activity,
    );

    name.text = initialValues.name;
    height.text = initialValues.heightCm == null
        ? ''
        : _formatNumber(initialValues.heightCm!, 1);
    deficit.text = initialValues.deficitKcal == null
        ? ''
        : _formatNumber(initialValues.deficitKcal!, 0);

    if (user.dateOfBirth != null) {
      dob.text = toRuDate(user.dateOfBirth!);
    } else {
      dob.text = '';
    }

    _initialName = initialValues.name;
    _initialHeightCm = initialValues.heightCm;
    _initialDeficitKcal = initialValues.deficitKcal;
    _initialDateOfBirth = initialValues.dateOfBirth;
    _initialSex = initialValues.sex;
    _initialGoal = initialValues.goal;
    _initialActivity = initialValues.activity;

    initialized = true;
    _initializingControllers = false;
  }

  Future<void> _saveProfile(ProfileSettingsDataEntity data) async {
    if (!_canSaveProfile(data)) return;

    if (!formKey.currentState!.validate()) return;

    final draft = _profileDraft();
    final heightCm = draft.heightCm;
    final deficitKcal = draft.deficitKcal;
    final dateOfBirth = draft.dateOfBirth;

    if (heightCm == null || deficitKcal == null || dateOfBirth == null) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _saving = true);

    try {
      await ref.read(profileSettingsControllerProvider).saveProfile(draft);

      if (!mounted) return;

      final savedHeightCm = heightCm;
      final savedDeficitKcal = deficitKcal;

      _initializingControllers = true;
      height.text = _formatNumber(savedHeightCm, 1);
      deficit.text = _formatNumber(savedDeficitKcal, 0);
      _initializingControllers = false;

      setState(() {
        _initialName = draft.name;
        _initialHeightCm = savedHeightCm;
        _initialDeficitKcal = savedDeficitKcal;
        _initialDateOfBirth = dateOfBirth;
        _initialSex = draft.sex;
        _initialGoal = draft.goal;
        _initialActivity = draft.activity;
      });

      ref.invalidate(profileSettingsLoadDataProvider);
      app_providers.notifyAppDataChanged(ref);

      showAppSnackBar(context, profileSavedMessage);
    } catch (e) {
      if (!mounted) return;

      showAppSnackBar(context, russianErrorMessage(e));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loadData = ref.watch(profileSettingsLoadDataProvider);

    return loadData.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) =>
          Text(errorWithTitle(profileLoadErrorTitle, error)),
      data: (data) {
        final user = data.user;

        if (user == null) {
          return const Text(
            localProfileLoginAgainMessage,
          );
        }

        if (!initialized) {
          _initializeFromUser(user);
        }

        final canSave = _canSaveProfile(data);

        return Form(
          key: formKey,
          child: Column(
            children: [
              FieldSpacingWidget(
                children: [
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
                decoration: const InputDecoration(
                  labelText: 'Дефицит / Профицит, ккал',
                ),
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
              SexDropdownWidget(
                value: sex,
                dropdownColor: Colors.white.withValues(alpha: 0.94),
                onChanged: (value) => setState(() => sex = value),
              ),
              GoalDropdownWidget(
                value: goal,
                dropdownColor: Colors.white.withValues(alpha: 0.94),
                onChanged: (value) => setState(() => goal = value),
              ),
              ActivityDropdownWidget(
                value: activity,
                dropdownColor: Colors.white.withValues(alpha: 0.94),
                onChanged: (value) => setState(() => activity = value),
              ),
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
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
