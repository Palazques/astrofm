import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/seasonal_pulse.dart';
import '../models/seasonal_track.dart';
import '../config/design_tokens.dart';
import 'glass_card.dart';

/// Glassmorphic bottom sheet for previewing seasonal themed playlists.
/// Shows the monthly message, track list, and Spotify integration.
class VibePreviewSheet extends StatelessWidget {
  final SeasonalTheme theme;
  final Color elementColor;
  final VoidCallback? onOpenSpotify;

  const VibePreviewSheet({
    super.key,
    required this.theme,
    required this.elementColor,
    this.onOpenSpotify,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.background,
            AppColors.background.withAlpha(240),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Stack(
        children: [
          // Background glow
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    elementColor.withAlpha(40),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // Content
          Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(77),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              _buildHeader(),
              
              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Monthly message
                      _buildMessage(),
                      const SizedBox(height: 24),
                      
                      // Track list
                      _buildTrackList(),
                    ],
                  ),
                ),
              ),
              
              // Action button
              _buildActionButton(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Row(
        children: [
          // Orb with glyph
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  elementColor.withAlpha(80),
                  elementColor.withAlpha(40),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: elementColor.withAlpha(128)),
              boxShadow: [
                BoxShadow(
                  color: elementColor.withAlpha(60),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                theme.glyph,
                style: TextStyle(
                  fontSize: 32,
                  color: elementColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Title and info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  theme.title,
                  style: GoogleFonts.syne(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${theme.trackCount} tracks • ${theme.totalDuration}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: Colors.white.withAlpha(153),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THE SEASONAL MESSAGE',
            style: GoogleFonts.spaceMono(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white.withAlpha(128),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            theme.monthlyMessage,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: Colors.white.withAlpha(204),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'TRACKLIST',
          style: GoogleFonts.spaceMono(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white.withAlpha(128),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        ...theme.tracks.map((track) => _buildTrackRow(track)),
      ],
    );
  }

  Widget _buildTrackRow(SeasonalTrack track) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Row(
        children: [
          // Energy indicator
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  elementColor,
                  Colors.white.withAlpha(51),
                ],
                stops: [track.energy / 100, track.energy / 100],
              ),
              borderRadius: BorderRadius.circular(2),
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
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  track.artist,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    color: Colors.white.withAlpha(128),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // Duration
          Text(
            track.duration,
            style: GoogleFonts.spaceMono(
              fontSize: 11,
              color: Colors.white.withAlpha(102),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final hasSpotifyUrl = theme.playlistUrl != null && theme.playlistUrl!.isNotEmpty;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            AppColors.background,
            AppColors.background.withAlpha(0),
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: hasSpotifyUrl ? onOpenSpotify : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: hasSpotifyUrl ? elementColor : Colors.white.withAlpha(26),
              foregroundColor: hasSpotifyUrl ? const Color(0xFF0A0A0F) : Colors.white.withAlpha(77),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              shadowColor: elementColor.withAlpha(100),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  hasSpotifyUrl ? Icons.open_in_new_rounded : Icons.hourglass_empty_rounded,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  hasSpotifyUrl ? 'Open in Spotify' : 'Generating Playlist...',
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
    );
  }

  /// Show the vibe preview sheet.
  static void show(
    BuildContext context, {
    required SeasonalTheme theme,
    required Color elementColor,
    VoidCallback? onOpenSpotify,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VibePreviewSheet(
        theme: theme,
        elementColor: elementColor,
        onOpenSpotify: onOpenSpotify,
      ),
    );
  }
}
