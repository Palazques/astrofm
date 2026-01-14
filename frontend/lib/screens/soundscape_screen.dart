import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/design_tokens.dart';
import '../widgets/app_header.dart';
import '../widgets/glass_card.dart';
import '../widgets/inline_error.dart';
import '../widgets/cosmic_wave_loader.dart';
import '../widgets/focus_area_card.dart';
import '../widgets/vibe_preview_sheet.dart';
import '../services/api_service.dart';
import '../services/spotify_service.dart';
import '../services/playlist_service.dart';
import '../services/storage_service.dart';
import '../models/seasonal_pulse.dart';
import '../models/birth_data.dart';

final playlistService = PlaylistService();
final storageService = StorageService();

const defaultTestBirthData = {
  'datetime': '1995-03-15T14:30:00',
  'latitude': 37.7749,
  'longitude': -122.4194,
  'timezone': 'America/Los_Angeles',
};

/// Soundscape screen - Cosmic Playlist Hub.
/// Displays both personal daily playlists AND seasonal collective playlists.
class SoundscapeScreen extends StatefulWidget {
  const SoundscapeScreen({super.key});

  @override
  State<SoundscapeScreen> createState() => _SoundscapeScreenState();
}

class _SoundscapeScreenState extends State<SoundscapeScreen> {
  final ApiService _apiService = ApiService();
  final SpotifyService _spotifyService = SpotifyService();
  
  // Birth data from storage
  BirthData? _birthData;
  
  // User's genre preferences
  List<String> _userMainGenres = [];
  
  // Seasonal pulse state
  SeasonalPulseResponse? _seasonalPulse;
  bool _isLoadingSeasonalPulse = false;
  String? _seasonalPulseError;

  Map<String, dynamic> get _birthDataMap => _birthData != null 
    ? {
        'datetime': _birthData!.datetime,
        'latitude': _birthData!.latitude,
        'longitude': _birthData!.longitude,
        'timezone': _birthData!.timezone,
      }
    : defaultTestBirthData;

  @override
  void initState() {
    super.initState();
    _loadData();
    playlistService.addListener(_onPlaylistServiceUpdate);
    playlistService.init();
  }
  
  @override
  void dispose() {
    playlistService.removeListener(_onPlaylistServiceUpdate);
    _apiService.dispose();
    super.dispose();
  }
  
  void _onPlaylistServiceUpdate() {
    if (mounted) {
      setState(() {});
    }
  }
  
  Future<void> _loadData() async {
    // Load birth data
    final stored = await storageService.loadBirthData();
    if (mounted) {
      setState(() => _birthData = stored);
    }
    
    // Load genre preferences
    final genrePrefs = await storageService.loadGenres();
    if (mounted) {
      setState(() {
        _userMainGenres = genrePrefs.genres;
      });
    }
    
    // Load Seasonal Pulse
    _loadSeasonalPulse();
  }
  
  Future<void> _loadSeasonalPulse() async {
    if (_isLoadingSeasonalPulse) return;
    
    setState(() {
      _isLoadingSeasonalPulse = true;
      _seasonalPulseError = null;
    });
    
    try {
      final pulse = await _apiService.getSeasonalPulse();
      
      if (mounted) {
        setState(() {
          _seasonalPulse = pulse;
          _isLoadingSeasonalPulse = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _seasonalPulseError = 'Could not load seasonal focus';
          _isLoadingSeasonalPulse = false;
        });
      }
    }
  }

  String _getCurrentZodiacSign() {
    final now = DateTime.now();
    final month = now.month;
    final day = now.day;
    
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return 'Aries';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return 'Taurus';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return 'Gemini';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return 'Cancer';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return 'Leo';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return 'Virgo';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return 'Libra';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return 'Scorpio';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return 'Sagittarius';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return 'Capricorn';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return 'Aquarius';
    return 'Pisces';
  }

  Future<void> _generatePlaylist() async {
    String sunSign = _getCurrentZodiacSign();
    String moonSign = 'Pisces';
    String risingSign = 'Scorpio';
    
    final genres = _userMainGenres.isNotEmpty 
        ? _userMainGenres 
        : ['indie rock', 'electronic', 'pop'];
    
    await playlistService.generatePlaylist(
      sunSign: sunSign,
      moonSign: moonSign,
      risingSign: risingSign,
      genrePreferences: genres,
    );
  }
  
