import 'dart:io';
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/app_errors.dart';
import '../../../core/app_ui.dart';
import '../../../domain/entities/local_entities.dart';
import '../../../domain/usecases/analytics_loader.dart';
import '../../controllers/analytics_chart_controller.dart';
import '../../state/app_refresh.dart';
import '../../widgets/photo_slot_labels.dart';

final analyticsDataProvider = FutureProvider.autoDispose<AnalyticsData>((ref) {
  ref.watch(currentDayKeyProvider);
  ref.watch(appRefreshTickProvider);

  return ref.watch(analyticsLoaderProvider).load();
});

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

  List<ProgressPhoto> _photosForDay(List<ProgressPhoto> all, String dayKey) {
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
            title: 'Аналитика',
            message:
                'Выберите тип аналитики: вес, % жира, талию, бедра, шею или фото.\n\n'
                'Для графиков выберите период: неделя, месяц или год, а затем переключайте даты стрелками.\n\n'
                'Нажмите на точку графика, чтобы увидеть дату и значение измерения.\n\n'
                'Для просмотра прогресса фото выберите две доступные даты.',
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
                  child: _MetricChart(
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
                _PhotoCompare(
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

class _MetricChart extends StatelessWidget {
  const _MetricChart({
    required this.type,
    required this.period,
    required this.periodOffset,
    required this.items,
    required this.onPreviousPeriod,
    required this.onNextPeriod,
  });

  final String type;
  final String period;
  final int periodOffset;
  final List<BodyMeasurement> items;
  final VoidCallback onPreviousPeriod;
  final VoidCallback onNextPeriod;

  @override
  Widget build(BuildContext context) {
    final chartController = AnalyticsChartController(
      type: type,
      period: period,
      periodOffset: periodOffset,
      items: items,
    );
    final points = chartController.points();
    final presentValues =
        points.where((e) => e.value != null).map((e) => e.value!).toList();

    if (presentValues.isEmpty) {
      return Column(
        children: [
          _PeriodHeader(
            title: chartController.periodTitle(),
            onPrevious: onPreviousPeriod,
            onNext: onNextPeriod,
          ),
          const SizedBox(height: 24),
          const Expanded(
            child: Center(child: Text('Нет данных за выбранный период')),
          ),
        ],
      );
    }

    final rawMaxY = presentValues.reduce(math.max);
    final axisMaxY = chartController.niceMax(rawMaxY <= 0 ? 1 : rawMaxY);
    final yStep = chartController.niceStep(axisMaxY);
    final chartEdgePaddingY = yStep * 0.16;
    final minY = -chartEdgePaddingY;
    final maxY = (axisMaxY + chartEdgePaddingY).toDouble();

    const chartLineWidth = 3.0;
    const chartDotRadius = 2.65;
    const chartTouchedDotRadius = 3.35;
    const chartEdgePaddingX = 0.35;

    final spots = <FlSpot>[
      for (int i = 0; i < points.length; i++)
        if (points[i].value != null) FlSpot(i.toDouble(), points[i].value!),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const headerHeight = 20.0;
        const bottomLabelsSpace = 20.0;
        final availableForSquare =
            constraints.maxHeight - headerHeight - bottomLabelsSpace;
        final chartSide = math.min(
          constraints.maxWidth + 40,
          availableForSquare,
        );

        const leftReserved = 30.0;

        return Column(
          children: [
            _PeriodHeader(
              title: chartController.periodTitle(),
              onPrevious: onPreviousPeriod,
              onNext: onNextPeriod,
            ),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: chartSide,
                  height: chartSide,
                  child: _ChartAxesOverlay(
                    yAxisLabel: chartController.yAxisLabel(),
                    xAxisLabel: chartController.xAxisLabel(),
                    leftReserved: leftReserved,
                    rightReserved: leftReserved,
                    bottomReserved: 36,
                    child: Padding(
                      padding: const EdgeInsets.only(right: leftReserved),
                      child: LineChart(
                        LineChartData(
                          minX: -chartEdgePaddingX,
                          maxX: (points.length - 1).toDouble() +
                              chartEdgePaddingX,
                          minY: minY,
                          maxY: maxY,
                          clipData: const FlClipData.all(),
                          backgroundColor: Colors.white,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            horizontalInterval: yStep,
                            verticalInterval: 1,
                            getDrawingHorizontalLine: (value) => FlLine(
                              color: Colors.grey.withValues(alpha: 0.12),
                              strokeWidth: 1,
                            ),
                            getDrawingVerticalLine: (value) => FlLine(
                              color: Colors.grey.withValues(alpha: 0.06),
                              strokeWidth: 1,
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.28),
                              width: 1,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: leftReserved,
                                interval: yStep,
                                getTitlesWidget: (value, meta) {
                                  if (!chartController.isMainYLabel(
                                    value: value,
                                    axisMaxY: axisMaxY,
                                    yStep: yStep,
                                  )) {
                                    return const SizedBox.shrink();
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        value.toStringAsFixed(
                                          value % 1 == 0 ? 0 : 1,
                                        ),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 36,
                                interval: 1,
                                getTitlesWidget: (value, meta) {
                                  final index = value.round();
                                  if ((value - index).abs() > 0.01 ||
                                      index < 0 ||
                                      index >= points.length) {
                                    return const SizedBox.shrink();
                                  }
                                  if (!chartController.showBottomLabel(
                                      index, points.length)) {
                                    return const SizedBox.shrink();
                                  }
                                  final label = points[index].label;
                                  if (label.isEmpty) {
                                    return const SizedBox.shrink();
                                  }

                                  return Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      label,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.black87,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          lineTouchData: LineTouchData(
                            handleBuiltInTouches: true,
                            touchTooltipData: LineTouchTooltipData(
                              tooltipRoundedRadius: 10,
                              tooltipMargin: 40,
                              tooltipPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 8,
                              ),
                              getTooltipItems: (touchedSpots) {
                                return touchedSpots.map((spot) {
                                  final index = spot.x.toInt();
                                  final point = points[index];
                                  return LineTooltipItem(
                                    '${point.fullLabel}\n${spot.y.toStringAsFixed(type == 'bodyFat' ? 2 : 1)} ${chartController.yUnit()}',
                                    const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                            getTouchedSpotIndicator: (LineChartBarData barData,
                                List<int> spotIndexes) {
                              return spotIndexes.map((index) {
                                return TouchedSpotIndicatorData(
                                  FlLine(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    strokeWidth: 1,
                                    dashArray: [4, 4],
                                  ),
                                  FlDotData(
                                    getDotPainter: (spot, percent, bar, index) {
                                      return FlDotCirclePainter(
                                        radius: chartTouchedDotRadius,
                                        color: Colors.white,
                                        strokeWidth: 1.4,
                                        strokeColor: Colors.blue,
                                      );
                                    },
                                  ),
                                );
                              }).toList();
                            },
                          ),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              curveSmoothness: 0.18,
                              preventCurveOverShooting: true,
                              preventCurveOvershootingThreshold: 4.0,
                              barWidth: chartLineWidth,
                              color: Colors.blue,
                              isStrokeCapRound: true,
                              dotData: FlDotData(
                                show: true,
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: chartDotRadius,
                                    color: Colors.blue,
                                    strokeWidth: 1.0,
                                    strokeColor: Colors.white,
                                  );
                                },
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.blue.withValues(alpha: 0.28),
                                    Colors.blue.withValues(alpha: 0.10),
                                    Colors.blue.withValues(alpha: 0.02),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ChartAxesOverlay extends StatelessWidget {
  const _ChartAxesOverlay({
    required this.yAxisLabel,
    required this.xAxisLabel,
    required this.leftReserved,
    required this.rightReserved,
    required this.bottomReserved,
    required this.child,
  });

  final String yAxisLabel;
  final String xAxisLabel;
  final double leftReserved;
  final double rightReserved;
  final double bottomReserved;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _ChartAxesPainter(
        yAxisLabel: yAxisLabel,
        xAxisLabel: xAxisLabel,
        leftReserved: leftReserved,
        rightReserved: rightReserved,
        bottomReserved: bottomReserved,
      ),
      child: child,
    );
  }
}

class _ChartAxesPainter extends CustomPainter {
  const _ChartAxesPainter({
    required this.yAxisLabel,
    required this.xAxisLabel,
    required this.leftReserved,
    required this.rightReserved,
    required this.bottomReserved,
  });

  final String yAxisLabel;
  final String xAxisLabel;
  final double leftReserved;
  final double rightReserved;
  final double bottomReserved;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= leftReserved + rightReserved + 20 ||
        size.height <= bottomReserved + 20) {
      return;
    }

    final axisPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 1.1
      ..strokeCap = StrokeCap.round;

    const arrowSize = 6.0;

    final plotLeft = leftReserved;
    const plotTop = -18.0;
    final plotBottom = size.height - bottomReserved;
    final plotRight = size.width - rightReserved;

    const yAxisX = 5.0;
    const yAxisTop = plotTop;
    final yAxisBottom = plotBottom;

    final xAxisY = plotBottom + 26.0;
    final xAxisStart = plotLeft;
    final xAxisEnd = math.min(size.width + 20, plotRight + 20);

    canvas.drawLine(
      Offset(yAxisX, yAxisBottom),
      const Offset(yAxisX, yAxisTop),
      axisPaint,
    );
    canvas.drawLine(
      const Offset(yAxisX, yAxisTop),
      const Offset(yAxisX - arrowSize, yAxisTop + arrowSize),
      axisPaint,
    );
    canvas.drawLine(
      const Offset(yAxisX, yAxisTop),
      const Offset(yAxisX + arrowSize, yAxisTop + arrowSize),
      axisPaint,
    );

    canvas.drawLine(
      Offset(xAxisStart, xAxisY),
      Offset(xAxisEnd, xAxisY),
      axisPaint,
    );
    canvas.drawLine(
      Offset(xAxisEnd, xAxisY),
      Offset(xAxisEnd - arrowSize, xAxisY - arrowSize),
      axisPaint,
    );
    canvas.drawLine(
      Offset(xAxisEnd, xAxisY),
      Offset(xAxisEnd - arrowSize, xAxisY + arrowSize),
      axisPaint,
    );

    const labelStyle = TextStyle(
      fontSize: 12,
      color: Colors.black87,
      fontWeight: FontWeight.w500,
    );

    final yTextPainter = TextPainter(
      text: TextSpan(text: yAxisLabel, style: labelStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    )..layout(maxWidth: math.max(24, yAxisBottom - yAxisTop - 16));

    canvas.save();
    canvas.translate(
      yAxisX - 16,
      yAxisBottom - ((yAxisBottom - yAxisTop) - yTextPainter.width) / 2,
    );
    canvas.rotate(-math.pi / 2);
    yTextPainter.paint(canvas, Offset.zero);
    canvas.restore();

    final xTextPainter = TextPainter(
      text: TextSpan(text: xAxisLabel, style: labelStyle),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      maxLines: 2,
      ellipsis: '…',
    )..layout(maxWidth: math.max(40, xAxisEnd - xAxisStart - 8));

    xTextPainter.paint(
      canvas,
      Offset(
        xAxisStart + ((xAxisEnd - xAxisStart) - xTextPainter.width) / 2,
        xAxisY + 3,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _ChartAxesPainter oldDelegate) {
    return oldDelegate.yAxisLabel != yAxisLabel ||
        oldDelegate.xAxisLabel != xAxisLabel ||
        oldDelegate.leftReserved != leftReserved ||
        oldDelegate.rightReserved != rightReserved ||
        oldDelegate.bottomReserved != bottomReserved;
  }
}

class _PeriodHeader extends StatelessWidget {
  const _PeriodHeader({
    required this.title,
    required this.onPrevious,
    required this.onNext,
  });

  final String title;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Row(
        children: [
          IconButton(
            onPressed: onPrevious,
            icon: const Icon(Icons.chevron_left),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right),
          ),
        ],
      ),
    );
  }
}

class _PhotoCompare extends StatelessWidget {
  const _PhotoCompare({
    required this.startPhotos,
    required this.endPhotos,
    required this.startDay,
    required this.endDay,
  });

  final List<ProgressPhoto> startPhotos;
  final List<ProgressPhoto> endPhotos;
  final String startDay;
  final String endDay;

  Widget _photoCell(BuildContext context, ProgressPhoto? photo) {
    final colors = Theme.of(context).colorScheme;

    final hasPhoto = photo != null &&
        photo.localPath.isNotEmpty &&
        File(photo.localPath).existsSync();

    return AspectRatio(
      aspectRatio: 3 / 4,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface.withValues(alpha: 0.82),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.7),
              ),
            ),
            child: hasPhoto
                ? Image.file(
                    File(photo.localPath),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final startBySlot = {for (final p in startPhotos) p.slot: p};
    final endBySlot = {for (final p in endPhotos) p.slot: p};

    const orderedSlots = [1, 2, 3, 4];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                startDay,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                endDay,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...orderedSlots.map((slot) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                Text(
                  photoSlotLabel(slot),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _photoCell(context, startBySlot[slot])),
                    const SizedBox(width: 12),
                    Expanded(child: _photoCell(context, endBySlot[slot])),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
