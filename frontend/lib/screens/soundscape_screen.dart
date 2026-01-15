import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/design_tokens.dart';
import '../widgets/app_header.dart';
import '../widgets/glass_card.dart';
import '../widgets/inline_error.dart';
import '../widgets/cosmic_wave_loader.dart';
import '../widgets/focus_area_card.dart';
import '../widgets/background_image_card.dart';
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

  // Background images for rotation
  final List<String> _cardBackgrounds = [
    'assets/images/card_backgrounds/focus_area_bg.png',
    'assets/images/card_backgrounds/daily_essence_bg.png',
    'assets/images/card_backgrounds/alignment_dashboard_bg.png',
    'assets/images/card_backgrounds/seasonal_guidance_bg.png',
    'assets/images/card_backgrounds/weekly_digest_bg.png',
  ];

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
        return Color(int.parse('FF\$hex', radix: 16));
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
            const SizedBox(height: 24),

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
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Your Cosmic Queue',
            style: GoogleFonts.syne(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        
        // Show cosmic wave loader while generating
        if (playlistService.isGenerating)
          const GlassCard(
            padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
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
          _buildEmptyState()
        // Show playlist preview
        else
          _buildActivePlaylistCard(),
      ],
    );
  }
  
  Widget _buildEmptyState() {
    return BackgroundImageCard(
      imagePath: 'assets/images/card_backgrounds/daily_essence_bg.png',
      borderRadius: 24,
      child: SizedBox(
        height: 200,
        child: Stack(
        children: [
          // Dark overlay for readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 40,
                  color: Colors.white.withOpacity(0.9),
                ),
                const SizedBox(height: 16),
                Text(
                  'No playlist generated yet',
                  style: GoogleFonts.syne(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Align your vibe with the cosmos',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: playlistService.isGenerating ? null : _generatePlaylist,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.cosmicPurple, AppColors.hotPink],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.cosmicPurple.withAlpha(80),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (playlistService.isGenerating)
                          Container(
                            width: 16,
                            height: 16,
                            margin: const EdgeInsets.only(right: 8),
                            child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        else
                          const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                        if (!playlistService.isGenerating)
                          const SizedBox(width: 8),
                        Text(
                          playlistService.isGenerating ? 'Generating...' : 'Generate Soundtrack',
                          style: GoogleFonts.syne(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
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
      ), // Close SizedBox
    );
  }
  
  Widget _buildActivePlaylistCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.cosmicPurple.withAlpha(40),
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: GlassCard(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            // Header with status
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00D4AA).withAlpha(38),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF00D4AA).withAlpha(80)),
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
                                const SizedBox(width: 6),
                                Text(
                                  'READY',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF00D4AA),
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (playlistService.cosmicPlaylist != null)
                            Text(
                              '${playlistService.cosmicPlaylist!.trackCount} tracks • ${playlistService.cosmicPlaylist!.formattedDuration}',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 12,
                                color: Colors.white.withAlpha(150),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: 250,
                        child: Text(
                          'Your Daily Cosmic\nSoundtrack',
                          style: GoogleFonts.syne(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Play button (Floating style)
                  GestureDetector(
                    onTap: _openSpotifyPlaylist,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF1DB954), Color(0xFF1ED760)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF1DB954).withAlpha(100),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded, 
                        color: Colors.white, 
                        size: 32
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Divider
            Divider(color: Colors.white.withAlpha(25), height: 1),
            
            // Track list preview
            _buildPlaylistPreview(),
            
            // Footer action
             if (playlistService.spotifyPlaylistUrl != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(10),
                  border: Border(top: BorderSide(color: Colors.white.withAlpha(20))),
                ),
                child: Center(
                  child: Text(
                    'Open in Spotify App',
                    style: GoogleFonts.syne(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withAlpha(200),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlaylistPreview() {
    List<Widget> trackItems = [];
    
    // Handle CosmicPlaylist (has CosmicTrack with name/artist)
    if (playlistService.cosmicPlaylist != null) {
      final tracks = playlistService.cosmicPlaylist!.tracks.take(4);
      trackItems = tracks.map((track) => _buildTrackRow(track.name, track.artist)).toList();
    }
    // Handle DatasetPlaylist (has DatasetTrack with trackName/artists)
    else if (playlistService.datasetPlaylist != null) {
      final tracks = playlistService.datasetPlaylist!.tracks.take(4);
      trackItems = tracks.map((track) => _buildTrackRow(track.trackName, track.artists)).toList();
    }
    
    if (trackItems.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(children: trackItems),
    );
  }
  
  Widget _buildTrackRow(String name, String artist) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // Track artwork placeholder
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: [
                  AppColors.cosmicPurple.withAlpha(100),
                  AppColors.hotPink.withAlpha(100),
                ],
              ),
            ),
            child: const Icon(Icons.music_note, color: Colors.white54, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.syne(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  artist,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: Colors.white.withAlpha(150),
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
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              'Seasonal Focus',
              style: GoogleFonts.syne(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const GlassCard(
            padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: CosmicWaveLoader(),
          ),
        ],
      );
    }
    
    // Error state
    if (_seasonalPulseError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Text(
              'Seasonal Focus',
              style: GoogleFonts.syne(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
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
            : Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  'Seasonal Focus',
                  style: GoogleFonts.syne(
                    fontSize: 18,                                            
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
          const SizedBox(height: 16),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
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
        const SizedBox(height: 20),
        
        // Focus area grid
        _buildFocusGrid(elementColor),
      ],
    );
  }
  
  Widget _buildCompactSeasonHeader(Color elementColor) {
    final pulse = _seasonalPulse!;
    
    return BackgroundImageCard(
      imagePath: 'assets/images/card_backgrounds/seasonal_guidance_bg.png',
      padding: const EdgeInsets.all(16),
      borderRadius: 20,
      child: Row(
        children: [
          // Small orb with zodiac symbol
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  elementColor.withAlpha(150),
                  elementColor.withAlpha(50),
                ],
              ),
              border: Border.all(color: Colors.white.withAlpha(100), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: elementColor.withAlpha(80),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                pulse.symbol,
                style: const TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Season info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CURRENT SEASON',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withAlpha(180),
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${pulse.activeSign} Season', // e.g. "Pisces Season"
                  style: GoogleFonts.syne(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  pulse.dateRange,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    color: Colors.white.withAlpha(150),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFocusGrid(Color elementColor) {
    final themes = _seasonalPulse!.themes;
    
    return Wrap(
      spacing: 12,
      runSpacing: 16,
      children: themes.asMap().entries.map((entry) {
        final index = entry.key;
        final theme = entry.value;
        // Cycle through backgrounds
        final bgImage = _cardBackgrounds[index % _cardBackgrounds.length];

        return SizedBox(
          width: (MediaQuery.of(context).size.width - 52) / 2, // 2 columns with padding
          child: FocusAreaCard(
            theme: theme,
            elementColor: elementColor,
            onTap: () => _showVibePreview(theme, elementColor),
            backgroundImage: bgImage, // Dynamic background
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
