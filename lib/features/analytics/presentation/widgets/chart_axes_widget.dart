import 'dart:math' as math;

import 'package:flutter/material.dart';

class ChartAxesWidget extends StatelessWidget {
  const ChartAxesWidget({super.key, 
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
