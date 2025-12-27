import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/design_tokens.dart';
import '../../../models/birth_chart_wheel_data.dart';

/// Info card showing selected planet details and aspects.
/// 
/// Displays:
/// - Planet icon, name, sign, house
/// - Frequency, intensity, house stats
/// - List of aspects with play buttons
class PlanetInfoCard extends StatelessWidget {
  final WheelPlanetData planet;
  final List<WheelAspectData> aspects;
  final List<WheelPlanetData> allPlanets;
  final bool isPlaying;
  final WheelAspectData? playingAspect;
  final VoidCallback onPlayPause;
  final Function(WheelAspectData) onAspectTap;

  const PlanetInfoCard({
    super.key,
    required this.planet,
    required this.aspects,
    required this.allPlanets,
    required this.isPlaying,
    this.playingAspect,
    required this.onPlayPause,
    required this.onAspectTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Top colored border accent
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            height: 3,
            decoration: BoxDecoration(
              color: planet.color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header row
          _buildHeader(),
          const SizedBox(height: 16),
          
          // Stats row
          _buildStatsRow(),
          
          // Aspects list
          if (aspects.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildAspectsList(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Planet icon
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                planet.color.withOpacity(0.4),
                planet.color.withOpacity(0.15),
              ],
            ),
            border: Border.all(color: planet.color, width: 2),
          ),
          child: Center(
            child: Text(
              planet.symbol,
              style: TextStyle(fontSize: 26, color: planet.color),
            ),
          ),
        ),
        const SizedBox(width: 14),
        
        // Name and position
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                planet.name,
                style: GoogleFonts.syne(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'in ${planet.sign} • House ${planet.house}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
        
        // Play button
        _buildPlayButton(),
      ],
    );
  }

  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: onPlayPause,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isPlaying ? planet.color : Colors.white.withOpacity(0.1),
        ),
        child: Icon(
          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: isPlaying ? const Color(0xFF0A0A0F) : Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatBox('Frequency', '${planet.frequency} Hz', planet.color),
        const SizedBox(width: 12),
        _buildStatBox('Intensity', '${planet.intensity}%', Colors.white),
        const SizedBox(width: 12),
        _buildStatBox('House', '${planet.house}', Colors.white),
      ],
    );
  }

  Widget _buildStatBox(String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.white.withOpacity(0.5),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAspectsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ASPECTS',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.5),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        ...aspects.map((aspect) => _buildAspectItem(aspect)),
      ],
    );
  }

  Widget _buildAspectItem(WheelAspectData aspect) {
    final otherPlanetName = AspectCalculator.getOtherPlanet(aspect, planet.name);
    final otherPlanet = allPlanets.firstWhere((p) => p.name == otherPlanetName);
    final isAspectPlaying = playingAspect != null &&
        playingAspect!.planet1 == aspect.planet1 &&
        playingAspect!.planet2 == aspect.planet2;

    return GestureDetector(
      onTap: () => onAspectTap(aspect),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isAspectPlaying
              ? aspect.color.withOpacity(0.2)
              : Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(10),
          border: Border(
            left: BorderSide(color: aspect.color, width: 3),
          ),
        ),
        child: Row(
          children: [
            // Aspect line indicator
            SizedBox(
              width: 24,
              child: _buildAspectLineIndicator(aspect),
            ),
            const SizedBox(width: 12),
            
            // Aspect info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${aspect.name} ${otherPlanet.name}',
                    style: GoogleFonts.syne(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${otherPlanet.frequency} Hz • ${aspect.harmony}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
            
            // Play button
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isAspectPlaying
                    ? aspect.color
                    : Colors.white.withOpacity(0.1),
              ),
              child: Icon(
                isAspectPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                color: isAspectPlaying ? const Color(0xFF0A0A0F) : Colors.white,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAspectLineIndicator(WheelAspectData aspect) {
    if (aspect.isDashed) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 4, height: 2, color: aspect.color),
          const SizedBox(width: 2),
          Container(width: 4, height: 2, color: aspect.color),
          const SizedBox(width: 2),
          Container(width: 4, height: 2, color: aspect.color),
        ],
      );
    }
    return Container(
      width: 20,
      height: 2,
      decoration: BoxDecoration(
        color: aspect.color,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
