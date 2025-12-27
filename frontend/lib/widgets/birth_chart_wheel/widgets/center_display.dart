import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../models/birth_chart_wheel_data.dart';

/// Center display widget for the birth chart wheel.
/// 
/// Shows different content based on state:
/// - Idle: "Tap a planet to listen" prompt
/// - Playing planet: Waveform animation + frequency Hz
/// - Playing aspect: Combined frequencies + waveform
class CenterDisplay extends StatefulWidget {
  final WheelPlanetData? playingPlanet;
  final WheelAspectData? playingAspect;
  final List<WheelPlanetData> planets;
  final double size;

  const CenterDisplay({
    super.key,
    this.playingPlanet,
    this.playingAspect,
    required this.planets,
    this.size = 100,
  });

  @override
  State<CenterDisplay> createState() => _CenterDisplayState();
}

class _CenterDisplayState extends State<CenterDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  Color get _displayColor {
    if (widget.playingAspect != null) {
      return widget.playingAspect!.color;
    }
    if (widget.playingPlanet != null) {
      return widget.playingPlanet!.color;
    }
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = widget.playingPlanet != null || widget.playingAspect != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _displayColor.withOpacity(isPlaying ? 0.4 : 0.02),
            _displayColor.withOpacity(isPlaying ? 0.1 : 0.02),
          ],
        ),
        border: Border.all(
          color: _displayColor.withOpacity(isPlaying ? 0.5 : 0.08),
          width: 1,
        ),
      ),
      child: Center(
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    if (widget.playingAspect != null) {
      return _buildAspectContent();
    }
    if (widget.playingPlanet != null) {
      return _buildPlanetContent();
    }
    return _buildIdleContent();
  }

  Widget _buildIdleContent() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: Text(
        'Tap a planet to listen',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 11,
          color: Colors.white.withOpacity(0.4),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildPlanetContent() {
    final planet = widget.playingPlanet!;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildWaveform(planet.color),
        const SizedBox(height: 6),
        Text(
          '${planet.frequency} Hz',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: planet.color,
          ),
        ),
      ],
    );
  }

  Widget _buildAspectContent() {
    final aspect = widget.playingAspect!;
    final planet1 = widget.planets.firstWhere((p) => p.name == aspect.planet1);
    final planet2 = widget.planets.firstWhere((p) => p.name == aspect.planet2);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildWaveform(aspect.color),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${planet1.frequency}',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: aspect.color,
              ),
            ),
            Text(
              ' + ',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                color: aspect.color.withOpacity(0.5),
              ),
            ),
            Text(
              '${planet2.frequency}',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: aspect.color,
              ),
            ),
            Text(
              ' Hz',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                color: aspect.color.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWaveform(Color color) {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (i) {
            final phase = (i * 0.2 + _waveController.value) % 1.0;
            final height = 8 + (12 * (0.5 + 0.5 * (phase * 2 - 1).abs()));
            
            return Container(
              width: 3,
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }
}

/// Sound wave animation that expands from center when playing.
class SoundWaveRing extends StatelessWidget {
  final Color color;
  final double size;
  final int delayMs;
  final AnimationController controller;

  const SoundWaveRing({
    super.key,
    required this.color,
    required this.size,
    required this.controller,
    this.delayMs = 0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        // Calculate delayed animation value
        final delayProgress = delayMs / 2000;
        final adjustedValue = (controller.value - delayProgress).clamp(0.0, 1.0);
        final scale = 1.0 + (1.5 * adjustedValue);
        final opacity = (0.8 - (0.8 * adjustedValue)).clamp(0.0, 1.0);

        return Transform.scale(
          scale: scale,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(opacity),
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }
}
