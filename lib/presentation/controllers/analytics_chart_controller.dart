import 'dart:math' as math;

import '../../domain/entities/local_entities.dart';

class AnalyticsChartPoint {
  const AnalyticsChartPoint({
    required this.label,
    required this.fullLabel,
    required this.value,
  });

  final String label;
  final String fullLabel;
  final double? value;
}

class AnalyticsChartController {
  const AnalyticsChartController({
    required this.type,
    required this.period,
    required this.periodOffset,
    required this.items,
  });

  final String type;
  final String period;
  final int periodOffset;
  final List<BodyMeasurement> items;

  static DateTime dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static DateTime weekStart(DateTime date) {
    final day = dateOnly(date);
    return day.subtract(Duration(days: day.weekday - 1));
  }

  static DateTime anchorDateForPeriod(String chartPeriod, int offset) {
    final now = DateTime.now();

    switch (chartPeriod) {
      case 'month':
        return DateTime(now.year, now.month + offset, 1);
      case 'year':
        return DateTime(now.year + offset, 1, 1);
      case 'week':
      default:
        return weekStart(now).add(Duration(days: offset * 7));
    }
  }

  static int periodOffsetForAnchor(String chartPeriod, DateTime anchor) {
    final now = DateTime.now();

    switch (chartPeriod) {
      case 'month':
        return (anchor.year - now.year) * 12 + anchor.month - now.month;
      case 'year':
        return anchor.year - now.year;
      case 'week':
      default:
        final currentWeekStart = weekStart(now);
        final selectedWeekStart = weekStart(anchor);
        return selectedWeekStart.difference(currentWeekStart).inDays ~/ 7;
    }
  }

  double value(BodyMeasurement measurement) {
    switch (type) {
      case 'bodyFat':
        return measurement.bodyFatPercent;
      case 'waist':
        return measurement.waistCm;
      case 'hips':
        return measurement.hipsCm;
      case 'neck':
        return measurement.neckCm;
      case 'weight':
      default:
        return measurement.weightKg;
    }
  }

  String yUnit() {
    switch (type) {
      case 'bodyFat':
        return '%';
      case 'weight':
        return 'кг';
      default:
        return 'см';
    }
  }

  String yAxisLabel() {
    switch (type) {
      case 'bodyFat':
        return '% жира, %';
      case 'waist':
        return 'Обхват талии, см.';
      case 'hips':
        return 'Обхват бедер, см.';
      case 'neck':
        return 'Обхват шеи, см.';
      case 'weight':
      default:
        return 'Вес, кг.';
    }
  }

  String xAxisLabel() {
    final anchor = anchorDate();

    if (period == 'week') {
      final monday = anchor;
      final sunday = monday.add(const Duration(days: 6));
      return 'День/неделя с ${shortYearDay(monday)} по ${shortYearDay(sunday)}';
    }

    if (period == 'month') {
      return 'День/${fullMonthName(anchor.month)} ${anchor.year} г.';
    }

    return 'Месяц/${anchor.year} г.';
  }

  DateTime anchorDate() {
    return anchorDateForPeriod(period, periodOffset);
  }

  String periodTitle() {
    final anchor = anchorDate();

    if (period == 'week') {
      final monday = anchor;
      final sunday = monday.add(const Duration(days: 6));
      return '${shortDay(monday)} - ${shortDay(sunday)}';
    }

    if (period == 'month') {
      return '${monthLabel(anchor.month)} ${anchor.year}';
    }

    return anchor.year.toString();
  }

  List<AnalyticsChartPoint> points() {
    switch (period) {
      case 'month':
        return _buildMonthPoints();
      case 'year':
        return _buildYearPoints();
      case 'week':
      default:
        return _buildWeekPoints();
    }
  }

  List<AnalyticsChartPoint> _buildWeekPoints() {
    final monday = anchorDate();

    final byDay = <String, BodyMeasurement>{
      for (final measurement in items) measurement.dayKey: measurement,
    };

    return List.generate(7, (index) {
      final date = monday.add(Duration(days: index));
      final key = dayKey(date);
      final measurement = byDay[key];

      return AnalyticsChartPoint(
        label: shortDay(date),
        fullLabel: fullRuDay(date),
        value: measurement == null ? null : value(measurement),
      );
    });
  }

