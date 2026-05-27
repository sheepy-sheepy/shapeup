import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/app_ui.dart';
import '../../../core/design.dart';
import '../../../core/enums.dart';
import '../../../core/extensions.dart';
import '../../../core/number_utils.dart';
import '../../../domain/services/nutrition_calculator.dart';
import '../../../domain/entities/local_entities.dart';
import '../../../domain/repositories/measurements_repository.dart';
import '../../../domain/usecases/measurements_loader.dart';
import '../../mixins/today_change_scheduler.dart';
import '../../state/app_refresh.dart';

final _measurementsLoadDataProvider =
    FutureProvider.autoDispose.family<MeasurementsLoadData, String>(
  (ref, dayKey) => ref.watch(measurementsLoaderProvider).loadForDay(dayKey),
);

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

    todayKey = ref.read(currentDayKeyProvider);

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

  double? _positiveDouble(TextEditingController controller) {
    final value = double.tryParse(
      controller.text.trim().replaceAll(',', '.'),
    );

    if (value == null || value <= 0) return null;
    return roundTo1(value);
  }

  bool get _canSaveMeasurements {
    return _positiveDouble(weight) != null &&
        _positiveDouble(neck) != null &&
        _positiveDouble(waist) != null &&
        _positiveDouble(hips) != null;
  }

  Sex? _sexFromUser(LocalUser user) {
    final sexName = user.sex;
    if (sexName == null) return null;

    for (final item in Sex.values) {
      if (item.name == sexName) return item;
    }

    return null;
  }

  double? _freshBodyFatForMeasurement({
    required LocalUser user,
    required BodyMeasurement measurement,
  }) {
    final sex = _sexFromUser(user);
    final heightCm = user.heightCm;

    if (sex == null || heightCm == null || heightCm <= 0) {
      return null;
    }

    try {
      return NutritionCalculator.bodyFatPercent(
        sex: sex,
        heightCm: heightCm,
        neckCm: measurement.neckCm,
        waistCm: measurement.waistCm,
        hipsCm: measurement.hipsCm,
      );
    } catch (_) {
      return null;
    }
  }

  double? _previewBodyFat(LocalUser user) {
    final sex = _sexFromUser(user);
    final heightCm = user.heightCm;
    final neckCm = _positiveDouble(neck);
    final waistCm = _positiveDouble(waist);
    final hipsCm = _positiveDouble(hips);

    if (sex == null ||
        heightCm == null ||
        heightCm <= 0 ||
        neckCm == null ||
        waistCm == null ||
        hipsCm == null) {
      return null;
    }

    try {
      return NutritionCalculator.bodyFatPercent(
        sex: sex,
        heightCm: heightCm,
        neckCm: neckCm,
        waistCm: waistCm,
        hipsCm: hipsCm,
      );
    } catch (_) {
      return null;
    }
  }

  String _ruDateFromDayKey(String dayKey) {
    final parts = dayKey.split('-');
    if (parts.length != 3) return dayKey;
    return '${parts[2]}.${parts[1]}.${parts[0]}';
  }

  Future<void> _saveMeasurement(LocalUser user) async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (!formKey.currentState!.validate()) return;

    final weightKg = _positiveDouble(weight);
    final neckCm = _positiveDouble(neck);
    final waistCm = _positiveDouble(waist);
    final hipsCm = _positiveDouble(hips);

    if (weightKg == null ||
        neckCm == null ||
        waistCm == null ||
        hipsCm == null) {
      showAppSnackBar(
        context,
        'Заполните все параметры положительными числами',
      );
      return;
    }

    try {
      await ref.read(measurementsRepositoryProvider).saveMeasurement(
            dayKey: todayKey,
            weightKg: roundTo1(weightKg),
            neckCm: roundTo1(neckCm),
            waistCm: roundTo1(waistCm),
            hipsCm: roundTo1(hipsCm),
            heightCm: user.heightCm!,
            sex: Sex.values.firstWhere((e) => e.name == user.sex),
          );

      if (!mounted) return;

      showAppSnackBar(context, 'Сохранено');

      ref.invalidate(_measurementsLoadDataProvider(todayKey));
      notifyAppDataChanged(ref);
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(appRefreshTickProvider, (previous, next) {
      if (previous == null || previous == next) return;
      ref.invalidate(_measurementsLoadDataProvider(todayKey));
    });

    final currentTodayKey = ref.watch(currentDayKeyProvider);
    scheduleTodayChangeIfNeeded(
      currentTodayKey: todayKey,
      nextTodayKey: currentTodayKey,
      onTodayChanged: _handleTodayChanged,
    );

    final loadData = ref.watch(_measurementsLoadDataProvider(todayKey));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Параметры тела'),
        actions: const [
          ScreenHelpAction(
            title: 'Параметры тела',
            message:
                'На этом экране можно один раз в день сохранить вес, обхват шеи, талии и бедер. '
                'Все значения должны быть положительными числами. После сохранения приложение рассчитывает % жира '
                'и использует эти данные для нормы КБЖУ, воды и графиков аналитики. '
                'Если параметры за сегодня уже введены, следующий ввод будет доступен завтра.',
          ),
        ],
      ),
      body: loadData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text('Ошибка загрузки: $error'),
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
                  'Локальный профиль не найден. Выполните загрузку данных.',
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
              _MeasurementsHeaderCard(
                dayText: _ruDateFromDayKey(todayKey),
                sexText: _sexFromUser(user)?.label ?? 'не указан',
                heightCm: user.heightCm,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (todayMeasurement != null)
                _SavedMeasurementContent(
                  measurement: todayMeasurement,
                  freshBodyFat: _freshBodyFatForMeasurement(
                    user: user,
                    measurement: todayMeasurement,
                  ),
                )
              else
                _MeasurementFormContent(
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

class _MeasurementsHeaderCard extends StatelessWidget {
  const _MeasurementsHeaderCard({
    required this.dayText,
    required this.sexText,
    required this.heightCm,
  });

  final String dayText;
  final String sexText;
  final double? heightCm;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colors.primaryContainer.withValues(alpha: 0.94),
            colors.secondaryContainer.withValues(alpha: 0.88),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: colors.surface.withValues(alpha: 0.72),
              foregroundColor: colors.primary,
              child: const Icon(Icons.monitor_weight_outlined),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Сегодняшние параметры',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dayText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onPrimaryContainer.withValues(alpha: 0.76),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MeasurementFormContent extends StatelessWidget {
  const _MeasurementFormContent({
    required this.formKey,
    required this.weight,
    required this.neck,
    required this.waist,
    required this.hips,
    required this.bodyFatPreview,
    required this.canSave,
    required this.onSave,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController weight;
  final TextEditingController neck;
  final TextEditingController waist;
  final TextEditingController hips;
  final double? bodyFatPreview;
  final bool canSave;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Новый замер',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _BodyInputField(
                    controller: weight,
                    label: 'Вес',
                    suffix: 'кг',
                    icon: Icons.accessibility_new_outlined,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _BodyInputField(
                    controller: neck,
                    label: 'Шея',
                    suffix: 'см',
                    icon: Icons.straighten_outlined,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _BodyInputField(
                    controller: waist,
                    label: 'Талия',
                    suffix: 'см',
                    icon: Icons.straighten_outlined,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _BodyInputField(
                    controller: hips,
                    label: 'Бедра',
                    suffix: 'см',
                    icon: Icons.straighten_outlined,
                  ),
                ],
              ),
            ),
          ),
          if (bodyFatPreview != null) ...[
            const SizedBox(height: AppSpacing.lg),
            _BodyFatPreviewCard(value: bodyFatPreview!),
          ],
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: canSave ? onSave : null,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Сохранить параметры'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedMeasurementContent extends StatelessWidget {
  const _SavedMeasurementContent({
    required this.measurement,
    required this.freshBodyFat,
  });

  final BodyMeasurement measurement;
  final double? freshBodyFat;

  @override
  Widget build(BuildContext context) {
    final bodyFat = freshBodyFat ?? measurement.bodyFatPercent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Параметры за сегодня сохранены',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  'Следующий ввод будет доступен завтра.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: AppSpacing.lg),
                _BodyFatResultCard(value: bodyFat),
                const SizedBox(height: AppSpacing.lg),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final twoColumns = constraints.maxWidth >= 360;
                    final cards = [
                      _MetricTile(
                        label: 'Вес',
                        value: measurement.weightKg.toStringAsFixed(1),
                        unit: 'кг',
                        icon: Icons.accessibility_new_outlined,
                      ),
                      _MetricTile(
                        label: 'Шея',
                        value: measurement.neckCm.toStringAsFixed(1),
                        unit: 'см',
                        icon: Icons.straighten_outlined,
                      ),
                      _MetricTile(
                        label: 'Талия',
                        value: measurement.waistCm.toStringAsFixed(1),
                        unit: 'см',
                        icon: Icons.straighten_outlined,
                      ),
                      _MetricTile(
                        label: 'Бедра',
                        value: measurement.hipsCm.toStringAsFixed(1),
                        unit: 'см',
                        icon: Icons.straighten,
                      ),
                    ];

                    if (!twoColumns) {
                      return Column(
                        children: [
                          for (var i = 0; i < cards.length; i++) ...[
                            cards[i],
                            if (i != cards.length - 1)
                              const SizedBox(height: AppSpacing.sm),
                          ],
                        ],
                      );
                    }

                    return GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: AppSpacing.sm,
                      crossAxisSpacing: AppSpacing.sm,
                      childAspectRatio: 2.7,
                      children: cards,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _BodyInputField extends StatelessWidget {
  const _BodyInputField({
    required this.controller,
    required this.label,
    required this.suffix,
    required this.icon,
  });

  final TextEditingController controller;
  final String label;
  final String suffix;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        suffixText: suffix,
      ),
      validator: Validators.positiveNumber,
    );
  }
}

