import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../models/alignment.dart';
import '../../models/birth_chart_wheel_data.dart';
import '../birth_chart_wheel/painters/wheel_painter.dart';
import '../birth_chart_wheel/painters/zodiac_icon_painter.dart';
import 'transit_wheel_planet_data.dart';
import 'transit_planet_orb.dart';

/// Transit Wheel widget displaying natal vs transit planet comparison.
/// 
/// Shows a zodiac wheel with transit planets, ghost orbs for natal positions,
/// animated arcs between natal and transit, and tappable planets for insights.
class TransitWheel extends StatefulWidget {
  final TransitAlignmentResult alignmentData;
  final TransitAlignmentPlanet? selectedPlanet;
  final ValueChanged<TransitAlignmentPlanet?>? onPlanetSelected;

  const TransitWheel({
    super.key,
    required this.alignmentData,
    this.selectedPlanet,
    this.onPlanetSelected,
  });

  @override
  State<TransitWheel> createState() => _TransitWheelState();
}

class _TransitWheelState extends State<TransitWheel> with SingleTickerProviderStateMixin {
  List<TransitWheelPlanetData> _planets = [];
  
  // Map of planet name to its stacking radius (for overlap handling)
  final Map<String, double> _planetRadii = {};
  
  // Animation for the arc
  late AnimationController _arcAnimController;

  // Wheel dimensions (matching birth chart for consistency)
  static const double wheelSize = 340;
  static const double outerRadius = 165;
  static const double signRingRadius = 145;
  static const double houseRingRadius = 105;
  static const double innerRadius = 65;
  static const double centerRadius = 50;
  static const double signIconRadius = 155;
  static const double arcRadius = 85;
  
  // Planet radii for stacking (normal, inner, outer)
  static const double planetRadiusNormal = 100;
  static const double planetRadiusInner = 80;
  static const double planetRadiusOuter = 120;
  static const double overlapThreshold = 20.0; // degrees

  @override
  void initState() {
    super.initState();
    _arcAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _buildPlanetData();
  }

  @override
  void dispose() {
    _arcAnimController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(TransitWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.alignmentData != widget.alignmentData) {
      _buildPlanetData();
    }
  }

  void _buildPlanetData() {
    _planets = widget.alignmentData.planets.map((planet) {
      return TransitWheelPlanetData.fromTransitAlignmentPlanet(planet);
    }).toList();
    
    _assignStackingRadii();
  }

  /// Assign stacking radii to planets that are close together.
  void _assignStackingRadii() {
    // Sort planets by angle for easier comparison
    final sortedPlanets = List<TransitWheelPlanetData>.from(_planets);
    sortedPlanets.sort((a, b) => a.angle.compareTo(b.angle));
    
    _planetRadii.clear();
    
    for (var i = 0; i < sortedPlanets.length; i++) {
      final planet = sortedPlanets[i];
      var assignedRadius = planetRadiusNormal;
      
      // Check for nearby planets that already have assigned radii
      for (var j = 0; j < i; j++) {
        final other = sortedPlanets[j];
        final distance = _angularDistance(planet.angle, other.angle);
        
        if (distance < overlapThreshold) {
          // There's an overlap, find an available radius
          final usedRadius = _planetRadii[other.name] ?? planetRadiusNormal;
          
          if (usedRadius == planetRadiusNormal) {
            assignedRadius = planetRadiusInner;
          } else if (usedRadius == planetRadiusInner) {
            assignedRadius = planetRadiusOuter;
          } else {
            assignedRadius = planetRadiusNormal;
          }
        }
      }
      
      _planetRadii[planet.name] = assignedRadius;
    }
  }

  double _angularDistance(double angle1, double angle2) {
    var diff = (angle1 - angle2).abs();
    if (diff > 180) diff = 360 - diff;
    return diff;
  }

  void _handlePlanetTap(TransitAlignmentPlanet planet) {
    // Toggle selection - if same planet tapped, deselect
    if (widget.selectedPlanet?.id == planet.id) {
      widget.onPlanetSelected?.call(null);
    } else {
      widget.onPlanetSelected?.call(planet);
    }
  }

