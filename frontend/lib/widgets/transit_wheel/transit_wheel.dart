import 'package:flutter/material.dart';
import '../../models/alignment.dart';
import '../../models/birth_chart_wheel_data.dart';
import '../birth_chart_wheel/painters/wheel_painter.dart';
import '../birth_chart_wheel/painters/zodiac_icon_painter.dart';
import 'transit_wheel_planet_data.dart';
import 'transit_planet_orb.dart';
import 'transit_planet_popup.dart';

/// Transit Wheel widget displaying current planetary transits.
/// 
/// Shows a zodiac wheel with transit planets overlaid, retrograde badges,
/// and tappable planets that show transit meaning popups.
class TransitWheel extends StatefulWidget {
  final TransitsResult transits;
  final String? highlightPlanet; // "Today's Highlight Planet" (default: Sun)
  final VoidCallback? onPlanetTap;

  const TransitWheel({
    super.key,
    required this.transits,
    this.highlightPlanet = 'Sun',
    this.onPlanetTap,
  });

  @override
  State<TransitWheel> createState() => _TransitWheelState();
}

class _TransitWheelState extends State<TransitWheel> {
  TransitWheelPlanetData? _selectedPlanet;
  List<TransitWheelPlanetData> _planets = [];
  
  // Map of planet name to its stacking radius (for overlap handling)
  final Map<String, double> _planetRadii = {};

  // Wheel dimensions (matching birth chart for consistency)
  static const double wheelSize = 340;
  static const double outerRadius = 165;
  static const double signRingRadius = 145;
  static const double houseRingRadius = 105;
  static const double innerRadius = 65;
  static const double centerRadius = 50;
  static const double signIconRadius = 155;
  
  // Planet radii for stacking (normal, inner, outer)
  static const double planetRadiusNormal = 120;
  static const double planetRadiusInner = 95;
  static const double planetRadiusOuter = 145;
  static const double overlapThreshold = 20.0; // degrees

  @override
  void initState() {
    super.initState();
    _buildPlanetData();
  }

  @override
  void didUpdateWidget(TransitWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transits != widget.transits) {
      _buildPlanetData();
    }
  }

  void _buildPlanetData() {
    _planets = widget.transits.planets.map((transit) {
      final isHighlight = transit.name == widget.highlightPlanet;
      return TransitWheelPlanetData.fromTransitPosition(
        transit,
        isHighlight: isHighlight,
      );
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

  void _handlePlanetTap(TransitWheelPlanetData planet) {
    setState(() => _selectedPlanet = planet);
    widget.onPlanetTap?.call();
  }

  void _closePopup() {
    setState(() => _selectedPlanet = null);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Main wheel content
        Column(
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
                  
                  // Center moon phase display
                  _buildCenterDisplay(),
                  
                  // Transit planet orbs
                  ..._buildPlanetOrbs(),
                ],
              ),
            ),
          ],
        ),
        
        // Popup overlay
        if (_selectedPlanet != null)
          Positioned.fill(
            child: TransitPlanetPopup(
              planet: _selectedPlanet!,
              onClose: _closePopup,
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
    // Moon phase icon display
    final moonPlanet = widget.transits.getPlanet('Moon');
    final moonPhase = widget.transits.moonPhase;
    
    return Container(
      width: centerRadius * 2,
      height: centerRadius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.02),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.12),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _getMoonPhaseIcon(moonPhase),
            style: const TextStyle(
              fontSize: 28,
              color: Color(0xFFC0C0C0),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            moonPhase,
            style: TextStyle(
              fontSize: 9,
              color: Colors.white.withOpacity(0.5),
              fontFamily: 'Space Grotesk',
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getMoonPhaseIcon(String phase) {
    const icons = {
      'New Moon': '🌑',
      'Waxing Crescent': '🌒',
      'First Quarter': '🌓',
      'Waxing Gibbous': '🌔',
      'Full Moon': '🌕',
      'Waning Gibbous': '🌖',
      'Last Quarter': '🌗',
      'Waning Crescent': '🌘',
    };
    return icons[phase] ?? '🌙';
  }

  List<Widget> _buildPlanetOrbs() {
    return _planets.map((planet) {
      // Use stacking radius if assigned, otherwise default
      final radius = _planetRadii[planet.name] ?? planetRadiusNormal;
      final position = getTransitPositionOnWheel(planet.angle, radius);
      
      return Positioned(
        left: wheelSize / 2 + position.dx - 22,
        top: wheelSize / 2 + position.dy - 22,
        child: TransitPlanetOrb(
          planetName: planet.name,
          symbol: planet.symbol,
          color: planet.color,
          isRetrograde: planet.isRetrograde,
          isHighlight: planet.isHighlight,
          isSelected: _selectedPlanet?.name == planet.name,
          onTap: () => _handlePlanetTap(planet),
        ),
      );
    }).toList();
  }
}
