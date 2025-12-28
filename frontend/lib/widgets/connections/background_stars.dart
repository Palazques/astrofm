import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Twinkling background stars for the constellation map.
/// Creates 80+ tiny stars with randomized positions and twinkle animation.
class BackgroundStars extends StatefulWidget {
  final int starCount;
  
  const BackgroundStars({
    super.key,
    this.starCount = 80,
  });

  @override
  State<BackgroundStars> createState() => _BackgroundStarsState();
}

class _BackgroundStarsState extends State<BackgroundStars>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Star> _stars;
  final _random = math.Random(42); // Seeded for consistency

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
    
    _stars = List.generate(widget.starCount, (_) => _Star(
      x: _random.nextDouble(),
      y: _random.nextDouble() * 0.6, // Top 60% of screen
      size: _random.nextDouble() < 0.9 ? 1.0 : 2.0,
      baseOpacity: _random.nextDouble() * 0.4 + 0.1,
      twinkleOffset: _random.nextDouble() * 2 * math.pi,
      twinkleDuration: 2 + _random.nextDouble() * 4,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: _StarsPainter(
            stars: _stars,
            animationValue: _controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Star {
  final double x;
  final double y;
  final double size;
  final double baseOpacity;
  final double twinkleOffset;
  final double twinkleDuration;

  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.baseOpacity,
    required this.twinkleOffset,
    required this.twinkleDuration,
  });
}

class _StarsPainter extends CustomPainter {
  final List<_Star> stars;
  final double animationValue;

  _StarsPainter({
    required this.stars,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;

    for (final star in stars) {
      // Calculate twinkle: oscillate between 0.3 and 0.8
      final twinklePhase = (animationValue * 2 * math.pi / star.twinkleDuration) + star.twinkleOffset;
      final twinkleFactor = (math.sin(twinklePhase) + 1) / 2; // 0 to 1
      final opacity = 0.3 + (twinkleFactor * 0.5);
      
      paint.color = Colors.white.withValues(alpha: opacity * star.baseOpacity * 2);
      
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}

/// Subtle nebula gradient overlays for the constellation background.
class NebulaOverlay extends StatelessWidget {
  const NebulaOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Purple nebula - left side
        Positioned(
          top: MediaQuery.of(context).size.height * 0.2,
          left: MediaQuery.of(context).size.width * 0.05,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFF7D67FE).withValues(alpha: 0.04),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
        // Pink nebula - right side
        Positioned(
          top: MediaQuery.of(context).size.height * 0.4,
          right: 0,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFFF59D0).withValues(alpha: 0.03),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
