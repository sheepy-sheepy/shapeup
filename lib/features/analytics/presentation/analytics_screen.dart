import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shapeup/core/shared/errors.dart';
import 'package:shapeup/core/design/ui.dart';
import 'package:shapeup/features/analytics/presentation/controllers/analytics_chart_controller.dart';
import 'package:shapeup/features/analytics/presentation/widgets/metric_chart_widget.dart';
import 'package:shapeup/features/analytics/presentation/widgets/photo_compare_widget.dart';
import 'package:shapeup/features/photos/domain/entities/progress_photo_entity.dart';
import 'package:shapeup/features/analytics/providers/analytics_provider.dart';

class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  String type = 'weight';
  String period = 'week';
  int periodOffset = 0;

  String? photoStartDay;
  String? photoEndDay;

  List<String> _photoEndOptions(List<String> allDays, String? startDay) {
    if (startDay == null) return const [];
    return allDays.where((d) => d.compareTo(startDay) > 0).toList();
  }

  List<ProgressPhotoEntity> _photosForDay(List<ProgressPhotoEntity> all, String dayKey) {
    final result = all.where((e) => e.dayKey == dayKey).toList()
      ..sort((a, b) => a.slot.compareTo(b.slot));
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final analyticsData = ref.watch(analyticsDataProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Аналитика'),
        actions: const [
          ScreenHelpAction(
            title: 'Контроль физической формы',
            message:
                'Выберите тип контроля: вес, % жира, талию, бедра, шею или фото.\n\n'
                'Для графиков выберите период: неделя, месяц или год, а затем переключайте даты стрелками.\n\n'
                'Нажмите на точку графика, чтобы увидеть дату и значение измерения.\n\n'
                'Для просмотра изменений тела по фото выберите две доступные даты.',
          ),
        ],
      ),
      body: analyticsData.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text(errorWithTitle(analyticsLoadErrorTitle, error)),
        ),
        data: (data) {
          final measurements = data.measurements;
          final photos = data.photos;

          final photoDays = photos.map((e) => e.dayKey).toSet().toList()
            ..sort();

          if (type == 'photo') {
            if (photoDays.isEmpty) {
              photoStartDay = null;
              photoEndDay = null;
            } else {
              photoStartDay ??= photoDays.first;
              if (!photoDays.contains(photoStartDay)) {
                photoStartDay = photoDays.first;
              }

              final validEndDays = _photoEndOptions(photoDays, photoStartDay);
              if (validEndDays.isEmpty) {
                photoEndDay = null;
              } else {
                if (photoEndDay == null ||
                    !validEndDays.contains(photoEndDay)) {
                  photoEndDay = validEndDays.first;
                }
              }
            }
          }

          final validPhotoEndDays = _photoEndOptions(photoDays, photoStartDay);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                initialValue: type,
                items: const [
                  DropdownMenuItem(value: 'bodyFat', child: Text('% жира')),
                  DropdownMenuItem(value: 'weight', child: Text('Вес')),
                  DropdownMenuItem(value: 'waist', child: Text('Талия')),
                  DropdownMenuItem(value: 'hips', child: Text('Бедра')),
                  DropdownMenuItem(value: 'neck', child: Text('Шея')),
                  DropdownMenuItem(value: 'photo', child: Text('Фото')),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() {
                    type = v;
                  });
                },
                decoration: const InputDecoration(labelText: 'Тип аналитики'),
              ),
              const SizedBox(height: 12),
              if (type != 'photo')
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  initialValue: period,
                  items: const [
                    DropdownMenuItem(value: 'week', child: Text('Неделя')),
                    DropdownMenuItem(value: 'month', child: Text('Месяц')),
                    DropdownMenuItem(value: 'year', child: Text('Год')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      final oldPeriod = period;

                      if ((oldPeriod == 'year' && v == 'month') ||
                          (oldPeriod == 'year' && v == 'week') ||
                          (oldPeriod == 'month' && v == 'week')) {
                        period = v;
                        periodOffset = 0;
                        return;
                      }

                      final selectedAnchor =
                          AnalyticsChartController.anchorDateForPeriod(
                        period,
                        periodOffset,
                      );
                      period = v;
                      periodOffset =
                          AnalyticsChartController.periodOffsetForAnchor(
                        v,
                        selectedAnchor,
                      );
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Период'),
                ),
              if (type == 'photo') ...[
                const SizedBox(height: 12),
                if (photoDays.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Text('Нет фото для аналитики'),
                  )
                else ...[
                  DropdownButtonFormField<String>(
                    dropdownColor: Colors.white,
                    initialValue: photoStartDay,
                    items: photoDays
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() {
                        photoStartDay = v;
                        final nextEndOptions =
                            _photoEndOptions(photoDays, photoStartDay);
                        if (photoEndDay == null ||
                            !nextEndOptions.contains(photoEndDay)) {
                          photoEndDay = nextEndOptions.isNotEmpty
                              ? nextEndOptions.first
                              : null;
                        }
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Дата начала'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    dropdownColor: Colors.white,
                    initialValue: photoEndDay,
                    items: validPhotoEndDays
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: validPhotoEndDays.isEmpty
                        ? null
                        : (v) {
                            if (v == null) return;
                            setState(() => photoEndDay = v);
                          },
                    decoration: const InputDecoration(labelText: 'Дата конца'),
                  ),
                ],
              ],
              const SizedBox(height: 20),
              if (type != 'photo')
                SizedBox(
                  height: 550,
                  child: MetricChartWidget(
                    type: type,
                    period: period,
                    periodOffset: periodOffset,
                    items: measurements,
                    onPreviousPeriod: () {
                      setState(() => periodOffset--);
                    },
                    onNextPeriod: () {
                      setState(() => periodOffset++);
                    },
                  ),
                ),
              if (type == 'photo' &&
                  photoStartDay != null &&
                  photoEndDay != null)
                PhotoCompareWidget(
                  startPhotos: _photosForDay(photos, photoStartDay!),
                  endPhotos: _photosForDay(photos, photoEndDay!),
                  startDay: photoStartDay!,
                  endDay: photoEndDay!,
                ),
            ],
          );
        },
      ),
    );
  }
}