  List<AnalyticsChartPoint> _buildMonthPoints() {
    final anchor = anchorDate();
    final start = DateTime(anchor.year, anchor.month, 1);
    final nextMonth = anchor.month == 12
        ? DateTime(anchor.year + 1, 1, 1)
        : DateTime(anchor.year, anchor.month + 1, 1);
    final lastDay = nextMonth.subtract(const Duration(days: 1)).day;

    final byDay = <String, BodyMeasurement>{
      for (final measurement in items) measurement.dayKey: measurement,
    };

    return List.generate(lastDay, (index) {
      final date = start.add(Duration(days: index));
      final key = dayKey(date);
      final measurement = byDay[key];
      final dayNumber = index + 1;
      final shouldLabel = dayNumber == 1 ||
          dayNumber == 10 ||
          dayNumber == 20 ||
          dayNumber == lastDay;

      return AnalyticsChartPoint(
        label: shouldLabel ? dayNumber.toString() : '',
        fullLabel: fullRuDay(date),
        value: measurement == null ? null : value(measurement),
      );
    });
  }

  List<AnalyticsChartPoint> _buildYearPoints() {
    final anchor = anchorDate();
    final currentYear = anchor.year;
    final points = <AnalyticsChartPoint>[];

    for (int month = 1; month <= 12; month++) {
      final monthItems = items.where((measurement) {
        final date = parseDayKey(measurement.dayKey);
        return date.year == currentYear && date.month == month;
      }).toList();

      double? avg;
      if (monthItems.isNotEmpty) {
        final sum = monthItems.fold<double>(
          0,
          (acc, measurement) => acc + value(measurement),
        );
        avg = sum / monthItems.length;
      }

      points.add(
        AnalyticsChartPoint(
          label: monthLabel(month),
          fullLabel: '${monthLabel(month)} $currentYear',
          value: avg,
        ),
      );
    }

    return points;
  }

  double niceStep(double maxValue) {
    if (maxValue <= 0) return 1;
    const desiredTicks = 4;
    final rough = maxValue / desiredTicks;
    final exponent =
        math.pow(10, (math.log(rough) / math.ln10).floor()).toDouble();
    final fraction = rough / exponent;

    double niceFraction;
    if (fraction <= 1) {
      niceFraction = 1;
    } else if (fraction <= 2) {
      niceFraction = 2;
    } else if (fraction <= 5) {
      niceFraction = 5;
    } else {
      niceFraction = 10;
    }

    return niceFraction * exponent;
  }

  double niceMax(double maxValue) {
    final step = niceStep(maxValue);
    return (maxValue / step).ceil() * step;
  }

  bool isMainYLabel({
    required double value,
    required double axisMaxY,
    required double yStep,
  }) {
    const epsilon = 0.0001;
    if (value < -epsilon || value > axisMaxY + epsilon) return false;
    if (value.abs() < epsilon) return true;
    if ((value - axisMaxY).abs() < epsilon) return true;

    final nearestStep = (value / yStep).round() * yStep;
    return (value - nearestStep).abs() < epsilon;
  }

  bool showBottomLabel(int index, int totalCount) {
    if (totalCount <= 8) return true;
    if (period == 'month') {
      return index == 0 || index == 9 || index == 19 || index == totalCount - 1;
    }
    if (period == 'year') return true;
    return index == 0 || index == totalCount ~/ 2 || index == totalCount - 1;
  }

  static DateTime parseDayKey(String dayKey) {
    final parts = dayKey.split('-');
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  static String dayKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static String shortDay(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month';
  }

  static String shortYearDay(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = (date.year % 100).toString().padLeft(2, '0');
    return '$day.$month.$year';
  }

  static String fullRuDay(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString().padLeft(4, '0');
    return '$day.$month.$year';
  }

  static String fullMonthName(int month) {
    const labels = [
      'январь',
      'февраль',
      'март',
      'апрель',
      'май',
      'июнь',
      'июль',
      'август',
      'сентябрь',
      'октябрь',
      'ноябрь',
      'декабрь',
    ];
    return labels[month - 1];
  }

  static String monthLabel(int month) {
    const labels = [
      'Янв',
      'Фев',
      'Мар',
      'Апр',
      'Май',
      'Июн',
      'Июл',
      'Авг',
      'Сен',
      'Окт',
      'Ноя',
      'Дек',
    ];
    return labels[month - 1];
  }
}
