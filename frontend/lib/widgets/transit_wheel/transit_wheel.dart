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
              
              // New: Render ALL active aspect arcs (filtered by 5° orb on backend)
              _buildAspectsLayer(),
              
              // Ghost orbs for natal positions of active aspects
              ..._buildNatalGhostOrbs(),
              
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

  /// Builds a layer of arcs for all active planetary aspects.
  Widget _buildAspectsLayer() {
    return AnimatedBuilder(
      animation: _arcAnimController,
      builder: (context, child) {
        return CustomPaint(
          size: const Size(wheelSize, wheelSize),
          painter: _TransitAspectsPainter(
            planets: widget.alignmentData.planets,
            animationValue: _arcAnimController.value,
            selectedPlanetId: widget.selectedPlanet?.id,
          ),
        );
      },
    );
  }

  /// Build "ghost orbs" for natal positions of planets with active aspects.
  List<Widget> _buildNatalGhostOrbs() {
    final activePlanets = widget.alignmentData.planets;
    
    return activePlanets.map((planet) {
      final isSelected = widget.selectedPlanet?.id == planet.id;
      // Only show natal ghost for selected planet OR major gaps
      if (!isSelected && planet.orb > 3.0) return const SizedBox.shrink();
      
      final planetData = _planets.firstWhere(
        (p) => p.name == planet.name,
        orElse: () => _planets.first,
      );

      final natalAngle = planetData.natalAngle ?? 0;
      final position = getTransitPositionOnWheel(natalAngle, arcRadius);
      final planetColor = Color(planet.colorValue);

      return Positioned(
        left: wheelSize / 2 + position.dx - (isSelected ? 14 : 10),
        top: wheelSize / 2 + position.dy - (isSelected ? 14 : 10),
        child: Opacity(
          opacity: isSelected ? 1.0 : 0.4,
          child: Container(
            width: isSelected ? 28 : 20,
            height: isSelected ? 28 : 20,
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
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Center(
              child: Text(
                planet.symbol,
                style: TextStyle(
                  fontSize: isSelected ? 12 : 9,
                  color: planetColor.withValues(alpha: 0.8),
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
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
                  selectedPlanet.status == 'integration' 
                    ? 'INTEGRATION' 
                    : selectedPlanet.aspectType.toUpperCase(),
                  style: TextStyle(
                    fontSize: 7,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    color: _getStatusColor(selectedPlanet),
                    fontFamily: 'Space Grotesk',
                  ),
                ),
              ]
            : [
                // Default: Major Shift indicator
                if (widget.alignmentData.isMajorLifeShift) ...[
                  const Icon(Icons.auto_awesome, size: 14, color: Color(0xFFFFD700)),
                  const SizedBox(height: 2),
                  const Text(
                    'MAJOR',
                    style: TextStyle(fontSize: 8, color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'SHIFT',
                    style: TextStyle(fontSize: 8, color: Color(0xFFFFD700), fontWeight: FontWeight.bold),
                  ),
                ] else ...[
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
              ],
      ),
    );
  }

  Color _getStatusColor(TransitAlignmentPlanet planet) {
    if (planet.isIntegration) return const Color(0xFF94A3B8); // Slate
    if (planet.isGap) return const Color(0xFFE84855); // Red
    if (planet.isAlignment) return const Color(0xFFFFD700); // Gold
    return const Color(0xFF00D4AA); // Seafoam
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

/// Enhanced Custom Painter for planetary aspects using Astro-Fidelity logic.
class _TransitAspectsPainter extends CustomPainter {
  final List<TransitAlignmentPlanet> planets;
  final double animationValue;
  final String? selectedPlanetId;

  _TransitAspectsPainter({
    required this.planets,
    required this.animationValue,
    this.selectedPlanetId,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const radius = 85.0;

    for (var planet in planets) {
      final isSelected = selectedPlanetId == planet.id;
      
      // Arc coordinates
      final natalLon = planet.natal.longitude ?? 0.0;
      final transitLon = planet.transit.longitude ?? 0.0;
      
      // Convert longitude to wheel angle (0 long = 270 deg / top of wheel)
      final startAngle = (natalLon - 90) * (math.pi / 180);
      
      var diffLon = transitLon - natalLon;
      if (diffLon > 180) diffLon -= 360;
      if (diffLon < -180) diffLon += 360;
      final sweepAngle = diffLon * (math.pi / 180);

      // Status Colors
      Color color;
      if (planet.isIntegration) {
        color = const Color(0xFF94A3B8); // Slate
      } else if (planet.isGap) {
        color = const Color(0xFFE84855); // Red
      } else if (planet.isAlignment) {
        color = const Color(0xFFFFD700); // Gold
      } else {
        color = const Color(0xFF00D4AA).withValues(alpha: 0.6); // Ghost Seafoam
      }

      final paint = Paint()
        ..color = isSelected ? color : color.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = (isSelected ? 3.5 : 1.5);

      // Handle Pulsing for tight orbs (< 1.0)
      if (planet.orb < 1.0 && (isSelected || !planet.isResonance)) {
        final pulse = (math.sin(animationValue * math.pi * 2) + 1) / 2;
        paint.strokeWidth += pulse * 2;
        if (isSelected) {
          // Inner Glow for peak
          canvas.drawArc(
            Rect.fromCircle(center: center, radius: radius),
            startAngle,
            sweepAngle,
            false,
            Paint()
              ..color = color.withValues(alpha: 0.2 * pulse)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 10
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
          );
        }
      }

      // Render Logic
      if (planet.isIntegration) {
        // Tier 4: Integration - Dashed Slate/Grey
        _drawDashedArc(canvas, center, radius, startAngle, sweepAngle, paint..strokeWidth = 1.0);
      } else if (planet.isResonance) {
        // Tier 3: Flow/Support - Thin Static Seafoam
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
          paint,
        );
      } else if (planet.isApplying && (planet.isGap || planet.isAlignment)) {
        // Tiers 1-2: Crisis/Power - Comet Trail
        _drawCometTrail(canvas, center, radius, startAngle, sweepAngle, color, isSelected, animationValue);
      } else {
        // Fallback
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
          paint,
        );
      }
    }
  }

  void _drawDashedArc(Canvas canvas, Offset center, double radius, double startAngle, double sweepAngle, Paint paint) {
    const dashLen = 4.0;
    const gapLen = 4.0;
    final totalLen = dashLen + gapLen;
    final arcLen = sweepAngle.abs() * radius;
    final count = (arcLen / totalLen).floor();
    
    for (var i = 0; i < count; i++) {
        final startFrac = (i * totalLen) / arcLen;
        final endFrac = (i * totalLen + dashLen) / arcLen;
        canvas.drawArc(
            Rect.fromCircle(center: center, radius: radius),
            startAngle + sweepAngle * startFrac,
            sweepAngle * (endFrac - startFrac),
            false,
            paint,
        );
    }
  }

  void _drawCometTrail(Canvas canvas, Offset center, double radius, double startAngle, double sweepAngle, Color color, bool isSelected, double anim) {
    // A comet trail is a gradient arc that tapers in opacity and/or width
    // The "head" is at transitAngle, "tail" is back toward natalAngle
    // However, our sweepAngle starts at natal and goes to transit.
    
    final segments = isSelected ? 20 : 10;
    final baseWidth = isSelected ? 4.0 : 2.0;
    
    for (var i = 0; i < segments; i++) {
        // Tail is at index 0 (near natal), Head is at segments-1 (near transit)
        final fraction = i / segments;
        final segmentStart = startAngle + sweepAngle * fraction;
        final segmentSweep = sweepAngle / segments;
        
        final opacity = 0.1 + (0.9 * fraction);
        final width = 0.5 + (baseWidth * fraction);
        
        canvas.drawArc(
            Rect.fromCircle(center: center, radius: radius),
            segmentStart,
            segmentSweep,
            false,
            Paint()
              ..color = color.withValues(alpha: isSelected ? opacity : opacity * 0.4)
              ..style = PaintingStyle.stroke
              ..strokeWidth = width
              ..strokeCap = StrokeCap.round,
        );
    }
    
    // Pulse the head if selected
    if (isSelected) {
        final headPos = startAngle + sweepAngle;
        final pulse = (math.sin(anim * math.pi * 4) + 1) / 2;
        canvas.drawCircle(
            Offset(center.dx + radius * math.cos(headPos), center.dy + radius * math.sin(headPos)),
            2.0 + pulse * 2.0,
            Paint()..color = color,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _TransitAspectsPainter oldDelegate) {
    return true; // Simple for now
  }
}
