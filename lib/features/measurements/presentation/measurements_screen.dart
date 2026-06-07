import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shapeup/core/shared/errors.dart';
import 'package:shapeup/core/design/ui.dart';
import 'package:shapeup/core/design/theme.dart';
import 'package:shapeup/core/shared/today_scheduler.dart';
import 'package:shapeup/presentation/providers/app_providers.dart' as app_providers;
import 'package:shapeup/features/measurements/presentation/widgets/measurement_form_widget.dart';
import 'package:shapeup/features/measurements/presentation/widgets/measurements_header_widget.dart';
import 'package:shapeup/features/measurements/presentation/widgets/saved_measurement_widget.dart';
import 'package:shapeup/features/settings/domain/entities/local_user_entity.dart';
import 'package:shapeup/features/measurements/providers/measurements_provider.dart';

class MeasurementsScreen extends ConsumerStatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  ConsumerState<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends ConsumerState<MeasurementsScreen>
    with TodayChangeScheduler<MeasurementsScreen> {
  final formKey = GlobalKey<FormState>();

  final weight = TextEditingController();
  final neck = TextEditingController();
  final waist = TextEditingController();
  final hips = TextEditingController();

  late String todayKey;

  @override
  void initState() {
    super.initState();

    todayKey = ref.read(app_providers.currentDayKeyProvider);

    weight.addListener(_onFieldChanged);
    neck.addListener(_onFieldChanged);
    waist.addListener(_onFieldChanged);
    hips.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    weight.removeListener(_onFieldChanged);
    neck.removeListener(_onFieldChanged);
    waist.removeListener(_onFieldChanged);
    hips.removeListener(_onFieldChanged);

    weight.dispose();
    neck.dispose();
    waist.dispose();
    hips.dispose();

    super.dispose();
  }

  void _onFieldChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _handleTodayChanged(String nextDayKey) {
    if (!mounted || nextDayKey == todayKey) return;

    weight.clear();
    neck.clear();
    waist.clear();
    hips.clear();

    setState(() {
      todayKey = nextDayKey;
    });
  }

  bool get _canSaveMeasurements {
    return ref.read(measurementsControllerProvider).canSaveMeasurementText(
      weightKg: weight.text,
      neckCm: neck.text,
      waistCm: waist.text,
      hipsCm: hips.text,
    );
  }

  double? _previewBodyFat(LocalUserEntity user) {
    return ref.read(measurementsControllerProvider).bodyFatPreviewFromText(
      user: user,
      neckCm: neck.text,
      waistCm: waist.text,
      hipsCm: hips.text,
    );
  }

  String _ruDateFromDayKey(String dayKey) {
    final parts = dayKey.split('-');
    if (parts.length != 3) return dayKey;
    return '${parts[2]}.${parts[1]}.${parts[0]}';
  }

  Future<void> _saveMeasurement(LocalUserEntity user) async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!formKey.currentState!.validate()) return;

    final values = ref.read(measurementsControllerProvider).valuesFromText(
      weightKg: weight.text,
      neckCm: neck.text,
      waistCm: waist.text,
      hipsCm: hips.text,
    );

    if (values == null) {
      showAppSnackBar(
        context,
        measurementParametersPositiveMessage,
      );
      return;
    }

    try {
      await ref.read(measurementsControllerProvider).saveMeasurement(
            dayKey: todayKey,
            user: user,
            values: values,
          );

      if (!mounted) return;

      showAppSnackBar(context, measurementsSavedMessage);

      ref.invalidate(measurementsLoadDataProvider(todayKey));
      app_providers.notifyAppDataChanged(ref);
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, russianErrorMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(app_providers.appRefreshTickProvider, (previous, next) {
      if (previous == null || previous == next) return;
      ref.invalidate(measurementsLoadDataProvider(todayKey));
    });

    final currentTodayKey = ref.watch(app_providers.currentDayKeyProvider);
    scheduleTodayChangeIfNeeded(
      currentTodayKey: todayKey,
      nextTodayKey: currentTodayKey,
      onTodayChanged: _handleTodayChanged,
    );

    final loadData = ref.watch(measurementsLoadDataProvider(todayKey));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Параметры тела'),
        actions: const [
          ScreenHelpAction(
            title: 'Параметры тела',
            message:
                'На этом экране можно один раз в день сохранить вес в кг., обхват шеи, талии и бедер в см.\n\n'
                'Все значения должны быть положительными числами. После сохранения приложение рассчитывает % жира, '
                'использует эти данные для нормы КБЖУ, воды и графиков изменений тела.\n\n'
                'Если параметры за сегодня уже введены, следующий ввод будет доступен завтра.',
          ),
        ],
      ),
      body: loadData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(errorWithTitle(measurementsLoadErrorTitle, error)),
          ),
        ),
        data: (data) {
          final user = data.user;
          final todayMeasurement = data.todayMeasurement;

          if (user == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  localProfileNotFoundMessage,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (user.sex == null || user.heightCm == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: Text(
                  'Профиль пользователя заполнен не полностью.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              MeasurementsHeaderWidget(
                dayText: _ruDateFromDayKey(todayKey),
                sexText: ref.read(measurementsControllerProvider).sexLabelFromUser(user) ??
                    'не указан',
                heightCm: user.heightCm,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (todayMeasurement != null)
                SavedMeasurementWidget(
                  measurement: todayMeasurement,
                  freshBodyFat:
                      ref.read(measurementsControllerProvider).freshBodyFatForMeasurement(
                    user: user,
                    measurement: todayMeasurement,
                  ),
                )
              else
                MeasurementFormWidget(
                  formKey: formKey,
                  weight: weight,
                  neck: neck,
                  waist: waist,
                  hips: hips,
                  bodyFatPreview: _previewBodyFat(user),
                  canSave: _canSaveMeasurements,
                  onSave: () => _saveMeasurement(user),
                ),
            ],
          );
        },
      ),
    );
  }
}
