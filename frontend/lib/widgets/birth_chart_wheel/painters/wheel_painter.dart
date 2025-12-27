import 'dart:math';
import 'package:flutter/material.dart';

/// CustomPainter for the birth chart wheel structure.
/// 
/// Draws concentric circles, house dividers, and house numbers.
class WheelPainter extends CustomPainter {
  final double outerRadius;
  final double signRingRadius;
  final double houseRingRadius;
  final double innerRadius;
  final double centerRadius;

  WheelPainter({
    required this.outerRadius,
    required this.signRingRadius,
    required this.houseRingRadius,
    required this.innerRadius,
    required this.centerRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Draw background circles
    _drawCircle(canvas, center, outerRadius, 0.05);
    _drawCircle(canvas, center, signRingRadius, 0.08);
    _drawCircle(canvas, center, houseRingRadius, 0.05);
    _drawCircle(canvas, center, innerRadius, 0.08, fill: true, fillOpacity: 0.02);

    // Draw house dividers
    _drawHouseDividers(canvas, center);

    // Draw house numbers
    _drawHouseNumbers(canvas, center);
  }

  void _drawCircle(
    Canvas canvas,
    Offset center,
    double radius,
    double opacity, {
    bool fill = false,
    double fillOpacity = 0,
  }) {
    if (fill) {
      final fillPaint = Paint()
        ..color = Colors.white.withOpacity(fillOpacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, radius, fillPaint);
    }

    final strokePaint = Paint()
      ..color = Colors.white.withOpacity(opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius, strokePaint);
  }

  void _drawHouseDividers(Canvas canvas, Offset center) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * (pi / 180);
      final innerPoint = Offset(
        center.dx + cos(angle) * innerRadius,
        center.dy + sin(angle) * innerRadius,
      );
      final outerPoint = Offset(
        center.dx + cos(angle) * signRingRadius,
        center.dy + sin(angle) * signRingRadius,
      );
      canvas.drawLine(innerPoint, outerPoint, paint);
    }
  }

  void _drawHouseNumbers(Canvas canvas, Offset center) {
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    final numberRadius = (innerRadius + houseRingRadius) / 2;

    for (var i = 0; i < 12; i++) {
      final angle = (i * 30 + 15 - 90) * (pi / 180);
      final position = Offset(
        center.dx + cos(angle) * numberRadius,
        center.dy + sin(angle) * numberRadius,
      );

      textPainter.text = TextSpan(
        text: '${i + 1}',
        style: TextStyle(
          fontFamily: 'Space Grotesk',
          fontSize: 10,
          color: Colors.white.withOpacity(0.2),
        ),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(
          position.dx - textPainter.width / 2,
          position.dy - textPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant WheelPainter oldDelegate) {
    return outerRadius != oldDelegate.outerRadius ||
        signRingRadius != oldDelegate.signRingRadius ||
        houseRingRadius != oldDelegate.houseRingRadius ||
        innerRadius != oldDelegate.innerRadius ||
        centerRadius != oldDelegate.centerRadius;
  }
}
