import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/design_tokens.dart';

/// Empty state widget shown when user has no connections.
/// Features cosmic-themed animation with floating star particles.
class ConnectionsEmptyState extends StatefulWidget {
  final VoidCallback onAddFriend;

  const ConnectionsEmptyState({
    super.key,
    required this.onAddFriend,
  });

  @override
  State<ConnectionsEmptyState> createState() => _ConnectionsEmptyStateState();
}

class _ConnectionsEmptyStateState extends State<ConnectionsEmptyState>
    with TickerProviderStateMixin {
  late AnimationController _orbitController;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Orbital rotation animation
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
    
    // Pulse animation for central orb
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _orbitController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          // Animated orbital visualization
          SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Orbital ring
                AnimatedBuilder(
                  animation: _orbitController,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _orbitController.value * 2 * math.pi,
                      child: CustomPaint(
                        size: const Size(180, 180),
                        painter: _OrbitalRingPainter(),
                      ),
                    );
                  },
                ),
                
                // Floating star particles on orbit
                ...List.generate(5, (index) {
                  final angle = (index / 5) * 2 * math.pi;
                  return AnimatedBuilder(
                    animation: _orbitController,
                    builder: (context, child) {
                      final rotatedAngle = angle + (_orbitController.value * 2 * math.pi);
                      final radius = 75.0;
                      final x = math.cos(rotatedAngle) * radius;
                      final y = math.sin(rotatedAngle) * radius;
                      
                      return Transform.translate(
                        offset: Offset(x, y),
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getStarColor(index),
                            boxShadow: [
                              BoxShadow(
                                color: _getStarColor(index).withValues(alpha: 0.6),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
                
                // Central user orb with pulse
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppColors.cosmicPurple, AppColors.hotPink],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.cosmicPurple.withValues(alpha: 0.4),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.person_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Headline
          Text(
            'Your Friend Constellation Awaits',
            style: GoogleFonts.syne(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 12),
          
          // Subtext
          Text(
            'Connect with friends to see how your celestial paths intertwine. Build your cosmic circle and discover your alignment.',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.5),
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // CTA Button
          GestureDetector(
            onTap: widget.onAddFriend,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.cosmicPurple, AppColors.hotPink],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.hotPink.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_add_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    'Add Your First Friend',
                    style: GoogleFonts.syne(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Color _getStarColor(int index) {
    final colors = [
      AppColors.electricYellow,
      AppColors.hotPink,
      AppColors.cosmicPurple,
      AppColors.teal,
      AppColors.orange,
    ];
    return colors[index % colors.length];
  }
}

/// Custom painter for the dashed orbital ring
class _OrbitalRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    
    // Draw dashed circle
    const dashLength = 8.0;
    const gapLength = 6.0;
    final circumference = 2 * math.pi * radius;
    final dashCount = circumference / (dashLength + gapLength);
    
    for (int i = 0; i < dashCount; i++) {
      final startAngle = (i * (dashLength + gapLength)) / radius;
      final sweepAngle = dashLength / radius;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