  Future<void> _openSpotifyPlaylist() async {
    if (playlistService.spotifyPlaylistUrl != null) {
      await _spotifyService.openPlaylist(playlistService.spotifyPlaylistUrl!);
    }
  }
  
  Color _getElementColor() {
    if (_seasonalPulse == null) return AppColors.cosmicPurple;
    
    // Parse the color from the API response
    try {
      final colorStr = _seasonalPulse!.color1;
      if (colorStr.startsWith('#')) {
        final hex = colorStr.substring(1);
        return Color(int.parse('FF$hex', radix: 16));
      }
    } catch (e) {
      // Fallback to default
    }
    
    // Fallback based on element
    final elementColors = {
      'Fire': const Color(0xFFFF6B6B),
      'Earth': const Color(0xFF2ECC71),
      'Air': const Color(0xFF3498DB),
      'Water': const Color(0xFF1ABC9C),
    };
    
    return elementColors[_seasonalPulse!.element] ?? AppColors.cosmicPurple;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppHeader(
              showBackButton: false,
              showMenuButton: false,
              title: 'Soundscape',
              showSettingsButton: true,
            ),
            const SizedBox(height: 16),

            // Your Cosmic Queue (Personal Daily Playlist)
            _buildCosmicQueue(),
            const SizedBox(height: 32),

            // Seasonal Focus (Collective Playlists)
            _buildSeasonalFocusSection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCosmicQueue() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Cosmic Queue',
                  style: GoogleFonts.syne(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (playlistService.cosmicPlaylist != null)
                  Text(
                    '${playlistService.cosmicPlaylist!.trackCount} tracks • ${playlistService.cosmicPlaylist!.formattedDuration}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      color: Colors.white.withAlpha(128),
                    ),
                  )
                else if (playlistService.datasetPlaylist != null)
                  Text(
                    '${playlistService.datasetPlaylist!.trackCount} tracks • ${playlistService.datasetPlaylist!.formattedDuration}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      color: Colors.white.withAlpha(128),
                    ),
                  )
                else if (playlistService.generatedPlaylist != null)
                  Text(
                    '${playlistService.generatedPlaylist!.songCount} songs • ${playlistService.generatedPlaylist!.formattedDuration}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      color: Colors.white.withAlpha(128),
                    ),
                  ),
              ],
            ),
            // Status + actions row
            Row(
              children: [
                // Ready status badge
                if (playlistService.hasPlaylist)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D4AA).withAlpha(38),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF00D4AA),
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Ready',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF00D4AA),
                          ),
                        ),
                      ],
                    ),
                  ),
                // Open in Spotify button
                if (playlistService.spotifyPlaylistUrl != null)
                  GestureDetector(
                    onTap: _openSpotifyPlaylist,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1DB954),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.play_circle_fill, size: 16, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            'Open in Spotify',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        
        // Show cosmic wave loader while generating
        if (playlistService.isGenerating)
          const GlassCard(
            padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: CosmicWaveLoader(),
          )
        // Show error with retry
        else if (playlistService.error != null)
          GlassCard(
            child: InlineError(
              message: playlistService.error!,
              onRetry: () => playlistService.init(),
            ),
          )
        // Show empty state
        else if (!playlistService.hasPlaylist)
          GlassCard(
            child: Column(
              children: [
                Icon(
                  Icons.queue_music_rounded,
                  size: 48,
                  color: Colors.white.withAlpha(51),
                ),
                const SizedBox(height: 12),
                Text(
                  'No playlists yet',
                  style: GoogleFonts.syne(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withAlpha(179),
                  ),
                ),
                Text(
                  'Discover your cosmic signature in sound',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: Colors.white.withAlpha(128),
                  ),
                ),
                const SizedBox(height: 32),
                GestureDetector(
                  onTap: playlistService.isGenerating ? null : _generatePlaylist,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.cosmicPurple, AppColors.hotPink],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cosmicPurple.withAlpha(51),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: playlistService.isGenerating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          'Generate My Soundtrack',
                          style: GoogleFonts.syne(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                  ),
                ),
              ],
            ),
          )
        // Show playlist preview
        else
          _buildPlaylistPreview(),
      ],
    );
  }
  
  Widget _buildPlaylistPreview() {
    // Build track items based on available playlist type
    List<Widget> trackItems = [];
    
    // Handle CosmicPlaylist (has CosmicTrack with name/artist)
    if (playlistService.cosmicPlaylist != null) {
      final tracks = playlistService.cosmicPlaylist!.tracks.take(5);
      trackItems = tracks.map((track) => _buildTrackRow(track.name, track.artist)).toList();
    }
    // Handle DatasetPlaylist (has DatasetTrack with trackName/artists)
    else if (playlistService.datasetPlaylist != null) {
      final tracks = playlistService.datasetPlaylist!.tracks.take(5);
      trackItems = tracks.map((track) => _buildTrackRow(track.trackName, track.artists)).toList();
    }
    
    if (trackItems.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Column(children: trackItems),
    );
  }
  
  Widget _buildTrackRow(String name, String artist) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Track artwork placeholder
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [
                  AppColors.cosmicPurple.withAlpha(128),
                  AppColors.hotPink.withAlpha(128),
                ],
              ),
            ),
            child: const Icon(Icons.music_note, color: Colors.white54, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.syne(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  artist,
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
        ],
      ),
    );
  }
  
  Widget _buildSeasonalFocusSection() {
    // Loading state
    if (_isLoadingSeasonalPulse) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seasonal Focus',
            style: GoogleFonts.syne(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const GlassCard(
            padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: CosmicWaveLoader(),
          ),
        ],
      );
    }
    
    // Error state (but don't block the page)
    // Error state
    if (_seasonalPulseError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Seasonal Focus',
            style: GoogleFonts.syne(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          GlassCard(
            child: InlineError(
              message: _seasonalPulseError!,
              onRetry: _loadSeasonalPulse,
            ),
          ),
        ],
      );
    }
    
    // No data state
    if (_seasonalPulse == null || _seasonalPulse!.themes.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _seasonalPulse != null 
            ? _buildCompactSeasonHeader(_getElementColor())
            : Text(
                'Seasonal Focus',
                style: GoogleFonts.syne(
                  fontSize: 16,                                            
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
          const SizedBox(height: 12),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: Column(
              children: [
                Icon(Icons.auto_awesome_outlined, size: 32, color: Colors.white.withAlpha(50)),
                const SizedBox(height: 12),
                Text(
                  'Aligning with the cosmos...',
                  style: GoogleFonts.spaceGrotesk(color: Colors.white.withAlpha(128)),
                ),
              ],
            ),
          ),
        ],
      );
    }
    
    // Seasonal focus with themed playlists
    final elementColor = _getElementColor();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Compact season header
        _buildCompactSeasonHeader(elementColor),
        const SizedBox(height: 16),
        
        // Focus area grid
        _buildFocusGrid(elementColor),
      ],
    );
  }
  
  Widget _buildCompactSeasonHeader(Color elementColor) {
    final pulse = _seasonalPulse!;
    
    return Row(
      children: [
        // Small orb with zodiac symbol
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                elementColor.withAlpha(80),
                elementColor.withAlpha(40),
              ],
            ),
            border: Border.all(color: elementColor.withAlpha(128)),
            boxShadow: [
              BoxShadow(
                color: elementColor.withAlpha(60),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Text(
              pulse.symbol,
              style: TextStyle(
                fontSize: 24,
                color: Colors.white.withAlpha(230),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        
        // Season info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Seasonal Focus',
                style: GoogleFonts.syne(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                '${pulse.activeSign} • ${pulse.dateRange}',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  color: Colors.white.withAlpha(128),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildFocusGrid(Color elementColor) {
    final themes = _seasonalPulse!.themes;
    
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: themes.map((theme) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 52) / 2, // 2 columns with padding
          child: FocusAreaCard(
            theme: theme,
            elementColor: elementColor,
            onTap: () => _showVibePreview(theme, elementColor),
            backgroundImage: 'assets/images/card_backgrounds/focus_area_bg.png',
          ),
        );
      }).toList(),
    );
  }
  
  void _showVibePreview(SeasonalTheme theme, Color elementColor) {
    VibePreviewSheet.show(
      context,
      theme: theme,
      elementColor: elementColor,
      onOpenSpotify: () {
        if (theme.playlistUrl != null && theme.playlistUrl!.isNotEmpty) {
          _spotifyService.openPlaylist(theme.playlistUrl!);
        }
      },
    );
  }
}
