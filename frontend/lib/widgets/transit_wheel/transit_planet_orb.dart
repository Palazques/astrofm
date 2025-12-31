import 'package:flutter/material.dart';

/// Transit planet orb widget for the transit wheel.
/// 
/// Displays a planet as a circular orb with:
/// - Planet symbol in the center
/// - Outer glow to distinguish from natal planets
/// - Small red retrograde badge when planet is retrograde
/// - Highlight glow for "Today's Highlight Planet"
class TransitPlanetOrb extends StatelessWidget {
  final String planetName;
  final String symbol;
  final Color color;
  final bool isRetrograde;
  final bool isHighlight;
  final bool isSelected;
  final VoidCallback onTap;

  const TransitPlanetOrb({
    super.key,
    required this.planetName,
    required this.symbol,
    required this.color,
    required this.isRetrograde,
    this.isHighlight = false,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Main planet orb
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? [color, color.withOpacity(0.8)]
                    : [color.withOpacity(0.4), color.withOpacity(0.15)],
              ),
              border: Border.all(
                color: isSelected ? color : color.withOpacity(0.7),
                width: 2,
              ),
              boxShadow: [
                // Outer glow to distinguish as transit
                BoxShadow(
                  color: color.withOpacity(isSelected ? 0.6 : 0.25),
                  blurRadius: isHighlight ? 24 : 12,
                  spreadRadius: isHighlight ? 4 : 1,
                ),
                // Highlight glow for "Today's Highlight Planet"
                if (isHighlight)
                  BoxShadow(
                    color: const Color(0xFFFFD700).withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
              ],
            ),
            child: Center(
              child: Text(
                symbol,
                style: TextStyle(
                  fontSize: 20,
                  color: isSelected ? const Color(0xFF0A0A0F) : color,
                  shadows: isSelected
                      ? null
                      : [
                          Shadow(
                            color: color,
                            blurRadius: 10,
                          ),
                        ],
                ),
              ),
            ),
          ),
          
          // Retrograde badge (small red circle at bottom-right)
          if (isRetrograde)
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF6B6B),
                  border: Border.all(
                    color: const Color(0xFF0A0A0F),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6B6B).withOpacity(0.5),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '℞',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Planet symbol lookup helper
String getPlanetSymbol(String name) {
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
  return symbols[name] ?? '✦';
}

/// Planet color lookup helper
Color getPlanetColor(String name) {
  const colors = {
    'Sun': Color(0xFFFFD700),
    'Moon': Color(0xFFC0C0C0),
    'Mercury': Color(0xFF87CEEB),
    'Venus': Color(0xFFFF69B4),
    'Mars': Color(0xFFFF6B6B),
    'Jupiter': Color(0xFFDDA0DD),
    'Saturn': Color(0xFF8B7355),
    'Uranus': Color(0xFF40E0D0),
    'Neptune': Color(0xFF6495ED),
    'Pluto': Color(0xFF9370DB),
  };
  return colors[name] ?? const Color(0xFFAAAAAA);
}