  /// Find the original TransitAlignmentPlanet from the planet data name.
  TransitAlignmentPlanet? _findAlignmentPlanet(String planetName) {
    try {
      return widget.alignmentData.planets.firstWhere((p) => p.name == planetName);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Transit Wheel
        SizedBox(
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
              
              // Gap/Resonance arc between natal and transit (when selected)
              if (widget.selectedPlanet != null)
                _buildAlignmentArc(),
              
              // Ghost orb for natal position (when selected)
              if (widget.selectedPlanet != null)
                _buildNatalGhostOrb(),
              
              // Center display
              _buildCenterDisplay(),
              
              // Transit planet orbs
              ..._buildPlanetOrbs(),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildZodiacIcons() {
    return ZodiacSignData.allSigns.asMap().entries.map((entry) {
      final index = entry.key;
      final sign = entry.value;
      final angle = index * 30 + 15; // Center of each 30° segment
      final position = WheelGeometry.getPositionOnWheel(angle.toDouble(), signIconRadius);
      
      return Positioned(
        left: wheelSize / 2 + position.dx - 10,
        top: wheelSize / 2 + position.dy - 10,
        child: ZodiacIcon(
          sign: sign.name,
          color: sign.color,
          size: 18,
        ),
      );
    }).toList();
  }

  Widget _buildCenterDisplay() {
    final selectedPlanet = widget.selectedPlanet;

    return Container(
      width: centerRadius * 2,
      height: centerRadius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.02),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: selectedPlanet != null
            ? [
                // Selected planet symbol
                Text(
                  selectedPlanet.symbol,
                  style: TextStyle(
                    fontSize: 22,
                    color: Color(selectedPlanet.colorValue),
                  ),
                ),
                const SizedBox(height: 2),
                // Status indicator
                Text(
                  selectedPlanet.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: selectedPlanet.isGap
                        ? const Color(0xFFE84855)
                        : const Color(0xFF00D4AA),
                    fontFamily: 'Space Grotesk',
                  ),
                ),
              ]
            : [
                // Default: prompt to tap a planet
                Text(
                  'TAP A',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white.withValues(alpha: 0.3),
                    fontFamily: 'Space Grotesk',
                  ),
                ),
                Text(
                  'PLANET',
                  style: TextStyle(
                    fontSize: 9,
                    color: Colors.white.withValues(alpha: 0.3),
                    fontFamily: 'Space Grotesk',
                  ),
                ),
              ],
      ),
    );
  }

  /// Build the animated arc between natal and transit positions.
  Widget _buildAlignmentArc() {
    final selectedPlanet = widget.selectedPlanet!;
    final planetData = _planets.firstWhere(
      (p) => p.name == selectedPlanet.name,
      orElse: () => _planets.first,
    );

    return AnimatedBuilder(
      animation: _arcAnimController,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(wheelSize, wheelSize),
          painter: _AlignmentArcPainter(
            natalAngle: planetData.natalAngle ?? 0,
            transitAngle: planetData.angle,
            isGap: selectedPlanet.isGap,
            animationValue: _arcAnimController.value,
          ),
        );
      },
    );
  }

  /// Build the "ghost orb" showing natal position.
  Widget _buildNatalGhostOrb() {
    final selectedPlanet = widget.selectedPlanet!;
    final planetData = _planets.firstWhere(
      (p) => p.name == selectedPlanet.name,
      orElse: () => _planets.first,
    );

    final natalAngle = planetData.natalAngle ?? 0;
    final position = getTransitPositionOnWheel(natalAngle, arcRadius);
    final planetColor = Color(selectedPlanet.colorValue);

    return Positioned(
      left: wheelSize / 2 + position.dx - 14,
      top: wheelSize / 2 + position.dy - 14,
      child: Column(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  planetColor.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
              border: Border.all(
                color: planetColor.withValues(alpha: 0.6),
                width: 2,
                strokeAlign: BorderSide.strokeAlignInside,
              ),
            ),
            child: Center(
              child: Text(
                selectedPlanet.symbol,
                style: TextStyle(
                  fontSize: 12,
                  color: planetColor.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'YOU',
            style: TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: planetColor,
              fontFamily: 'Space Grotesk',
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPlanetOrbs() {
    return _planets.map((planet) {
      // Use stacking radius if assigned, otherwise default
      final radius = _planetRadii[planet.name] ?? planetRadiusNormal;
      final position = getTransitPositionOnWheel(planet.angle, radius);
      
      // Find the original alignment planet for tap handling
      final alignmentPlanet = _findAlignmentPlanet(planet.name);
      if (alignmentPlanet == null) return const SizedBox.shrink();
      
      final isSelected = widget.selectedPlanet?.id == alignmentPlanet.id;
      
      return Positioned(
        left: wheelSize / 2 + position.dx - 22,
        top: wheelSize / 2 + position.dy - 22,
        child: TransitPlanetOrb(
          planetName: planet.name,
          symbol: planet.symbol,
          color: planet.color,
          isRetrograde: planet.isRetrograde,
          isHighlight: planet.isHighlight,
          isSelected: isSelected,
          onTap: () => _handlePlanetTap(alignmentPlanet),
        ),
      );
    }).toList();
  }
}

/// Custom painter for the gap/resonance arc.
class _AlignmentArcPainter extends CustomPainter {
  final double natalAngle;
  final double transitAngle;
  final bool isGap;
  final double animationValue;

  _AlignmentArcPainter({
    required this.natalAngle,
    required this.transitAngle,
    required this.isGap,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 85.0;

    // Calculate arc angles (convert from wheel coordinates)
    final startAngle = (natalAngle - 90) * (math.pi / 180);
    
    // Calculate the sweep angle (shortest path)
    var diff = transitAngle - natalAngle;
    if (diff > 180) diff -= 360;
    if (diff < -180) diff += 360;
    final sweepAngle = diff * (math.pi / 180);

    final color = isGap ? const Color(0xFFE84855) : const Color(0xFF00D4AA);
    
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = isGap ? 3 : 4
      ..strokeCap = StrokeCap.round;

    if (isGap) {
      // Dashed arc for gaps with animation
      paint.strokeWidth = 3;
      final dashLength = 8.0;
      final gapLength = 6.0;
      final totalDash = dashLength + gapLength;
      
      // Animate dash offset
      final dashOffset = animationValue * totalDash;
      
      // Draw dashed arc segments
      final arcLength = sweepAngle.abs() * radius;
      var currentLength = -dashOffset;
      
      while (currentLength < arcLength) {
        if (currentLength + dashLength > 0 && currentLength < arcLength) {
          final segmentStart = math.max(0.0, currentLength);
          final segmentEnd = math.min(arcLength, currentLength + dashLength);
          
          if (segmentEnd > segmentStart) {
            final startFraction = segmentStart / arcLength;
            final endFraction = segmentEnd / arcLength;
            
            final segmentStartAngle = startAngle + sweepAngle * startFraction;
            final segmentSweepAngle = sweepAngle * (endFraction - startFraction);
            
            canvas.drawArc(
              Rect.fromCircle(center: center, radius: radius),
              segmentStartAngle,
              segmentSweepAngle,
              false,
              paint..color = color.withValues(alpha: 0.4 + 0.5 * (1 - animationValue)),
            );
          }
        }
        currentLength += totalDash;
      }
    } else {
      // Solid arc for resonance with glow effect
      // Outer glow
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.2 + 0.3 * animationValue)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        glowPaint,
      );
      
      // Main arc
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
  bool shouldRepaint(covariant _AlignmentArcPainter oldDelegate) {
    return oldDelegate.natalAngle != natalAngle ||
        oldDelegate.transitAngle != transitAngle ||
        oldDelegate.isGap != isGap ||
        oldDelegate.animationValue != animationValue;
  }
}
