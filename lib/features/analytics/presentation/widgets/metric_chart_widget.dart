import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shapeup/features/analytics/presentation/controllers/analytics_chart_controller.dart';
import 'package:shapeup/features/analytics/presentation/widgets/chart_axes_widget.dart';
import 'package:shapeup/features/analytics/presentation/widgets/period_header_widget.dart';
import 'package:shapeup/features/measurements/domain/entities/body_measurement_entity.dart';

class MetricChartWidget extends StatelessWidget {
  const MetricChartWidget({super.key, 
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
  final List<BodyMeasurementEntity> items;
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
          PeriodHeaderWidget(
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
            PeriodHeaderWidget(
              title: chartController.periodTitle(),
              onPrevious: onPreviousPeriod,
              onNext: onNextPeriod,
            ),
            Expanded(
              child: Center(
                child: SizedBox(
                  width: chartSide,
                  height: chartSide,
                  child: ChartAxesWidget(
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
