import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/design_tokens.dart';
import '../../models/sonification.dart';
import '../../models/birth_chart_wheel_data.dart';
import '../birth_chart_wheel/painters/wheel_painter.dart';
import '../birth_chart_wheel/painters/zodiac_icon_painter.dart';
import '../skeleton_loader.dart';

/// Daily Sound Wheel widget for the homescreen.
/// 
/// Displays today's planetary positions on a zodiac wheel with a tappable
/// center to play/stop the day's sound signature.
class DailySoundWheel extends StatefulWidget {
  final ChartSonification? sonification;
  final bool isPlaying;
  final bool isLoading;
  final VoidCallback onPlayPressed;

  const DailySoundWheel({
    super.key,
    this.sonification,
    required this.isPlaying,
    required this.isLoading,
    required this.onPlayPressed,
  });

  @override
  State<DailySoundWheel> createState() => _DailySoundWheelState();
}

class _DailySoundWheelState extends State<DailySoundWheel>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  // Wheel dimensions (larger for homescreen visibility)
  static const double wheelSize = 340;
  static const double outerRadius = 162;
  static const double signRingRadius = 136;
  static const double houseRingRadius = 102;
  static const double innerRadius = 68;
  static const double centerRadius = 52;
  static const double signIconRadius = 148;
  static const double planetRadius = 115;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    if (widget.isPlaying) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(DailySoundWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show skeleton while loading
    if (widget.isLoading) {
      return SkeletonLoader(
        width: wheelSize,
        height: wheelSize,
        borderRadius: BorderRadius.circular(wheelSize / 2),
        color: Colors.white.withValues(alpha: 0.08),
      );
    }

    return GestureDetector(
      onTap: widget.sonification != null ? widget.onPlayPressed : null,
      child: SizedBox(
        width: wheelSize,
        height: wheelSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Base wheel structure
            CustomPaint(
              size: const Size(wheelSize, wheelSize),
              painter: WheelPainter(
                outerRadius: outerRadius,
                signRingRadius: signRingRadius,
                houseRingRadius: houseRingRadius,
                innerRadius: innerRadius,
                centerRadius: centerRadius,
              ),
            ),

            // Zodiac sign icons
            ..._buildZodiacIcons(),

            // Planet orbs (if data available)
            if (widget.sonification != null) ..._buildPlanetOrbs(),

            // Center play button
            _buildCenterDisplay(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildZodiacIcons() {
    return ZodiacSignData.allSigns.asMap().entries.map((entry) {
      final index = entry.key;
      final sign = entry.value;
      final angle = index * 30 + 15; // Center of each 30° segment
      final position = _getPositionOnWheel(angle.toDouble(), signIconRadius);

      return Positioned(
        left: wheelSize / 2 + position.dx - 8,
        top: wheelSize / 2 + position.dy - 8,
        child: ZodiacIcon(
          sign: sign.name,
          color: sign.color,
          size: 16,
        ),
      );
    }).toList();
  }

  List<Widget> _buildPlanetOrbs() {
    final sonification = widget.sonification;
    if (sonification == null) return [];

    // Calculate angles for all planets
    final planetAngles = <String, double>{};
    for (final chord in sonification.planetChords) {
      final signIndex = _getSignIndex(chord.sign);
      final angle = signIndex * 30 + (chord.houseDegree / 30 * 30);
      planetAngles[chord.planet] = angle;
    }

    // Assign stacking radii to prevent overlap
    final planetRadii = <String, double>{};
    final sortedPlanets = sonification.planetChords.toList()
      ..sort((a, b) => planetAngles[a.planet]!.compareTo(planetAngles[b.planet]!));
    
    const double radiusNormal = 115;
    const double radiusInner = 90;
    const double radiusOuter = 140;
    const double overlapThreshold = 25.0; // degrees

    for (var i = 0; i < sortedPlanets.length; i++) {
      final planet = sortedPlanets[i].planet;
      var assignedRadius = radiusNormal;

      // Check for nearby planets
      for (var j = 0; j < i; j++) {
        final other = sortedPlanets[j].planet;
        final distance = _angularDistance(planetAngles[planet]!, planetAngles[other]!);

        if (distance < overlapThreshold) {
          final usedRadius = planetRadii[other] ?? radiusNormal;
          if (usedRadius == radiusNormal) {
            assignedRadius = radiusInner;
          } else if (usedRadius == radiusInner) {
            assignedRadius = radiusOuter;
          } else {
            assignedRadius = radiusNormal;
          }
        }
      }
      planetRadii[planet] = assignedRadius;
    }

    // Build planet widgets
    return sonification.planetChords.map((chord) {
      final angle = planetAngles[chord.planet]!;
      final radius = planetRadii[chord.planet] ?? radiusNormal;
      final position = _getPositionOnWheel(angle, radius);

      return Positioned(
        left: wheelSize / 2 + position.dx - 14,
        top: wheelSize / 2 + position.dy - 14,
        child: _PlanetDot(
          symbol: _getPlanetSymbol(chord.planet),
          color: _getPlanetColor(chord.planet),
        ),
      );
    }).toList();
  }

  double _angularDistance(double angle1, double angle2) {
    var diff = (angle1 - angle2).abs();
    if (diff > 180) diff = 360 - diff;
    return diff;
  }

  Widget _buildCenterDisplay() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = widget.isPlaying ? 1.0 + (_pulseController.value * 0.1) : 1.0;
        final glowOpacity = widget.isPlaying ? 0.3 + (_pulseController.value * 0.3) : 0.0;

        return Transform.scale(
          scale: scale,
          child: Container(
            width: centerRadius * 2,
            height: centerRadius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: widget.isPlaying
                    ? [
                        AppColors.electricYellow.withValues(alpha: 0.3),
                        AppColors.cosmicPurple.withValues(alpha: 0.15),
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.12),
                        Colors.white.withValues(alpha: 0.04),
                      ],
              ),
              border: Border.all(
                color: widget.isPlaying
                    ? AppColors.electricYellow.withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.15),
                width: 1.5,
              ),
              boxShadow: widget.isPlaying
                  ? [
                      BoxShadow(
                        color: AppColors.electricYellow.withValues(alpha: glowOpacity),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  widget.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  size: 20,
                  color: widget.isPlaying
                      ? AppColors.electricYellow
                      : Colors.white.withValues(alpha: 0.7),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.isPlaying ? 'PLAYING' : 'TAP',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 7,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                    color: widget.isPlaying
                        ? AppColors.electricYellow
                        : Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Offset _getPositionOnWheel(double angleDegrees, double radius) {
    // Convert to radians, adjust for top-start orientation
    final radians = (angleDegrees - 90) * math.pi / 180;
    return Offset(
      radius * math.cos(radians),
      radius * math.sin(radians),
    );
  }

  int _getSignIndex(String sign) {
    const signs = [
      'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
      'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
    ];
    return signs.indexOf(sign).clamp(0, 11);
  }

  String _getPlanetSymbol(String planet) {
    const symbols = {
      'Sun': '☉',
      'Moon': '☽',
      'Mercury': '☿',
      'Venus': '♀',
      'Mars': '♂',
      'Jupiter': '♃',
      'Saturn': '♄',
      'Uranus': '♅',
      'Neptune': '♆',
      'Pluto': '♇',
    };
    return symbols[planet] ?? '●';
  }

  Color _getPlanetColor(String planet) {
    const colors = {
      'Sun': Color(0xFFFFD700),
      'Moon': Color(0xFFC0C0C0),
      'Mercury': Color(0xFFE5EB0D),
      'Venus': Color(0xFFFF59D0),
      'Mars': Color(0xFFFF5733),
      'Jupiter': Color(0xFF9B59B6),
      'Saturn': Color(0xFF7D67FE),
      'Uranus': Color(0xFF00D4AA),
      'Neptune': Color(0xFF3498DB),
      'Pluto': Color(0xFF8B0000),
    };
    return colors[planet] ?? Colors.white;
  }
}

/// Small planet indicator dot for the daily wheel.
class _PlanetDot extends StatelessWidget {
  final String symbol;
  final Color color;

  const _PlanetDot({
    required this.symbol,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.25),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          symbol,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ),
    );
  }
}
