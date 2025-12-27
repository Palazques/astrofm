import 'dart:math';
import 'package:flutter/material.dart';

/// Painter for custom zodiac icon glyphs.
/// 
/// Each zodiac sign has a distinct geometric icon drawn with thin strokes.
class ZodiacIconPainter extends CustomPainter {
  final String sign;
  final Color color;
  final double size;

  ZodiacIconPainter({
    required this.sign,
    required this.color,
    required this.size,
  });

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Scale to fit within the given size
    final scale = size / 24; // Icons designed on 24x24 viewBox
    canvas.scale(scale, scale);

    switch (sign) {
      case 'Aries':
        _drawAries(canvas, paint);
        break;
      case 'Taurus':
        _drawTaurus(canvas, paint);
        break;
      case 'Gemini':
        _drawGemini(canvas, paint);
        break;
      case 'Cancer':
        _drawCancer(canvas, paint);
        break;
      case 'Leo':
        _drawLeo(canvas, paint);
        break;
      case 'Virgo':
        _drawVirgo(canvas, paint);
        break;
      case 'Libra':
        _drawLibra(canvas, paint);
        break;
      case 'Scorpio':
        _drawScorpio(canvas, paint);
        break;
      case 'Sagittarius':
        _drawSagittarius(canvas, paint);
        break;
      case 'Capricorn':
        _drawCapricorn(canvas, paint);
        break;
      case 'Aquarius':
        _drawAquarius(canvas, paint);
        break;
      case 'Pisces':
        _drawPisces(canvas, paint);
        break;
    }
  }

  void _drawAries(Canvas canvas, Paint paint) {
    final path = Path();
    // Vertical line
    path.moveTo(12, 20);
    path.lineTo(12, 6);
    canvas.drawPath(path, paint);
    
    // Left horn
    final leftHorn = Path();
    leftHorn.moveTo(12, 6);
    leftHorn.cubicTo(12, 6, 12, 3, 9, 3);
    leftHorn.cubicTo(6, 3, 5, 5, 5, 7);
    leftHorn.cubicTo(5, 9, 7, 10, 7, 10);
    canvas.drawPath(leftHorn, paint);
    
    // Right horn
    final rightHorn = Path();
    rightHorn.moveTo(12, 6);
    rightHorn.cubicTo(12, 6, 12, 3, 15, 3);
    rightHorn.cubicTo(18, 3, 19, 5, 19, 7);
    rightHorn.cubicTo(19, 9, 17, 10, 17, 10);
    canvas.drawPath(rightHorn, paint);
  }

  void _drawTaurus(Canvas canvas, Paint paint) {
    // Circle
    canvas.drawCircle(const Offset(12, 15), 6, paint);
    
    // Left horn
    final leftHorn = Path();
    leftHorn.moveTo(6, 6);
    leftHorn.cubicTo(6, 6, 6, 9, 9, 9);
    canvas.drawPath(leftHorn, paint);
    
    // Right horn
    final rightHorn = Path();
    rightHorn.moveTo(18, 6);
    rightHorn.cubicTo(18, 6, 18, 9, 15, 9);
    canvas.drawPath(rightHorn, paint);
    
    // Connecting line
    canvas.drawLine(const Offset(9, 9), const Offset(15, 9), paint);
  }

  void _drawGemini(Canvas canvas, Paint paint) {
    // Top line
    canvas.drawLine(const Offset(6, 4), const Offset(18, 4), paint);
    // Bottom line
    canvas.drawLine(const Offset(6, 20), const Offset(18, 20), paint);
    // Left vertical
    canvas.drawLine(const Offset(9, 4), const Offset(9, 20), paint);
    // Right vertical
    canvas.drawLine(const Offset(15, 4), const Offset(15, 20), paint);
  }

  void _drawCancer(Canvas canvas, Paint paint) {
    // Upper curl
    final upper = Path();
    upper.moveTo(19, 8);
    upper.cubicTo(19, 8, 19, 5, 16, 5);
    upper.cubicTo(13, 5, 13, 8, 13, 8);
    upper.cubicTo(13, 8, 13, 11, 16, 11);
    canvas.drawPath(upper, paint);
    
    // Lower curl
    final lower = Path();
    lower.moveTo(5, 16);
    lower.cubicTo(5, 16, 5, 19, 8, 19);
    lower.cubicTo(11, 19, 11, 16, 11, 16);
    lower.cubicTo(11, 16, 11, 13, 8, 13);
    canvas.drawPath(lower, paint);
    
    // Connecting lines
    canvas.drawLine(const Offset(16, 11), const Offset(8, 11), paint);
    canvas.drawLine(const Offset(8, 13), const Offset(16, 13), paint);
  }

  void _drawLeo(Canvas canvas, Paint paint) {
    // Circle
    canvas.drawCircle(const Offset(9, 9), 4, paint);
    
    // Tail
    final tail = Path();
    tail.moveTo(13, 9);
    tail.cubicTo(13, 9, 15, 9, 17, 11);
    tail.cubicTo(19, 13, 19, 17, 17, 19);
    tail.cubicTo(15, 21, 13, 19, 13, 17);
    tail.cubicTo(13, 15, 15, 15, 15, 15);
    canvas.drawPath(tail, paint);
  }

  void _drawVirgo(Canvas canvas, Paint paint) {
    // Main curved body
    final body = Path();
    body.moveTo(5, 4);
    body.lineTo(5, 16);
    body.cubicTo(5, 16, 5, 20, 9, 20);
    canvas.drawPath(body, paint);
    
    final middle = Path();
    middle.moveTo(5, 10);
    middle.cubicTo(5, 10, 5, 6, 9, 6);
    middle.cubicTo(13, 6, 9, 14, 9, 14);
    middle.cubicTo(9, 14, 9, 10, 13, 10);
    middle.cubicTo(17, 10, 13, 18, 13, 18);
    canvas.drawPath(middle, paint);
    
    // Right vertical with curl
    final right = Path();
    right.moveTo(17, 4);
    right.lineTo(17, 16);
    right.cubicTo(17, 16, 17, 20, 21, 18);
    canvas.drawPath(right, paint);
    
    // Small diagonal
    canvas.drawLine(const Offset(19, 14), const Offset(21, 12), paint);
  }

  void _drawLibra(Canvas canvas, Paint paint) {
    // Bottom lines
    canvas.drawLine(const Offset(5, 17), const Offset(19, 17), paint);
    canvas.drawLine(const Offset(5, 20), const Offset(19, 20), paint);
    
    // Middle vertical
    canvas.drawLine(const Offset(12, 17), const Offset(12, 10), paint);
    
    // Top arc
    final arc = Path();
    arc.moveTo(7, 10);
    arc.cubicTo(7, 7, 9, 5, 12, 5);
    arc.cubicTo(15, 5, 17, 7, 17, 10);
    canvas.drawPath(arc, paint);
  }

  void _drawScorpio(Canvas canvas, Paint paint) {
    // Curved M shape
    final body = Path();
    body.moveTo(4, 4);
    body.lineTo(4, 16);
    body.cubicTo(4, 16, 4, 20, 8, 20);
    canvas.drawPath(body, paint);
    
    final middle = Path();
    middle.moveTo(4, 10);
    middle.cubicTo(4, 10, 4, 6, 8, 6);
    middle.cubicTo(12, 6, 8, 14, 8, 14);
    middle.cubicTo(8, 14, 8, 10, 12, 10);
    middle.cubicTo(16, 10, 12, 18, 12, 18);
    canvas.drawPath(middle, paint);
    
    // Right tail with arrow
    final tail = Path();
    tail.moveTo(16, 4);
    tail.lineTo(16, 18);
    tail.cubicTo(16, 18, 16, 20, 19, 20);
    canvas.drawPath(tail, paint);
    
    // Arrow
    canvas.drawLine(const Offset(19, 20), const Offset(21, 18), paint);
    canvas.drawLine(const Offset(19, 20), const Offset(21, 22), paint);
  }

  void _drawSagittarius(Canvas canvas, Paint paint) {
    // Main diagonal arrow
    canvas.drawLine(const Offset(5, 19), const Offset(19, 5), paint);
    
    // Arrow head
    canvas.drawLine(const Offset(19, 5), const Offset(13, 5), paint);
    canvas.drawLine(const Offset(19, 5), const Offset(19, 11), paint);
    
    // Cross line
    canvas.drawLine(const Offset(9, 9), const Offset(15, 15), paint);
  }

  void _drawCapricorn(Canvas canvas, Paint paint) {
    // Main body
    final body = Path();
    body.moveTo(6, 4);
    body.lineTo(6, 12);
    body.cubicTo(6, 12, 6, 16, 10, 16);
    body.cubicTo(14, 16, 14, 12, 14, 12);
    body.lineTo(14, 8);
    canvas.drawPath(body, paint);
    
    // Tail with loop
    final tail = Path();
    tail.moveTo(10, 16);
    tail.cubicTo(10, 16, 10, 20, 14, 20);
    tail.cubicTo(18, 20, 18, 16, 18, 16);
    tail.cubicTo(18, 16, 18, 12, 14, 14);
    canvas.drawPath(tail, paint);
    
    // Small circle at end
    canvas.drawCircle(const Offset(18, 18), 2, paint);
  }

  void _drawAquarius(Canvas canvas, Paint paint) {
    // Top wave
    final top = Path();
    top.moveTo(4, 9);
    top.lineTo(7, 6);
    top.lineTo(10, 9);
    top.lineTo(13, 6);
    top.lineTo(16, 9);
    top.lineTo(19, 6);
    canvas.drawPath(top, paint);
    
    // Bottom wave
    final bottom = Path();
    bottom.moveTo(4, 15);
    bottom.lineTo(7, 12);
    bottom.lineTo(10, 15);
    bottom.lineTo(13, 12);
    bottom.lineTo(16, 15);
    bottom.lineTo(19, 12);
    canvas.drawPath(bottom, paint);
  }

  void _drawPisces(Canvas canvas, Paint paint) {
    // Left fish
    final left = Path();
    left.moveTo(5, 4);
    left.cubicTo(5, 4, 9, 8, 9, 12);
    left.cubicTo(9, 16, 5, 20, 5, 20);
    canvas.drawPath(left, paint);
    
    // Right fish
    final right = Path();
    right.moveTo(19, 4);
    right.cubicTo(19, 4, 15, 8, 15, 12);
    right.cubicTo(15, 16, 19, 20, 19, 20);
    canvas.drawPath(right, paint);
    
    // Connecting line
    canvas.drawLine(const Offset(5, 12), const Offset(19, 12), paint);
  }

  @override
  bool shouldRepaint(covariant ZodiacIconPainter oldDelegate) {
    return sign != oldDelegate.sign ||
        color != oldDelegate.color ||
        size != oldDelegate.size;
  }
}

/// Widget wrapper for ZodiacIconPainter.
class ZodiacIcon extends StatelessWidget {
  final String sign;
  final Color color;
  final double size;

  const ZodiacIcon({
    super.key,
    required this.sign,
    required this.color,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: ZodiacIconPainter(
        sign: sign,
        color: color,
        size: size,
      ),
    );
  }
}
