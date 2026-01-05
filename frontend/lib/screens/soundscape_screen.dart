import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/design_tokens.dart';
import '../widgets/app_header.dart';
import '../widgets/glass_card.dart';
import '../widgets/inline_error.dart';
import '../widgets/zodiac_season_card_widget.dart';
import '../widgets/cosmic_wave_loader.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/spotify_service.dart';
import '../services/playlist_service.dart';
import '../models/zodiac_season_card.dart';
import '../models/birth_data.dart';
import '../data/test_users.dart';

/// Soundscape screen - the new Playlist Hub for music & curation.
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
  
  // Zodiac Season Card state
  ZodiacSeasonCardData? _zodiacSeasonCard;
  bool _isLoadingSeasonCard = false;
  String? _seasonCardError;
  
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
    
    // Load Zodiac Season Card
    _loadZodiacSeasonCard();
  }
  
  Future<void> _loadZodiacSeasonCard() async {
    if (_isLoadingSeasonCard) return;
    
    setState(() {
      _isLoadingSeasonCard = true;
      _seasonCardError = null;
    });
    
    try {
      final card = await _apiService.getZodiacSeasonCard(
        datetime: _birthDataMap['datetime'] as String,
        latitude: _birthDataMap['latitude'] as double,
        longitude: _birthDataMap['longitude'] as double,
        timezone: _birthDataMap['timezone'] as String,
        genrePreferences: _userMainGenres.isNotEmpty 
            ? _userMainGenres 
            : ['indie rock', 'electronic', 'pop'],
      );
      
      if (mounted) {
        setState(() {
          _zodiacSeasonCard = card;
          _isLoadingSeasonCard = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _seasonCardError = 'Could not load season card';
          _isLoadingSeasonCard = false;
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
    // Extract signs - in a real app, these would come from the birth chart data
    // For now we'll use sun as the current sign and fallbacks for others
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

            // Zodiac Season Card (Feature)
            _buildZodiacSeasonCardSection(),
            const SizedBox(height: 24),

            // Cosmic Queue (Playlists)
            _buildCosmicQueue(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildZodiacSeasonCardSection() {
    return ZodiacSeasonCardWidget(
      data: _zodiacSeasonCard,
      isLoading: _isLoadingSeasonCard,
      errorMessage: _seasonCardError,
      onRetry: _loadZodiacSeasonCard,
      onPlayPressed: () {
        // Could trigger Spotify playback here
      },
      onOpenSpotify: () {
        if (_zodiacSeasonCard?.playlistUrl != null) {
          _spotifyService.openPlaylist(_zodiacSeasonCard!.playlistUrl!);
        }
      },
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
}
