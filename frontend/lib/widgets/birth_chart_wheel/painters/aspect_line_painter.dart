import 'dart:math';
import 'package:flutter/material.dart';
import '../../../models/birth_chart_wheel_data.dart';

/// CustomPainter for drawing aspect lines between planets.
/// 
/// Draws connecting lines with different styles based on aspect type:
/// - Solid lines for harmonious aspects
/// - Dashed lines for tense aspects
/// - Glow effect for playing aspects
class AspectLinePainter extends CustomPainter {
  final List<WheelAspectData> aspects;
  final List<WheelPlanetData> planets;
  final WheelAspectData? playingAspect;
  final double radius;
  final Offset center;
  final double animationValue;

  AspectLinePainter({
    required this.aspects,
    required this.planets,
    required this.playingAspect,
    required this.radius,
    required this.center,
    this.animationValue = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final aspect in aspects) {
      _drawAspectLine(canvas, aspect);
    }
  }

  void _drawAspectLine(Canvas canvas, WheelAspectData aspect) {
    final planet1 = planets.firstWhere((p) => p.name == aspect.planet1);
    final planet2 = planets.firstWhere((p) => p.name == aspect.planet2);

    final pos1 = WheelGeometry.getPositionOnWheel(planet1.angle, radius);
    final pos2 = WheelGeometry.getPositionOnWheel(planet2.angle, radius);

    final start = Offset(center.dx + pos1.dx, center.dy + pos1.dy);
    final end = Offset(center.dx + pos2.dx, center.dy + pos2.dy);

    final isPlaying = playingAspect != null &&
        playingAspect!.planet1 == aspect.planet1 &&
        playingAspect!.planet2 == aspect.planet2;

    // Draw glow effect first
    final glowPaint = Paint()
      ..color = aspect.color.withAlpha(isPlaying ? 102 : 51)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isPlaying ? 6 : 4
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, isPlaying ? 4 : 3);

    if (aspect.isDashed) {
      _drawDashedLine(canvas, start, end, glowPaint, aspect.type == AspectType.square ? 4 : 8);
    } else {
      canvas.drawLine(start, end, glowPaint);
    }

    // Draw main line
    final mainPaint = Paint()
      ..color = aspect.color.withValues(alpha: isPlaying ? 1.0 * animationValue : 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isPlaying ? 3 : 2
      ..strokeCap = StrokeCap.round;

    if (aspect.isDashed) {
      _drawDashedLine(canvas, start, end, mainPaint, aspect.type == AspectType.square ? 4 : 8);
    } else {
      canvas.drawLine(start, end, mainPaint);
    }
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint, double dashLength) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = sqrt(dx * dx + dy * dy);
    final dashCount = (distance / (dashLength * 2)).floor();

    if (dashCount < 1) {
      canvas.drawLine(start, end, paint);
      return;
    }

    final unitDx = dx / distance;
    final unitDy = dy / distance;
    final gap = dashLength;

    var currentX = start.dx;
    var currentY = start.dy;

    for (var i = 0; i < dashCount; i++) {
      final dashStart = Offset(currentX, currentY);
      currentX += unitDx * dashLength;
      currentY += unitDy * dashLength;
      final dashEnd = Offset(currentX, currentY);
      canvas.drawLine(dashStart, dashEnd, paint);
      currentX += unitDx * gap;
      currentY += unitDy * gap;
    }
  }

  @override
  bool shouldRepaint(covariant AspectLinePainter oldDelegate) {
    return aspects != oldDelegate.aspects ||
        playingAspect != oldDelegate.playingAspect ||
        animationValue != oldDelegate.animationValue;
  }
}
