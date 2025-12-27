import 'package:flutter/material.dart';
import '../../models/birth_chart_wheel_data.dart';
import '../../models/sonification.dart';
import '../../services/audio_service.dart';
import 'painters/wheel_painter.dart';
import 'painters/zodiac_icon_painter.dart';
import 'painters/aspect_line_painter.dart';
import 'widgets/planet_orb.dart';
import 'widgets/center_display.dart';
import 'widgets/planet_info_card.dart';

/// Interactive Birth Chart Wheel widget.
/// 
/// Displays a circular natal chart with tappable planets, aspect lines,
/// and audio playback integration.
class BirthChartWheel extends StatefulWidget {
  final ChartSonification sonification;
  final AudioService audioService;
  final Function(WheelPlanetData?)? onPlanetSelected;

  const BirthChartWheel({
    super.key,
    required this.sonification,
    required this.audioService,
    this.onPlanetSelected,
  });

  @override
  State<BirthChartWheel> createState() => _BirthChartWheelState();
}

class _BirthChartWheelState extends State<BirthChartWheel>
    with TickerProviderStateMixin {
  WheelPlanetData? _selectedPlanet;
  WheelPlanetData? _playingPlanet;
  WheelAspectData? _playingAspect;
  
  late List<WheelPlanetData> _planets;
  late List<WheelAspectData> _aspects;
  
  late AnimationController _soundWaveController;
  late AnimationController _aspectPulseController;

  // Wheel dimensions
  static const double wheelSize = 340;
  static const double outerRadius = 165;
  static const double signRingRadius = 140;
  static const double houseRingRadius = 100;
  static const double innerRadius = 60;
  static const double planetRadius = 115;
  static const double signIconRadius = 152;

  @override
  void initState() {
    super.initState();
    _buildWheelData();
    
    _soundWaveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    
    _aspectPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Listen to audio playback state
    widget.audioService.playingStream.listen((isPlaying) {
      if (!isPlaying && mounted) {
        setState(() {
          _playingPlanet = null;
          _playingAspect = null;
        });
        _soundWaveController.stop();
        _soundWaveController.reset();
      }
    });
  }

  @override
  void didUpdateWidget(BirthChartWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sonification != widget.sonification) {
      _buildWheelData();
    }
  }

  void _buildWheelData() {
    _planets = widget.sonification.planets
        .map((p) => WheelPlanetData.fromPlanetSound(p))
        .toList();
    _aspects = AspectCalculator.calculateAspects(_planets);
  }

  @override
  void dispose() {
    _soundWaveController.dispose();
    _aspectPulseController.dispose();
    super.dispose();
  }

  void _handlePlanetTap(WheelPlanetData planet) {
    if (_playingPlanet?.name == planet.name) {
      // Stop playback
      widget.audioService.stop();
      setState(() {
        _playingPlanet = null;
        _selectedPlanet = null;
        _playingAspect = null;
      });
      _soundWaveController.stop();
      _soundWaveController.reset();
    } else {
      // Start playback
      final planetSound = widget.sonification.planets
          .firstWhere((p) => p.planet == planet.name);
      widget.audioService.playSinglePlanet(planetSound);
      
      setState(() {
        _selectedPlanet = planet;
        _playingPlanet = planet;
        _playingAspect = null;
      });
      _soundWaveController.repeat();
    }
    widget.onPlanetSelected?.call(_selectedPlanet);
  }

  void _handleAspectTap(WheelAspectData aspect) {
    final isSameAspect = _playingAspect != null &&
        _playingAspect!.planet1 == aspect.planet1 &&
        _playingAspect!.planet2 == aspect.planet2;

    if (isSameAspect) {
      // Stop playback
      widget.audioService.stop();
      setState(() {
        _playingAspect = null;
        _playingPlanet = null;
      });
      _soundWaveController.stop();
      _soundWaveController.reset();
      _aspectPulseController.stop();
    } else {
      // Play both frequencies as chord
      final planet1Sound = widget.sonification.planets
          .firstWhere((p) => p.planet == aspect.planet1);
      final planet2Sound = widget.sonification.planets
          .firstWhere((p) => p.planet == aspect.planet2);
      
      // Play chord using both frequencies
      widget.audioService.playFrequencyChord(
        planet1Sound.frequency.round(),
        planet2Sound.frequency.round(),
      );
      
      setState(() {
        _playingAspect = aspect;
        _playingPlanet = null;
      });
      _soundWaveController.repeat();
      _aspectPulseController.repeat(reverse: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final aspectsForSelected = _selectedPlanet != null
        ? AspectCalculator.getAspectsForPlanet(_selectedPlanet!.name, _aspects)
        : <WheelAspectData>[];

    return Column(
      children: [
        // Birth Chart Wheel
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
                  centerRadius: 50,
                ),
              ),
              
              // Zodiac sign icons
              ..._buildZodiacIcons(),
              
              // Aspect lines (when planet selected)
              if (_selectedPlanet != null)
                CustomPaint(
                  size: const Size(wheelSize, wheelSize),
                  painter: AspectLinePainter(
                    aspects: aspectsForSelected,
                    planets: _planets,
                    playingAspect: _playingAspect,
                    radius: planetRadius,
                    center: const Offset(wheelSize / 2, wheelSize / 2),
                  ),
                ),
              
              // Sound wave rings (when playing)
              if (_playingPlanet != null) ..._buildSoundWaveRings(),
              
              // Center display
              CenterDisplay(
                playingPlanet: _playingPlanet,
                playingAspect: _playingAspect,
                planets: _planets,
                size: 100,
              ),
              
              // Planet orbs
              ..._buildPlanetOrbs(),
            ],
          ),
        ),
        
        // Planet info card (when selected)
        if (_selectedPlanet != null) ...[
          const SizedBox(height: 20),
          PlanetInfoCard(
            planet: _selectedPlanet!,
            aspects: aspectsForSelected,
            allPlanets: _planets,
            isPlaying: _playingPlanet?.name == _selectedPlanet!.name,
            playingAspect: _playingAspect,
            onPlayPause: () => _handlePlanetTap(_selectedPlanet!),
            onAspectTap: _handleAspectTap,
          ),
        ],
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
          size: 20,
        ),
      );
    }).toList();
  }

  List<Widget> _buildPlanetOrbs() {
    return _planets.map((planet) {
      final position = WheelGeometry.getPositionOnWheel(planet.angle, planetRadius);
      
      return Positioned(
        left: wheelSize / 2 + position.dx - 22,
        top: wheelSize / 2 + position.dy - 22,
        child: PlanetOrb(
          planet: planet,
          isSelected: _selectedPlanet?.name == planet.name,
          isPlaying: _playingPlanet?.name == planet.name,
          onTap: () => _handlePlanetTap(planet),
        ),
      );
    }).toList();
  }

  List<Widget> _buildSoundWaveRings() {
    final color = _playingPlanet?.color ?? Colors.white;
    return [
      AnimatedBuilder(
        animation: _soundWaveController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1 + (_soundWaveController.value * 1.5),
            child: Opacity(
              opacity: 0.8 - (_soundWaveController.value * 0.8),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
              ),
            ),
          );
        },
      ),
      AnimatedBuilder(
        animation: _soundWaveController,
        builder: (context, child) {
          final delayedValue = (_soundWaveController.value - 0.25).clamp(0.0, 1.0) / 0.75;
          return Transform.scale(
            scale: 1 + (delayedValue * 1.5),
            child: Opacity(
              opacity: 0.8 - (delayedValue * 0.8),
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 2),
                ),
              ),
            ),
          );
        },
      ),
    ];
  }
}