Color _bodyFatColor(BuildContext context, double value) {
  final colors = Theme.of(context).colorScheme;
  final t = ((value - 10.0) / 25.0).clamp(0.0, 1.0).toDouble();

  return Color.lerp(
    colors.primaryContainer.withValues(alpha: 0.82),
    const Color(0xFFFFF2B8).withValues(alpha: 0.92),
    t,
  )!;
}

Color _bodyFatBorderColor(BuildContext context, double value) {
  final colors = Theme.of(context).colorScheme;
  final t = ((value - 10.0) / 25.0).clamp(0.0, 1.0).toDouble();

  return Color.lerp(
    colors.primary.withValues(alpha: 0.18),
    const Color(0xFFE6C85C).withValues(alpha: 0.34),
    t,
  )!;
}

class _BodyFatPreviewCard extends StatelessWidget {
  const _BodyFatPreviewCard({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        constraints: const BoxConstraints(
          minWidth: 190,
          maxWidth: 260,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          color: _bodyFatColor(context, value),
          border: Border.all(
            color: _bodyFatBorderColor(context, value),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Предварительный % жира',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onPrimaryContainer.withValues(alpha: 0.74),
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '${value.toStringAsFixed(2)}%',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BodyFatResultCard extends StatelessWidget {
  const _BodyFatResultCard({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        constraints: const BoxConstraints(
          minWidth: 170,
          maxWidth: 230,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          color: _bodyFatColor(context, value),
          border: Border.all(
            color: _bodyFatBorderColor(context, value),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '% жира',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onPrimaryContainer.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              '${value.toStringAsFixed(2)}%',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
  });

  final String label;
  final String value;
  final String unit;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.64),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border:
            Border.all(color: colors.outlineVariant.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                ),
                Text.rich(
                  TextSpan(
                    text: value,
                    children: [
                      TextSpan(
                        text: ' $unit',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
