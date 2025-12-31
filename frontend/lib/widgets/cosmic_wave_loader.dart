import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/design_tokens.dart';

/// A cosmic wave loader animation for playlist generation.
/// Based on the design mockup: design-mockups/animations/playlist_animation.jsx
class CosmicWaveLoader extends StatefulWidget {
  const CosmicWaveLoader({super.key});

  @override
  State<CosmicWaveLoader> createState() => _CosmicWaveLoaderState();
}

class _CosmicWaveLoaderState extends State<CosmicWaveLoader>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _pulseController;
  late AnimationController _orbitController;
  late AnimationController _progressController;
  
  int _currentMessageIndex = 0;
  final List<String> _loadingMessages = [
    "Reading your stars...",
    "Translating frequencies...",
    "Mapping cosmic rhythms...",
    "Aligning sound waves...",
    "Curating your vibe...",
  ];

  @override
  void initState() {
    super.initState();
    
    // Wave animation - 1.5s and 2s cycle
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    
    // Pulse animation - 1s cycle
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    // Orbit animation - variable duration for each orbiting note
    _orbitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
    
    // Progress bar animation - 5s cycle
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    )..repeat();
    
    // Rotate through loading messages every 2.5s
    _startMessageRotation();
  }

  void _startMessageRotation() {
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        setState(() {
          _currentMessageIndex = (_currentMessageIndex + 1) % _loadingMessages.length;
        });
        _startMessageRotation();
      }
    });
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    _orbitController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Wave and orb container - Flexible scale
            LayoutBuilder(
              builder: (context, constraints) {
                // Determine optimal size based on available space
                final availableWidth = constraints.maxWidth;
                final size = availableWidth > 200 ? 200.0 : availableWidth;
                
                return SizedBox(
                  width: size,
                  height: size * 0.75, // Aspect ratio 4:3
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Animated waves
                      AnimatedBuilder(
                        animation: _waveController,
                        builder: (context, child) {
                          return CustomPaint(
                            size: Size(size, size * 0.5),
                            painter: _WavePainter(
                              progress: _waveController.value,
                            ),
                          );
                        },
                      ),
                      
                      // Center pulsing note
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          final scale = 1.0 + (_pulseController.value * 0.4);
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              width: size * 0.3, // Proportional size
                              height: size * 0.3,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.electricYellow,
                                    AppColors.hotPink,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.electricYellow.withAlpha(64),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '♪',
                                  style: TextStyle(
                                    fontSize: size * 0.12, // Proportional font
                                    color: const Color(0xFF0A0A0F),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      // Orbiting music notes
                      AnimatedBuilder(
                        animation: _orbitController,
                        builder: (context, child) {
                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              _buildOrbitingNote(
                                symbol: '♪',
                                radius: size * 0.25,
                                duration: 3,
                                initialAngle: 0,
                                color: AppColors.cosmicPurple,
                                fontSize: size * 0.09,
                              ),
                              _buildOrbitingNote(
                                symbol: '♫',
                                radius: size * 0.35,
                                duration: 4,
                                initialAngle: 120,
                                color: AppColors.hotPink,
                                fontSize: size * 0.08,
                              ),
                              _buildOrbitingNote(
                                symbol: '♪',
                                radius: size * 0.45,
                                duration: 5,
                                initialAngle: 240,
                                color: const Color(0xFF00D4AA),
                                fontSize: size * 0.07,
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                );
              }
            ),
            
            const SizedBox(height: 24),
            
            // Loading message with fade animation
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Text(
                _loadingMessages[_currentMessageIndex],
                key: ValueKey<int>(_currentMessageIndex),
                textAlign: TextAlign.center,
                style: GoogleFonts.syne(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.electricYellow,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Progress bar
            AnimatedBuilder(
              animation: _progressController,
              builder: (context, child) {
                return Container(
                  width: 150,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(26),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: _progressController.value,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.electricYellow,
                              AppColors.hotPink,
                              AppColors.cosmicPurple,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrbitingNote({
    required String symbol,
    required double radius,
    required int duration,
    required double initialAngle,
    required Color color,
    required double fontSize,
  }) {
    // Calculate orbit position based on duration
    final timeOffset = _orbitController.value * (3.0 / duration);
    final angle = (initialAngle / 360.0 + timeOffset) * 2 * math.pi;
    
    final x = radius * math.cos(angle);
    final y = radius * math.sin(angle) * 0.5; // Flatten for perspective
    
    return Transform.translate(
      offset: Offset(x, y),
      child: Text(
        symbol,
        style: TextStyle(
          fontSize: fontSize,
          color: color,
          shadows: [
            Shadow(
              color: color.withAlpha(200),
              blurRadius: 8,
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for animated wave effect
class _WavePainter extends CustomPainter {
  final double progress;

  _WavePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    
    // First wave - purple to pink to yellow gradient
    final wave1Paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          AppColors.cosmicPurple,
          AppColors.hotPink,
          AppColors.electricYellow,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final wave1Path = Path();
    wave1Path.moveTo(0, centerY);
    
    for (double x = 0; x <= size.width; x += 1) {
      final amplitude = 40 * math.sin(progress * 2 * math.pi);
      final y = centerY + amplitude * math.sin((x / size.width) * 4 * math.pi);
      wave1Path.lineTo(x, y);
    }
    
    canvas.drawPath(wave1Path, wave1Paint);
    
    // Second wave - offset phase
    final wave2Paint = Paint()
      ..shader = const LinearGradient(
        colors: [
          AppColors.hotPink,
          Color(0xFF00D4AA),
          AppColors.cosmicPurple,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    
    // Lower opacity for second wave
    wave2Paint.color = wave2Paint.color.withAlpha(128);

    final wave2Path = Path();
    wave2Path.moveTo(0, centerY);
    
    final wave2Progress = (progress + 0.33) % 1.0;
    for (double x = 0; x <= size.width; x += 1) {
      final amplitude = 35 * math.sin(wave2Progress * 2 * math.pi + math.pi);
      final y = centerY + amplitude * math.sin((x / size.width) * 4 * math.pi + 0.5);
      wave2Path.lineTo(x, y);
    }
    
    canvas.drawPath(wave2Path, wave2Paint);
  }

  @override
  bool shouldRepaint(covariant _WavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
