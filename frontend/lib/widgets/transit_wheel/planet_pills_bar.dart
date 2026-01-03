import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/alignment.dart';

/// Horizontal scrollable bar showing all planets with gap/resonance indicators.
/// Quick-select any planet to view its transit alignment.
class PlanetPillsBar extends StatelessWidget {
  final List<TransitAlignmentPlanet> planets;
  final TransitAlignmentPlanet? selectedPlanet;
  final ValueChanged<TransitAlignmentPlanet> onPlanetSelected;

  const PlanetPillsBar({
    super.key,
    required this.planets,
    required this.selectedPlanet,
    required this.onPlanetSelected,
  });

  // Gap red and resonance teal colors from mockup
  static const Color _gapColor = Color(0xFFE84855);
  static const Color _resonanceColor = Color(0xFF00D4AA);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: planets.map((planet) {
          final isSelected = selectedPlanet?.id == planet.id;
          final planetColor = Color(planet.colorValue);
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: _PlanetPill(
              planet: planet,
              planetColor: planetColor,
              isSelected: isSelected,
              onTap: () => onPlanetSelected(planet),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PlanetPill extends StatelessWidget {
  final TransitAlignmentPlanet planet;
  final Color planetColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanetPill({
    required this.planet,
    required this.planetColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = planet.isGap 
        ? PlanetPillsBar._gapColor 
        : PlanetPillsBar._resonanceColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected
                ? planetColor
                : Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected 
                  ? planetColor 
                  : Colors.white.withValues(alpha: 0.1),
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: planetColor.withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Planet symbol
              Text(
                planet.symbol,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected 
                      ? const Color(0xFF0A0A0F) 
                      : planetColor,
                ),
              ),
              const SizedBox(width: 6),
              // Status dot
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor,
                  boxShadow: [
                    BoxShadow(
                      color: statusColor.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Header widget showing gap and resonance counts.
class TransitAlignmentHeader extends StatelessWidget {
  final int gapCount;
  final int resonanceCount;

  const TransitAlignmentHeader({
    super.key,
    required this.gapCount,
    required this.resonanceCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Gap badge
        _CountBadge(
          count: gapCount,
          label: 'Gaps',
          color: const Color(0xFFE84855),
        ),
        const SizedBox(width: 8),
        // Resonance badge
        _CountBadge(
          count: resonanceCount,
          label: 'Resonances',
          color: const Color(0xFF00D4AA),
        ),
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  final int count;
  final String label;
  final Color color;

  const _CountBadge({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$count $label',
            style: GoogleFonts.syne(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
