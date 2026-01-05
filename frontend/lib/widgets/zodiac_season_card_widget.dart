import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../models/zodiac_season_card.dart';
import '../config/design_tokens.dart';
import 'glass_card.dart';
import 'skeleton_loader.dart';

/// Premium glassmorphic zodiac season card widget.
/// 
/// Displays:
/// - Current zodiac season with animated symbol orb
/// - Personalized AI insight based on user's natal chart
/// - Seasonal playlist with track list
class ZodiacSeasonCardWidget extends StatefulWidget {
  final ZodiacSeasonCardData? data;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onPlayPressed;
  final VoidCallback? onOpenSpotify;

  const ZodiacSeasonCardWidget({
    super.key,
    this.data,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.onPlayPressed,
    this.onOpenSpotify,
  });

  @override
  State<ZodiacSeasonCardWidget> createState() => _ZodiacSeasonCardWidgetState();
}

class _ZodiacSeasonCardWidgetState extends State<ZodiacSeasonCardWidget>
    with TickerProviderStateMixin {
  bool _isPlaying = false;
  int _currentTrack = 0;
  late AnimationController _floatController;
  late AnimationController _rotateController;
  late Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat(reverse: true);
    
    _rotateController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    )..repeat();
    
    _floatAnimation = Tween<double>(begin: 0, end: 6).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildLoadingState();
    }

    if (widget.errorMessage != null) {
      return _buildErrorState();
    }

    if (widget.data == null) {
      return const SizedBox.shrink();
    }

    return _buildCard();
  }

  Widget _buildLoadingState() {
    return GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              SkeletonLoader(
                width: 110,
                height: 110,
                borderRadius: BorderRadius.circular(55),
                color: Colors.white.withAlpha(25),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(
                      width: 120,
                      height: 32,
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.white.withAlpha(25),
                    ),
                    const SizedBox(height: 8),
                    SkeletonLoader(
                      width: 80,
                      height: 16,
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.white.withAlpha(18),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return GlassCard(
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            color: Colors.white.withAlpha(128),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            widget.errorMessage ?? 'Failed to load season card',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              color: Colors.white.withAlpha(153),
            ),
            textAlign: TextAlign.center,
          ),
          if (widget.onRetry != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: widget.onRetry,
              child: Text(
                'Retry',
                style: GoogleFonts.syne(
                  fontSize: 12,
                  color: AppColors.hotPink,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCard() {
    final data = widget.data!;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            data.color1.withAlpha(30),
            data.color2.withAlpha(20),
            Colors.white.withAlpha(5),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background glow
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    data.color1.withAlpha(50),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                // Header
                _buildHeader(data),
                // Season visual
                _buildSeasonVisual(data),
                // Personal connection
                _buildPersonalConnection(data),
                // Playlist
                _buildPlaylistSection(data),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ZodiacSeasonCardData data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: data.color1,
                  boxShadow: [
                    BoxShadow(
                      color: data.color1.withAlpha(128),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'CURRENT SEASON',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  color: Colors.white.withAlpha(128),
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () => _shareSeasonCard(data),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(13),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.share_outlined,
                    size: 14,
                    color: Colors.white.withAlpha(153),
                  ),
                ),
              ),
              Text(
                data.dateRange,
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

  void _shareSeasonCard(ZodiacSeasonCardData data) {
    final insight = data.personalInsight;
    final playlistLink = data.playlistUrl ?? '';
    
    final text = '''${data.symbol} ${data.sign.toUpperCase()} SEASON
${data.dateRange}

🔮 ${insight.headline}
${insight.subtext}

${insight.meaning}

🎧 Focus Areas: ${insight.focusAreas.join(' • ')}

🎵 Playlist: ${data.playlistName}${playlistLink.isNotEmpty ? '\n$playlistLink' : ''}

— Generated by Astro.FM''';
    
    Share.share(text);
  }

  Widget _buildSeasonVisual(ZodiacSeasonCardData data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Row(
        children: [
          // Animated zodiac orb
          AnimatedBuilder(
            animation: _floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -_floatAnimation.value),
                child: _buildZodiacOrb(data),
              );
            },
          ),
          const SizedBox(width: 20),
          // Season info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Colors.white, data.color1],
                  ).createShader(bounds),
                  child: Text(
                    data.sign,
                    style: GoogleFonts.syne(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  'Season',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: Colors.white.withAlpha(153),
                  ),
                ),
                const SizedBox(height: 12),
                // Element & modality tags
                Wrap(
                  spacing: 8,
                  children: [
                    _buildTag(data.element, data.elementColor, filled: true),
                    _buildTag(data.modality, Colors.white.withAlpha(153)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZodiacOrb(ZodiacSeasonCardData data) {
    return SizedBox(
      width: 110,
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Rotating ring
          RotationTransition(
            turns: _rotateController,
            child: CustomPaint(
              size: const Size(134, 134),
              painter: _OrbitRingPainter(
                color1: data.color1,
                color2: data.color2,
              ),
            ),
          ),
          // Glass orb
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.3),
                colors: [
                  data.color1.withAlpha(90),
                  data.color2.withAlpha(60),
                  Colors.black.withAlpha(80),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              border: Border.all(
                color: data.color1.withAlpha(102),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: data.color1.withAlpha(80),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Center(
              child: Text(
                data.symbol,
                style: TextStyle(
                  fontSize: 48,
                  color: Colors.white.withAlpha(230),
                  shadows: [
                    Shadow(
                      color: data.color1.withAlpha(150),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Ruling planet badge
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    data.color2.withAlpha(80),
                    const Color(0xFF0A0A0F),
                  ],
                ),
                border: Border.all(
                  color: data.color2.withAlpha(128),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(150),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  data.rulingSymbol,
                  style: TextStyle(
                    fontSize: 20,
                    color: data.color2,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color, {bool filled = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: filled ? color.withAlpha(38) : Colors.white.withAlpha(13),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: filled ? color.withAlpha(102) : Colors.white.withAlpha(30),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.spaceGrotesk(
          fontSize: 11,
          color: filled ? color : Colors.white.withAlpha(153),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildPersonalConnection(ZodiacSeasonCardData data) {
    final insight = data.personalInsight;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(90),
        border: Border(
          top: BorderSide(color: Colors.white.withAlpha(15)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            insight.headline,
            style: GoogleFonts.syne(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            insight.subtext,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              color: data.color1,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            insight.meaning,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              color: Colors.white.withAlpha(179),
              height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          // Focus areas
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: insight.focusAreas.map((area) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(13),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withAlpha(26)),
                ),
                child: Text(
                  area,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    color: Colors.white.withAlpha(179),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistSection(ZodiacSeasonCardData data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        border: Border(
          top: BorderSide(color: Colors.white.withAlpha(20)),
        ),
      ),
      child: Column(
        children: [
          // Playlist header
          _buildPlaylistHeader(data),
          // Play button
          _buildPlayButton(data),
          // Track list
          _buildTrackList(data),
        ],
      ),
    );
  }

  Widget _buildPlaylistHeader(ZodiacSeasonCardData data) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Playlist cover
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.3),
                colors: [
                  data.color1.withAlpha(102),
                  data.color2.withAlpha(76),
                  Colors.black.withAlpha(102),
                ],
              ),
              border: Border.all(color: data.color1.withAlpha(90)),
              boxShadow: [
                BoxShadow(
                  color: data.color1.withAlpha(50),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Center(
              child: _isPlaying
                  ? _buildWaveform()
                  : Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white.withAlpha(204),
                      size: 32,
                    ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SEASONAL PLAYLIST',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    color: Colors.white.withAlpha(102),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.playlistName,
                  style: GoogleFonts.syne(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${data.trackCount} tracks • ${data.totalDuration}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: Colors.white.withAlpha(128),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveform() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final heights = [0.4, 0.7, 1.0, 0.6, 0.8];
        return Container(
          width: 4,
          height: 28 * heights[i],
          margin: const EdgeInsets.symmetric(horizontal: 1.5),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(230),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }

  Widget _buildPlayButton(ZodiacSeasonCardData data) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          // Vibe tags
          Expanded(
            child: Wrap(
              spacing: 6,
              children: data.vibeTags.take(3).map((tag) {
                final isFirst = tag == data.vibeTags.first;
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isFirst ? data.color1.withAlpha(46) : Colors.white.withAlpha(13),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    tag,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      color: isFirst ? data.color1 : Colors.white.withAlpha(128),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackList(ZodiacSeasonCardData data) {
    return Column(
      children: [
        // Play all button
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() => _isPlaying = !_isPlaying);
                widget.onPlayPressed?.call();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _isPlaying
                    ? Colors.white.withAlpha(20)
                    : data.color1,
                foregroundColor: _isPlaying ? Colors.white : const Color(0xFF0A0A0F),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: _isPlaying
                      ? BorderSide(color: data.color1.withAlpha(128))
                      : BorderSide.none,
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isPlaying ? 'Pause' : 'Play Season Soundtrack',
                    style: GoogleFonts.syne(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        // Track items
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          child: Column(
            children: [
              ...data.tracks.take(5).toList().asMap().entries.map((entry) {
                final index = entry.key;
                final track = entry.value;
                return _buildTrackItem(track, index, data);
              }),
              if (data.tracks.length > 5)
                _buildViewAllButton(data),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrackItem(SeasonTrack track, int index, ZodiacSeasonCardData data) {
    final isCurrentTrack = _currentTrack == index && _isPlaying;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentTrack = index;
          _isPlaying = true;
        });
        widget.onPlayPressed?.call();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          color: isCurrentTrack ? Colors.white.withAlpha(15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Track number or waveform
            SizedBox(
              width: 28,
              child: Center(
                child: isCurrentTrack
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(3, (i) {
                          final heights = [0.5, 0.8, 0.6];
                          return Container(
                            width: 3,
                            height: 16 * heights[i],
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            decoration: BoxDecoration(
                              color: data.color1,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          );
                        }),
                      )
                    : Text(
                        '${index + 1}',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 13,
                          color: Colors.white.withAlpha(76),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Track info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: GoogleFonts.syne(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isCurrentTrack ? data.color1 : Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    track.artist,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: Colors.white.withAlpha(102),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Energy bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(26),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: track.energy / 100,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [data.color1, data.color2],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Duration
            Text(
              track.duration,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                color: Colors.white.withAlpha(76),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewAllButton(ZodiacSeasonCardData data) {
    return GestureDetector(
      onTap: widget.onOpenSpotify,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        margin: const EdgeInsets.only(top: 8),
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
              'View all ${data.trackCount} tracks',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 13,
                color: Colors.white.withAlpha(128),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 16,
              color: Colors.white.withAlpha(102),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for the orbital ring around the zodiac symbol.
class _OrbitRingPainter extends CustomPainter {
  final Color color1;
  final Color color2;

  _OrbitRingPainter({required this.color1, required this.color2});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 1;

    // Draw ring
    final ringPaint = Paint()
      ..color = color1.withAlpha(60)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius, ringPaint);

    // Draw dots on ring
    final angles = [0, 60, 120, 180, 240, 300];
    for (var i = 0; i < angles.length; i++) {
      final angle = angles[i] * 3.14159 / 180;
      final dotX = center.dx + radius * cos(angle);
      final dotY = center.dy + radius * sin(angle);
      
      final dotPaint = Paint()
        ..color = i % 2 == 0 ? color1 : color2
        ..style = PaintingStyle.fill;
      
      final dotSize = i % 2 == 0 ? 3.0 : 2.0;
      canvas.drawCircle(Offset(dotX, dotY), dotSize, dotPaint);
    }
  }

  double cos(double radians) => (radians >= 0) 
      ? (radians < 1.5708 ? _cos(radians) : (radians < 3.1416 ? -_cos(3.1416 - radians) : (radians < 4.7124 ? -_cos(radians - 3.1416) : _cos(6.2832 - radians))))
      : cos(radians + 6.2832);
  
  double sin(double radians) => cos(1.5708 - radians);
  
  double _cos(double x) => 1 - x * x / 2 + x * x * x * x / 24;

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
