import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/monthly_zodiac.dart';
import '../services/spotify_service.dart';
import '../config/design_tokens.dart';
import 'glass_card.dart';
import 'skeleton_loader.dart';

/// Collapsible card displaying the monthly zodiac playlist.
/// 
/// Features:
/// - Element-themed gradient background (Fire/Earth/Air/Water)
/// - Collapsed by default, expands on tap
/// - Shows zodiac symbol, sign name, and horoscope
/// - Track list preview with "Open in Spotify" button
class ZodiacPlaylistCard extends StatefulWidget {
  final MonthlyZodiacPlaylist? playlist;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final VoidCallback? onOpenSpotify;

  const ZodiacPlaylistCard({
    super.key,
    this.playlist,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.onOpenSpotify,
  });

  @override
  State<ZodiacPlaylistCard> createState() => _ZodiacPlaylistCardState();
}

class _ZodiacPlaylistCardState extends State<ZodiacPlaylistCard>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  List<Color> _getElementGradient() {
    if (widget.playlist == null) {
      return [AppColors.cosmicPurple, AppColors.hotPink];
    }
    
    final colors = MonthlyZodiacPlaylist.getElementColors(widget.playlist!.element);
    return colors.map((c) => Color(c)).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Loading state
    if (widget.isLoading) {
      return _buildLoadingState();
    }

    // Error state
    if (widget.errorMessage != null) {
      return _buildErrorState();
    }

    // No data yet
    if (widget.playlist == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: _toggleExpanded,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getElementGradient()[0].withAlpha(51),  // 20% opacity
              _getElementGradient()[1].withAlpha(38),  // 15% opacity
            ],
          ),
          border: Border.all(
            color: _getElementGradient()[0].withAlpha(77), // 30% opacity
            width: 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            children: [
              // Header (always visible)
              _buildHeader(),
              
              // Expandable content
              SizeTransition(
                sizeFactor: _expandAnimation,
                child: _buildExpandedContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              SkeletonLoader(
                width: 48,
                height: 48,
                borderRadius: BorderRadius.circular(24),
                color: Colors.white.withAlpha(25),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(
                      width: 150,
                      height: 20,
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.white.withAlpha(25),
                    ),
                    const SizedBox(height: 8),
                    SkeletonLoader(
                      width: 100,
                      height: 14,
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
            widget.errorMessage ?? 'Failed to load zodiac playlist',
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

  Widget _buildHeader() {
    final playlist = widget.playlist!;
    final gradientColors = _getElementGradient();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Zodiac symbol circle
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: gradientColors,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradientColors[0].withAlpha(77),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                playlist.symbol,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Title and subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${playlist.zodiacSign} Season',
                      style: GoogleFonts.syne(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Element badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: gradientColors[0].withAlpha(51),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: gradientColors[0].withAlpha(102),
                        ),
                      ),
                      child: Text(
                        playlist.element,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          color: gradientColors[0],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  playlist.dateRange,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: Colors.white.withAlpha(153),
                  ),
                ),
              ],
            ),
          ),
          
          // Expand/collapse indicator
          AnimatedRotation(
            turns: _isExpanded ? 0.5 : 0,
            duration: const Duration(milliseconds: 300),
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white.withAlpha(153),
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedContent() {
    final playlist = widget.playlist!;
    final gradientColors = _getElementGradient();
    
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Divider
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  gradientColors[0].withAlpha(77),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Horoscope text
          Text(
            'MONTHLY HOROSCOPE',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              color: Colors.white.withAlpha(128),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            playlist.horoscope,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              color: Colors.white.withAlpha(230),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          
          // Vibe summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: gradientColors[0].withAlpha(26),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: gradientColors[0].withAlpha(51),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.music_note_rounded,
                  color: gradientColors[0],
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    playlist.vibeSummary,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 12,
                      color: Colors.white.withAlpha(204),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Track preview (first 3)
          if (playlist.tracks.isNotEmpty) ...[
            Text(
              'YOUR PLAYLIST (${playlist.tracks.length} tracks)',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                color: Colors.white.withAlpha(128),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            ...playlist.tracks.take(3).map((track) => _buildTrackItem(track)),
            if (playlist.tracks.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '+${playlist.tracks.length - 3} more tracks',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    color: Colors.white.withAlpha(102),
                  ),
                ),
              ),
          ],
          
          // Open in Spotify button
          if (playlist.playlistUrl != null) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.onOpenSpotify,
                icon: const Icon(Icons.play_circle_fill_rounded, size: 20),
                label: Text(
                  'Open in Spotify',
                  style: GoogleFonts.syne(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1DB954), // Spotify green
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTrackItem(SpotifyTrack track) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              gradient: LinearGradient(
                colors: _getElementGradient(),
              ),
            ),
            child: const Icon(
              Icons.music_note,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.name,
                  style: GoogleFonts.syne(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  track.artistName,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    color: Colors.white.withAlpha(153),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
