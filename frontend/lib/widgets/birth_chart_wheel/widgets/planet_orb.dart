import 'package:flutter/material.dart';
import '../../../models/birth_chart_wheel_data.dart';

/// Tappable planet orb widget for the birth chart wheel.
/// 
/// Features:
/// - Circular gradient background with planet color
/// - Planet symbol (Unicode)
/// - Glow effect when selected/playing
/// - Scale animation on tap
class PlanetOrb extends StatelessWidget {
  final WheelPlanetData planet;
  final bool isSelected;
  final bool isPlaying;
  final VoidCallback onTap;

  const PlanetOrb({
    super.key,
    required this.planet,
    required this.isSelected,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isPlaying
                ? [planet.color, planet.color.withAlpha(204)]
                : [planet.color.withAlpha(77), planet.color.withAlpha(26)],
          ),
          border: Border.all(
            color: isPlaying ? planet.color : planet.color.withAlpha(153),
            width: 2,
          ),
          boxShadow: isPlaying
              ? [
                  BoxShadow(
                    color: planet.color.withAlpha(153),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Text(
            planet.symbol,
            style: TextStyle(
              fontSize: 20,
              color: isPlaying ? const Color(0xFF0A0A0F) : planet.color,
              shadows: isPlaying
                  ? null
                  : [
                      Shadow(
                        color: planet.color,
                        blurRadius: 10,
                      ),
                    ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Positioned planet orb with polar coordinate placement.
class PositionedPlanetOrb extends StatelessWidget {
  final WheelPlanetData planet;
  final double radius;
  final bool isSelected;
  final bool isPlaying;
  final VoidCallback onTap;

  const PositionedPlanetOrb({
    super.key,
    required this.planet,
    required this.radius,
    required this.isSelected,
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final position = WheelGeometry.getPositionOnWheel(planet.angle, radius);
    
    return Positioned(
      left: position.dx - 22, // Half of orb width (44/2)
      top: position.dy - 22,
      child: PlanetOrb(
        planet: planet,
        isSelected: isSelected,
        isPlaying: isPlaying,
        onTap: onTap,
      ),
    );
  }
}
