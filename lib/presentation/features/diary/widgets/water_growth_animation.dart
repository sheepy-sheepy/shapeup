import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/design.dart';

class WaterGrowthAnimation extends StatefulWidget {
  const WaterGrowthAnimation({
    super.key,
    required this.progress,
    required this.waveTrigger,
    this.height = 136,
  });

  final double progress;
  final int waveTrigger;
  final double height;

  @override
  State<WaterGrowthAnimation> createState() => _WaterGrowthAnimationState();
}

class _WaterGrowthAnimationState extends State<WaterGrowthAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1050),
    );
  }

  @override
  void didUpdateWidget(covariant WaterGrowthAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.waveTrigger != widget.waveTrigger) {
      _waveController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final targetProgress = widget.progress.clamp(0.0, 1.0).toDouble();
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, _) {
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(end: targetProgress),
          duration: const Duration(milliseconds: 720),
          curve: Curves.easeOutCubic,
          builder: (context, animatedProgress, _) {
            final waveT = _waveController.value;
            final waveStrength = math.sin(waveT * math.pi).clamp(0.0, 1.0);

            return RepaintBoundary(
              child: SizedBox(
                height: widget.height,
                width: double.infinity,
                child: CustomPaint(
                  painter: _WaterGrowthPainter(
                    progress: animatedProgress,
                    wavePhase: waveT,
                    waveStrength: waveStrength.toDouble(),
                    primaryColor: colorScheme.primary,
                    outlineColor: colorScheme.outlineVariant,
                    surfaceColor: colorScheme.surface,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _WaterGrowthPainter extends CustomPainter {
  const _WaterGrowthPainter({
    required this.progress,
    required this.wavePhase,
    required this.waveStrength,
    required this.primaryColor,
    required this.outlineColor,
    required this.surfaceColor,
  });

  final double progress;
  final double wavePhase;
  final double waveStrength;
  final Color primaryColor;
  final Color outlineColor;
  final Color surfaceColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Индикатор воды специально меньше общей области рисования.
    // Лианы и цветы идут вокруг рамки снаружи, поэтому не попадают в воду.
    final waterArea = RRect.fromRectAndRadius(
      Rect.fromLTWH(24, 15, size.width - 48, size.height - 30),
      const Radius.circular(AppRadius.lg),
    );

    _paintOutsideVines(canvas, size, waterArea.outerRect);
    _paintCardBase(canvas, waterArea);

    canvas.save();
    canvas.clipRRect(waterArea);
    _paintWater(canvas, waterArea.outerRect);
    _paintSoftHighlights(canvas, waterArea.outerRect);
    canvas.restore();

    _paintFrame(canvas, waterArea);
  }

  void _paintCardBase(Canvas canvas, RRect waterArea) {
    final basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.74),
          surfaceColor.withValues(alpha: 0.54),
        ],
      ).createShader(waterArea.outerRect);

    canvas.drawRRect(waterArea, basePaint);
  }

  void _paintWater(Canvas canvas, Rect rect) {
    final fillHeight = rect.height * progress;
    final fillTop = rect.bottom - fillHeight;
    final amplitude = waveStrength <= 0.001 ? 0.0 : 3.0 + (progress * 4.0);
    final phase = wavePhase * math.pi * 4.0;

    final waterPath = Path()..moveTo(rect.left, rect.bottom);
    waterPath.lineTo(rect.left, fillTop);

    for (var x = rect.left; x <= rect.right + 2; x += 3) {
      final relativeX = (x - rect.left) / rect.width;
      final wave1 = math.sin(relativeX * math.pi * 2.0 + phase);
      final wave2 = math.sin(relativeX * math.pi * 4.0 - phase * 0.72);
      final y = fillTop + ((wave1 * amplitude) + (wave2 * amplitude * 0.34));
      waterPath.lineTo(x, y);
    }

    waterPath.lineTo(rect.right, rect.bottom);
    waterPath.close();

    final waterPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF90CAF9).withValues(alpha: 0.84),
          const Color(0xFF42A5F5).withValues(alpha: 0.80),
          const Color(0xFF1E88E5).withValues(alpha: 0.78),
        ],
      ).createShader(rect);

    canvas.drawPath(waterPath, waterPaint);

    final edgePaint = Paint()
      ..color = Colors.white.withValues(alpha: waveStrength > 0 ? 0.74 : 0.54)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.7
      ..strokeCap = StrokeCap.round;

    final edgePath = Path()..moveTo(rect.left, fillTop);
    for (var x = rect.left; x <= rect.right + 2; x += 3) {
      final relativeX = (x - rect.left) / rect.width;
      final wave1 = math.sin(relativeX * math.pi * 2.0 + phase);
      final wave2 = math.sin(relativeX * math.pi * 4.0 - phase * 0.72);
      final y = fillTop + ((wave1 * amplitude) + (wave2 * amplitude * 0.34));
      edgePath.lineTo(x, y);
    }
    canvas.drawPath(edgePath, edgePaint);
  }

  void _paintSoftHighlights(Canvas canvas, Rect rect) {
    if (progress <= 0.02) return;

    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    final phase = wavePhase * math.pi * 3.0;
    for (var i = 0; i < 3; i++) {
      final baseY = rect.bottom - rect.height * (0.20 + i * 0.18) * progress;
      if (baseY < rect.top || baseY > rect.bottom) continue;

      final path = Path()..moveTo(rect.left + 18, baseY);
      for (var x = rect.left + 18; x <= rect.right - 18; x += 5) {
        final relativeX = (x - rect.left) / rect.width;
        final y = baseY +
            math.sin(relativeX * math.pi * 2.2 + phase + i) *
                1.5 *
                waveStrength;
        path.lineTo(x, y);
      }
      canvas.drawPath(path, highlightPaint);
    }
  }

  void _paintFrame(Canvas canvas, RRect waterArea) {
    final framePaint = Paint()
      ..color = outlineColor.withValues(alpha: 0.66)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawRRect(waterArea, framePaint);
  }

  void _paintOutsideVines(Canvas canvas, Size size, Rect frame) {
    final freshness = ((progress - 0.18) / 0.82).clamp(0.0, 1.0).toDouble();
    final flowerOpen = ((progress - 0.46) / 0.54).clamp(0.0, 1.0).toDouble();
    final budFreshness = ((progress - 0.28) / 0.72).clamp(0.0, 1.0).toDouble();

    final vineColor = Color.lerp(
      const Color(0xFF8D6E63),
      const Color(0xFF2E7D32),
      freshness,
    )!;
    final leafColor = Color.lerp(
      const Color(0xFFBCAAA4),
      const Color(0xFF66BB6A),
      freshness,
    )!;
    final flowerColor = Color.lerp(
      const Color(0xFFD7CCC8),
      const Color(0xFFF48FB1),
      budFreshness,
    )!;

    final vinePaint = Paint()
      ..color = vineColor.withValues(alpha: 0.92)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final leftX = frame.left - 10;
    final rightX = frame.right + 10;
    final topY = frame.top - 6;
    final bottomY = frame.bottom + 6;

    final leftPath = Path()
      ..moveTo(leftX, bottomY)
      ..cubicTo(leftX - 11, frame.bottom - frame.height * 0.20, leftX + 7,
          frame.bottom - frame.height * 0.35, leftX - 2, frame.center.dy)
      ..cubicTo(leftX - 10, frame.top + frame.height * 0.34, leftX + 7,
          frame.top + frame.height * 0.20, leftX, topY)
      ..quadraticBezierTo(frame.left + frame.width * 0.16, topY - 8,
          frame.left + frame.width * 0.31, topY - 2);

    final rightPath = Path()
      ..moveTo(rightX, bottomY)
      ..cubicTo(rightX + 11, frame.bottom - frame.height * 0.20, rightX - 7,
          frame.bottom - frame.height * 0.35, rightX + 2, frame.center.dy)
      ..cubicTo(rightX + 10, frame.top + frame.height * 0.34, rightX - 7,
          frame.top + frame.height * 0.20, rightX, topY)
      ..quadraticBezierTo(frame.right - frame.width * 0.16, topY - 8,
          frame.right - frame.width * 0.31, topY - 2);

    final bottomPath = Path()
      ..moveTo(frame.left + frame.width * 0.18, bottomY + 2)
      ..cubicTo(frame.left + frame.width * 0.38, bottomY + 11,
          frame.right - frame.width * 0.38, bottomY + 11,
          frame.right - frame.width * 0.18, bottomY + 2);

    canvas.drawPath(leftPath, vinePaint);
    canvas.drawPath(rightPath, vinePaint);
    canvas.drawPath(bottomPath, vinePaint);

    _paintSmallCurl(
      canvas,
      center: Offset(frame.left - 6, frame.top + frame.height * 0.34),
      clockwise: true,
      color: vineColor,
    );
    _paintSmallCurl(
      canvas,
      center: Offset(frame.right + 6, frame.top + frame.height * 0.62),
      clockwise: false,
      color: vineColor,
    );

    _paintLeaves(
      canvas,
      positions: [
        Offset(frame.left - 8, frame.bottom - frame.height * 0.20),
        Offset(frame.left - 11, frame.bottom - frame.height * 0.46),
        Offset(frame.left - 7, frame.top + frame.height * 0.22),
        Offset(frame.left + frame.width * 0.22, frame.top - 3),
        Offset(frame.right + 8, frame.bottom - frame.height * 0.21),
        Offset(frame.right + 11, frame.bottom - frame.height * 0.49),
        Offset(frame.right + 7, frame.top + frame.height * 0.23),
        Offset(frame.right - frame.width * 0.22, frame.top - 3),
      ],
      leafColor: leafColor,
      growth: freshness,
    );

    _paintFlower(
      canvas,
      center: Offset(frame.left - 14, frame.bottom - frame.height * 0.34),
      open: flowerOpen,
      budFreshness: budFreshness,
      flowerColor: flowerColor,
      mirror: false,
    );
    _paintFlower(
      canvas,
      center: Offset(frame.left + frame.width * 0.33, frame.top - 11),
      open: (flowerOpen - 0.10).clamp(0.0, 1.0).toDouble(),
      budFreshness: budFreshness,
      flowerColor: flowerColor,
      mirror: false,
    );
    _paintFlower(
      canvas,
      center: Offset(frame.right + 14, frame.bottom - frame.height * 0.36),
      open: flowerOpen,
      budFreshness: budFreshness,
      flowerColor: flowerColor,
      mirror: true,
    );
    _paintFlower(
      canvas,
      center: Offset(frame.right - frame.width * 0.33, frame.top - 11),
      open: (flowerOpen - 0.10).clamp(0.0, 1.0).toDouble(),
      budFreshness: budFreshness,
      flowerColor: flowerColor,
      mirror: true,
    );
  }

  void _paintSmallCurl(
    Canvas canvas, {
    required Offset center,
    required bool clockwise,
    required Color color,
  }) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.70)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final path = Path()..moveTo(center.dx, center.dy);
    final direction = clockwise ? 1.0 : -1.0;
    for (var i = 0; i < 28; i++) {
      final t = i / 27.0;
      final angle = t * math.pi * 1.8 * direction;
      final radius = 8.0 * (1 - t);
      path.lineTo(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
    }

    canvas.drawPath(path, paint);
  }

  void _paintLeaves(
    Canvas canvas, {
    required List<Offset> positions,
    required Color leafColor,
    required double growth,
  }) {
    final scale = (0.42 + growth * 0.72).clamp(0.0, 1.14).toDouble();
    final paint = Paint()..color = leafColor.withValues(alpha: 0.88);

    for (var i = 0; i < positions.length; i++) {
      final position = positions[i];
      final mirror = i >= positions.length ~/ 2;
      final leafPath = Path();
      final width = 4.6 * scale;
      final height = 9.5 * scale;
      final dx = mirror ? -1.0 : 1.0;

      leafPath.moveTo(position.dx, position.dy);
      leafPath.cubicTo(
        position.dx + dx * width,
        position.dy - height * 0.5,
        position.dx + dx * width,
        position.dy - height,
        position.dx,
        position.dy - height * 1.15,
      );
      leafPath.cubicTo(
        position.dx - dx * width * 0.55,
        position.dy - height * 0.72,
        position.dx - dx * width * 0.48,
        position.dy - height * 0.18,
        position.dx,
        position.dy,
      );
      canvas.drawPath(leafPath, paint);
    }
  }

  void _paintFlower(
    Canvas canvas, {
    required Offset center,
    required double open,
    required double budFreshness,
    required Color flowerColor,
    required bool mirror,
  }) {
    final stemPaint = Paint()
      ..color = Color.lerp(
        const Color(0xFF8D6E63),
        const Color(0xFF43A047),
        budFreshness,
      )!.withValues(alpha: 0.88)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final stemEnd = Offset(center.dx + (mirror ? -8 : 8), center.dy + 9);
    canvas.drawLine(stemEnd, center, stemPaint);

    final budPaint = Paint()
      ..color = Color.lerp(const Color(0xFF8D6E63), flowerColor, budFreshness)!
          .withValues(alpha: 0.96);

    if (open < 0.12) {
      canvas.drawOval(
        Rect.fromCenter(center: center, width: 7, height: 10),
        budPaint,
      );
      return;
    }

    final petalPaint = Paint()..color = flowerColor.withValues(alpha: 0.94);
    final centerPaint = Paint()..color = const Color(0xFFFFD54F).withValues(alpha: 0.92);
    final petalLength = 4.0 + open * 5.0;
    final petalWidth = 2.6 + open * 2.0;

    for (var i = 0; i < 5; i++) {
      final angle = -math.pi / 2 + i * math.pi * 2 / 5;
      final petalCenter = Offset(
        center.dx + math.cos(angle) * petalLength * 0.55,
        center.dy + math.sin(angle) * petalLength * 0.55,
      );

      canvas.save();
      canvas.translate(petalCenter.dx, petalCenter.dy);
      canvas.rotate(angle);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: petalWidth,
          height: petalLength,
        ),
        petalPaint,
      );
      canvas.restore();
    }

    canvas.drawCircle(center, 2.0 + open * 0.9, centerPaint);
  }

  @override
  bool shouldRepaint(covariant _WaterGrowthPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.wavePhase != wavePhase ||
        oldDelegate.waveStrength != waveStrength ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.outlineColor != outlineColor ||
        oldDelegate.surfaceColor != surfaceColor;
  }
}
