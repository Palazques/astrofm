import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/design_tokens.dart';
import '../../../models/birth_chart_wheel_data.dart';
import '../../../data/planet_reference_data.dart';

/// Comprehensive planet sound detail card.
///
/// Displays when a planet is tapped on the birth chart wheel, showing:
/// - Animated planet orb with play/pause
/// - Name, sign, house, degree
/// - Archetype badge and keywords
/// - Frequency and waveform type
/// - Sound description
/// - House context and meaning
/// - Harmonic connections (aspects) with meanings and sound blends
class PlanetSoundDetail extends StatefulWidget {
  final WheelPlanetData planet;
  final List<WheelAspectData> aspects;
  final List<WheelPlanetData> allPlanets;
  final bool isPlaying;
  final WheelAspectData? playingAspect;
  final VoidCallback onPlayPause;
  final Function(WheelAspectData) onAspectTap;
  final VoidCallback? onClose;

  const PlanetSoundDetail({
    super.key,
    required this.planet,
    required this.aspects,
    required this.allPlanets,
    required this.isPlaying,
    this.playingAspect,
    required this.onPlayPause,
    required this.onAspectTap,
    this.onClose,
  });

  @override
  State<PlanetSoundDetail> createState() => _PlanetSoundDetailState();
}

class _PlanetSoundDetailState extends State<PlanetSoundDetail>
    with SingleTickerProviderStateMixin {
  int? _activeAspect;
  bool _showAllAspects = false;
  late AnimationController _rippleController;

  @override
  void initState() {
    super.initState();
    _rippleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.isPlaying) {
      _rippleController.repeat();
    }
  }

  @override
  void didUpdateWidget(PlanetSoundDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying && !oldWidget.isPlaying) {
      _rippleController.repeat();
    } else if (!widget.isPlaying && oldWidget.isPlaying) {
      _rippleController.stop();
      _rippleController.reset();
    }
  }

  @override
  void dispose() {
    _rippleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Main Planet Sound Card
        _buildMainCard(),
        const SizedBox(height: 16),

        // Aspects Section
        if (widget.aspects.isNotEmpty) _buildAspectsSection(),

        // Play Full Sound Button
        const SizedBox(height: 16),
        _buildPlayFullSoundButton(),
      ],
    );
  }

  Widget _buildMainCard() {
    final planet = widget.planet;
    final archetype = planetArchetypes[planet.name] ?? 'Celestial Body';
    final keywords = planetKeywords[planet.name] ?? [];
    final waveform = planetWaveforms[planet.name] ?? 'Sonic Presence';
    final soundDescription =
        planetSoundDescriptions[planet.name] ?? 'A unique cosmic frequency.';
    final houseTheme = houseThemes[planet.house] ?? 'Life Domain';
    final houseMeaning = getPlanetInHouseMeaning(planet.name, planet.house);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            planet.color.withAlpha(38), // 0.15 opacity = 38
            planet.color.withAlpha(20), // 0.08 opacity = 20
            Colors.black.withAlpha(77), // 0.3 opacity = 77
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withAlpha(20),
        ),
      ),
      child: Column(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              children: [
                // Planet Orb with Play
                _buildPlanetOrb(),
                const SizedBox(height: 24),

                // Planet Name & Position
                _buildNameAndPosition(),
                const SizedBox(height: 20),

                // Archetype Badge
                _buildArchetypeBadge(archetype),
                const SizedBox(height: 16),

                // Keywords
                _buildKeywords(keywords),
                const SizedBox(height: 24),

                // Frequency Display
                _buildFrequencyDisplay(waveform),
                const SizedBox(height: 20),

                // Sound Description
                _buildSoundDescription(soundDescription),
              ],
            ),
          ),

          // House Context Section
          _buildHouseContext(houseTheme, houseMeaning),
        ],
      ),
    );
  }

  Widget _buildPlanetOrb() {
    final planet = widget.planet;

    return SizedBox(
      width: 130,
      height: 130,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ripple effects when playing
          if (widget.isPlaying) ...[
            _buildRipple(0),
            _buildRipple(0.33),
            _buildRipple(0.66),
          ],

          // Main orb button
          GestureDetector(
            onTap: widget.onPlayPause,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.3, -0.3),
                  colors: [
                    planet.color.withAlpha(128),
                    planet.color.withAlpha(102),
                    Colors.transparent,
                  ],
                  stops: const [0, 0.5, 1],
                ),
                border: Border.all(
                  color: planet.color.withAlpha(153),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: planet.color.withAlpha(77),
                    blurRadius: 40,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: widget.isPlaying
                    ? _buildWaveformBars()
                    : Text(
                        planet.symbol,
                        style: TextStyle(
                          fontSize: 48,
                          color: planet.color,
                          shadows: [
                            Shadow(
                              color: planet.color.withAlpha(204),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRipple(double delay) {
    return AnimatedBuilder(
      animation: _rippleController,
      builder: (context, child) {
        final value = ((_rippleController.value + delay) % 1.0);
        return Transform.scale(
          scale: 1 + (value * 1.5),
          child: Opacity(
            opacity: (0.6 - (value * 0.6)).clamp(0.0, 1.0),
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: widget.planet.color.withAlpha(102),
                  width: 2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaveformBars() {
    final heights = [0.4, 0.7, 1.0, 0.8, 0.5, 0.9, 0.6];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: heights.asMap().entries.map((entry) {
        final i = entry.key;
        final h = entry.value;
        return AnimatedBuilder(
          animation: _rippleController,
          builder: (context, child) {
            final phase = (_rippleController.value + (i * 0.05)) % 1.0;
            final scale = 0.7 + (0.6 * (0.5 + 0.5 * math.cos(phase * 6.28)));
            return Container(
              width: 4,
              height: (h * 40 * scale).clamp(8.0, 60.0),
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(230),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildNameAndPosition() {
    final planet = widget.planet;
    return Column(
      children: [
        Text(
          planet.name,
          style: GoogleFonts.syne(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            foreground: Paint()
              ..shader = LinearGradient(
                colors: [Colors.white, planet.color],
              ).createShader(const Rect.fromLTWH(0, 0, 200, 50)),
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              color: Colors.white.withAlpha(153),
            ),
            children: [
              const TextSpan(text: 'in '),
              TextSpan(
                text: planet.sign,
                style: TextStyle(
                  color: planet.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const TextSpan(text: ' • House '),
              TextSpan(text: '${planet.house}'),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${planet.angle.toStringAsFixed(1)}°',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            color: Colors.white.withAlpha(102),
          ),
        ),
      ],
    );
  }

  Widget _buildArchetypeBadge(String archetype) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: widget.planet.color.withAlpha(51),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.planet.color.withAlpha(102),
        ),
      ),
      child: Text(
        archetype,
        style: GoogleFonts.syne(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: widget.planet.color,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildKeywords(List<String> keywords) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: keywords.map((keyword) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(13),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            keyword,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 11,
              color: Colors.white.withAlpha(153),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFrequencyDisplay(String waveform) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(77),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  widget.planet.color.withAlpha(77),
                  widget.planet.color.withAlpha(51),
                ],
              ),
            ),
            child: Icon(
              Icons.graphic_eq,
              color: widget.planet.color,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${widget.planet.frequency}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    TextSpan(
                      text: ' Hz',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        color: Colors.white.withAlpha(128),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                waveform,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  color: Colors.white.withAlpha(102),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSoundDescription(String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        '"$description"',
        textAlign: TextAlign.center,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontStyle: FontStyle.italic,
          color: Colors.white.withAlpha(179),
          height: 1.7,
        ),
      ),
    );
  }

  Widget _buildHouseContext(String houseTheme, String houseMeaning) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(102),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
        border: Border(
          top: BorderSide(
            color: widget.planet.color.withAlpha(51),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'House ${widget.planet.house}',
                style: GoogleFonts.syne(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.electricYellow,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '•',
                style: TextStyle(
                  color: Colors.white.withAlpha(77),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                houseTheme,
                style: GoogleFonts.syne(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withAlpha(128),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            houseMeaning,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              color: Colors.white.withAlpha(166),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAspectsSection() {
    final visibleAspects =
        _showAllAspects ? widget.aspects : widget.aspects.take(2).toList();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withAlpha(20),
        ),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Harmonic Connections',
                      style: GoogleFonts.syne(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'How ${widget.planet.name} blends with your other planets',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: Colors.white.withAlpha(102),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(13),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${widget.aspects.length}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            height: 1,
            color: Colors.white.withAlpha(15),
          ),

          // Aspect Cards
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                ...visibleAspects.asMap().entries.map((entry) {
                  final index = entry.key;
                  final aspect = entry.value;
                  return _buildAspectCard(aspect, index);
                }),

                // Show More Button
                if (widget.aspects.length > 2)
                  GestureDetector(
                    onTap: () =>
                        setState(() => _showAllAspects = !_showAllAspects),
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white.withAlpha(26),
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _showAllAspects
                                ? 'Show less'
                                : '${widget.aspects.length - 2} more aspects',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withAlpha(128),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Transform.rotate(
                            angle: _showAllAspects ? 3.14159 : 0,
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white.withAlpha(102),
                              size: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAspectCard(WheelAspectData aspect, int index) {
    final otherPlanetName =
        AspectCalculator.getOtherPlanet(aspect, widget.planet.name);
    final otherPlanet =
        widget.allPlanets.firstWhere((p) => p.name == otherPlanetName);

    final isExpanded = _activeAspect == index;
    final isAspectPlaying = widget.playingAspect != null &&
        widget.playingAspect!.planet1 == aspect.planet1 &&
        widget.playingAspect!.planet2 == aspect.planet2;

    final aspectColor = aspect.color;
    final quality = aspect.harmony;

    final aspectMeaning =
        getAspectMeaning(widget.planet.name, otherPlanetName, aspect.name);
    final soundBlend =
        getSoundBlend(widget.planet.name, otherPlanetName, aspect.name, quality);

    return GestureDetector(
      onTap: () => setState(() {
        _activeAspect = _activeAspect == index ? null : index;
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isExpanded
              ? Colors.white.withAlpha(15)
              : Colors.white.withAlpha(0),
          borderRadius: BorderRadius.circular(16),
          border: isExpanded
              ? Border.all(color: aspectColor.withAlpha(77))
              : Border.all(color: Colors.transparent),
        ),
        child: Column(
          children: [
            // Aspect Header Row
            Row(
              children: [
                // Planet Symbol
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        aspectColor.withAlpha(64),
                        aspectColor.withAlpha(26),
                      ],
                    ),
                    border: Border.all(
                      color: aspectColor.withAlpha(102),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      otherPlanet.symbol,
                      style: TextStyle(
                        fontSize: 22,
                        color: aspectColor,
                        shadows: [
                          Shadow(
                            color: aspectColor.withAlpha(128),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Aspect Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            otherPlanetName,
                            style: GoogleFonts.syne(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: aspectColor.withAlpha(38),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              aspect.name,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: aspectColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${otherPlanet.frequency} Hz • $quality',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: Colors.white.withAlpha(128),
                        ),
                      ),
                    ],
                  ),
                ),

                // Play Button
                GestureDetector(
                  onTap: () => widget.onAspectTap(aspect),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isAspectPlaying
                          ? aspectColor
                          : Colors.white.withAlpha(20),
                    ),
                    child: Icon(
                      isAspectPlaying ? Icons.pause : Icons.play_arrow,
                      color: isAspectPlaying
                          ? const Color(0xFF0A0A0F)
                          : Colors.white.withAlpha(179),
                      size: 16,
                    ),
                  ),
                ),
              ],
            ),

            // Expanded Content
            if (isExpanded) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withAlpha(20),
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Meaning Section
                    Text(
                      'THE MEANING',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: aspectColor,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      aspectMeaning,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        color: Colors.white.withAlpha(179),
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Sound Blend Section
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(77),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'SOUND BLEND',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withAlpha(102),
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '"$soundBlend"',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.white.withAlpha(153),
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlayFullSoundButton() {
    return GestureDetector(
      onTap: widget.onPlayPause,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.planet.color,
              widget.planet.color.withAlpha(204),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: widget.planet.color.withAlpha(77),
              blurRadius: 32,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Text(
              'Play Full ${widget.planet.name} Sound',
              style: GoogleFonts.syne(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
