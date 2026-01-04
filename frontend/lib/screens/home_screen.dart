import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../config/design_tokens.dart';
import '../widgets/app_header.dart';
import '../widgets/glass_card.dart';
import '../widgets/daily_sound_wheel/daily_sound_wheel.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/cosmic_wave_loader.dart';
import '../widgets/inline_error.dart';
import '../services/audio_service.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/spotify_service.dart';
import '../services/session_cache_service.dart';
import '../models/sonification.dart';
import '../models/ai_responses.dart';
import '../models/playlist.dart';

import '../models/birth_data.dart';

import '../services/playlist_service.dart';
import '../data/test_users.dart';
import '../widgets/zodiac_season_card_widget.dart';
import '../models/zodiac_season_card.dart';

/// Home screen with sound orbs, alignment score, and cosmic queue.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioService _audioService = AudioService();
  final ApiService _apiService = ApiService();
  final SpotifyService _spotifyService = SpotifyService();
  
  bool _isPlayingDailySound = false;
  ChartSonification? _userSonification;
  ChartSonification? _dailySonification;
  DailyReading? _dailyReading;
  bool _isLoadingReading = false;
  String? _readingError;
  bool _isLoadingSonification = true;
  
  // User's genre preferences from onboarding
  List<String> _userMainGenres = [];
  
  // Carousel state for Today's Reading (Old) - Removed as redundant with new card layout
  

  

  
  // Birth data from storage (or fallback to test data)
  BirthData? _birthData;
  
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

  // Fallback data when API is unavailable
  Map<String, String> get todaysReading => {
    'sign': _getCurrentZodiacSign(),
    'date': _formatCurrentDate(),
    'energy': _dailyReading?.energyLabel ?? 'Loading...',
    'mood': _dailyReading?.mood ?? 'Loading...',
    'bpm': _dailyReading?.playlistParams.bpmRange ?? '---',
    'vibe': _dailyReading?.reading ?? 'Connecting to the cosmos...',
  };
  
  /// Get the current zodiac sign based on today's date
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
    return 'Pisces'; // Feb 19 - Mar 20
  }
  
  String _formatCurrentDate() {
    final now = DateTime.now();
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  final alignedFriends = [
    {'name': 'Maya', 'color1': const Color(0xFFFF59D0), 'color2': const Color(0xFF7D67FE)},
    {'name': 'Jordan', 'color1': const Color(0xFFFAFF0E), 'color2': const Color(0xFFFF59D0)},
    {'name': 'Alex', 'color1': const Color(0xFF7D67FE), 'color2': const Color(0xFF00D4AA)},
  ];

  final playlist = [
    {'title': 'Midnight Protocol', 'artist': 'Orbital Dreams', 'duration': '6:42', 'energy': 78},
    {'title': 'Plutonian Depths', 'artist': 'Modular Witch', 'duration': '5:18', 'energy': 85},
    {'title': 'Dissolve', 'artist': 'Kiasmos', 'duration': '7:03', 'energy': 62},
  ];

  // alignmentScore is now dynamic from _alignmentScore state variable

  @override
  void initState() {
    super.initState();
    _loadBirthDataAndInit();
    
    // Listen to global playlist service
    playlistService.addListener(_onPlaylistServiceUpdate);
    playlistService.init();

    _audioService.playingStream.listen((isPlaying) {
      if (mounted && !isPlaying) {
        setState(() {
          // _isPlayingUserSound is removed
          _isPlayingDailySound = false;
        });
      }
    });
  }

  void _onPlaylistServiceUpdate() {
    if (mounted) {
      setState(() {
        // Trigger rebuild when service updates
      });
    }
  }
  
  Future<void> _loadBirthDataAndInit() async {
    // Load birth data from storage (fast, local)
    final stored = await storageService.loadBirthData();
    if (mounted) {
      setState(() => _birthData = stored);
    }
    
    // Load genre preferences from onboarding (fast, local)
    final genrePrefs = await storageService.loadGenres();
    if (mounted) {
      setState(() {
        _userMainGenres = genrePrefs.genres;
      });
    }
    
    // PERFORMANCE OPTIMIZATION: Fire AI reading immediately (slowest API call)
    // This runs in parallel with everything else below
    _loadDailyReading();
    
    // Load cached playlist state and Spotify status
    await playlistService.init();
    
    // Load all API data in parallel
    Future.wait([
      _loadSonificationData(),
      _loadZodiacSeasonCard(),
    ]);
  }
  



  @override
  void dispose() {
    playlistService.removeListener(_onPlaylistServiceUpdate);
    _audioService.dispose();
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _loadSonificationData() async {
    // Check cache first
    final cache = SessionCacheService();
    if (cache.userSonification != null && cache.dailySonification != null) {
      setState(() {
        _userSonification = cache.userSonification;
        _dailySonification = cache.dailySonification;
        _isLoadingSonification = false;
      });
      return;
    }
    
    setState(() => _isLoadingSonification = true);
    
    try {
      // Load user's sound and daily sound in parallel
      final results = await Future.wait([
        _apiService.getUserSonification(
          datetime: _birthDataMap['datetime'] as String,
          latitude: _birthDataMap['latitude'] as double,
          longitude: _birthDataMap['longitude'] as double,
          timezone: _birthDataMap['timezone'] as String,
        ),
        _apiService.getDailySonification(
          latitude: _birthDataMap['latitude'] as double,
          longitude: _birthDataMap['longitude'] as double,
        ),
      ]);
      
      if (mounted) {
        // Store in cache
        cache.cacheUserSonification(results[0]);
        cache.cacheDailySonification(results[1]);
        
        setState(() {
          _userSonification = results[0];
          _dailySonification = results[1];
          _isLoadingSonification = false;
        });
      }
    } catch (e) {
      // Sonification failed - orbs will show skeletons
      if (mounted) {
        setState(() => _isLoadingSonification = false);
      }
    }
    // Note: _loadDailyReading is now called independently in _loadBirthDataAndInit
  }
  
  Future<void> _loadDailyReading() async {
    if (_isLoadingReading) return;
    
    // Check cache first
    final cache = SessionCacheService();
    if (cache.hasAiReading('daily_reading')) {
      setState(() {
        _dailyReading = cache.getAiReading('daily_reading') as DailyReading;
        _isLoadingReading = false;
      });
      return;
    }
    
    setState(() {
      _isLoadingReading = true;
      _readingError = null;
    });
    
    try {
      final reading = await _apiService.getDailyReading(
        datetime: _birthDataMap['datetime'] as String,
        latitude: _birthDataMap['latitude'] as double,
        longitude: _birthDataMap['longitude'] as double,
        timezone: _birthDataMap['timezone'] as String,
      );
      
      if (mounted) {
        // Store in cache
        cache.cacheAiReading('daily_reading', reading);
        
        setState(() {
          _dailyReading = reading;
          _isLoadingReading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _readingError = 'Could not load reading';
          _isLoadingReading = false;
        });
      }
    }
  }
  
  Future<void> _loadZodiacSeasonCard() async {
    if (_isLoadingSeasonCard) return;
    
    // Check cache first using season key
    final cache = SessionCacheService();
    if (cache.hasAiReading('zodiac_season_card')) {
      final cached = cache.getAiReading('zodiac_season_card') as ZodiacSeasonCardData?;
      if (cached != null && cached.cachedUntil.isAfter(DateTime.now())) {
        setState(() {
          _zodiacSeasonCard = cached;
          _isLoadingSeasonCard = false;
        });
        return;
      }
    }
    
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
        // Cache for season duration
        cache.cacheAiReading('zodiac_season_card', card);
        
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

  Future<void> _generatePlaylist() async {
    // Extract sun, moon, rising signs from sonification data
    String sunSign = _getCurrentZodiacSign();
    String moonSign = 'Pisces'; // Default fallback
    String risingSign = 'Scorpio'; // Default fallback
    
    if (_userSonification != null) {
      sunSign = _userSonification!.bigFour['sun']?.sign ?? sunSign;
      moonSign = _userSonification!.bigFour['moon']?.sign ?? moonSign;
      // Rising sign is the ascendant
      risingSign = _userSonification!.bigFour['rising']?.sign ?? risingSign;
    }
    
    // Combine genres - use main genres, fall back to defaults if empty
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



  void _sharePlaylistInsight() {
    if (playlistService.playlistInsight == null) return;
    
    final text = '''🎵 My Cosmic Playlist

${playlistService.playlistInsight!.insight}

✨ ${playlistService.playlistInsight!.astroHighlight}
⚡ Energy: ${playlistService.playlistInsight!.energyPercent}%
🎭 Mood: ${playlistService.playlistInsight!.dominantMood}

Generated by Astro.FM''';
    
    Share.share(text);
  }



  void _playDailySound() {
    if (_isPlayingDailySound) {
      _audioService.stop();
      setState(() => _isPlayingDailySound = false);
    } else if (_dailySonification != null) {
      _audioService.stop();
      _audioService.playChartSound(_dailySonification!);
      setState(() {
        _isPlayingDailySound = true;
        // _isPlayingUserSound is removed
      });
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
            const AppHeader(showSettingsButton: true),
            const SizedBox(height: 16),

            // Sound Orbs Section
            _buildSoundOrbsSection(),
            const SizedBox(height: 20),

            // CTA Buttons
            _buildCtaButtons(),
            const SizedBox(height: 24),

            // Today's Resonance
            _buildTodaysResonance(),
            const SizedBox(height: 24),
            
            // Zodiac Season Card
            _buildZodiacSeasonCardSection(),
            const SizedBox(height: 24),

            // Cosmic Queue
            _buildCosmicQueue(),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundOrbsSection() {
    return Column(
      children: [
        // Today's Sound Wheel - shows daily planet positions
        DailySoundWheel(
          sonification: _dailySonification,
          isPlaying: _isPlayingDailySound,
          isLoading: _isLoadingSonification,
          onPlayPressed: _playDailySound,
        ),
        const SizedBox(height: 14),
        Text(
          'TODAY\'S SOUND',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            color: Colors.white.withAlpha(128),
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _isLoadingSonification 
            ? 'Loading...'
            : (_isPlayingDailySound ? 'Now Playing' : 'Tap to Play'),
          style: GoogleFonts.syne(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: _isPlayingDailySound ? AppColors.electricYellow : Colors.white.withAlpha(153),
          ),
        ),
      ],
    );
  }



  Widget _buildCtaButtons() {
    return Row(
      children: [
        Expanded(
          child: _CtaButton(
            label: 'Align Now',
            icon: Icons.access_time_rounded,
            gradient: const LinearGradient(
              colors: [AppColors.cosmicPurple, AppColors.hotPink],
            ),
            onPressed: () => Navigator.pushNamed(context, '/align'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _CtaButton(
            label: 'Generate',
            icon: Icons.music_note_rounded,
            gradient: const LinearGradient(
              colors: [AppColors.electricYellow, Color(0xFFE5EB0D)],
            ),
            textColor: AppColors.background,
            onPressed: playlistService.isGenerating ? null : () { _generatePlaylist(); },
          ),
        ),
      ],
    );
  }

  Widget _buildTodaysResonance() {
    // Show error state with retry
    if (_readingError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReadingHeader(),
          const SizedBox(height: 12),
          GlassCard(
            child: InlineError(
              message: _readingError!,
              onRetry: _loadDailyReading,
            ),
          ),
        ],
      );
    }
    
    // Show skeleton while loading
    if (_isLoadingReading && _dailyReading == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReadingHeader(),
          const SizedBox(height: 12),
          SkeletonLoader(
            width: double.infinity,
            height: 180,
            borderRadius: BorderRadius.circular(20),
            color: Colors.white.withAlpha(15),
          ),
        ],
      );
    }
    
    // New horoscope-style card
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHoroscopeCard(),
      ],
    );
  }
  
  /// Build the premium luxury horoscope card inspired by the latest design
  Widget _buildHoroscopeCard() {
    final reading = _dailyReading;
    if (reading == null) {
      return GlassCard(
        child: Text(
          'Connecting to the cosmos...',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            height: 1.6,
            color: Colors.white.withAlpha(179),
          ),
        ),
      );
    }
    
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0F),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withAlpha(20)),
        boxShadow: [
          BoxShadow(
            color: AppColors.cosmicPurple.withAlpha(24),
            blurRadius: 50,
            spreadRadius: -10,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Background Glow Orb (Subtle)
          Positioned(
            top: -40,
            right: -20,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.electricYellow.withAlpha(30),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row: DATE & SHARE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.electricYellow,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'TODAY\'S READING',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            color: Colors.white.withAlpha(128),
                            letterSpacing: 2,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '•',
                          style: TextStyle(color: Colors.white.withAlpha(77)),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatCurrentDate(),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            color: Colors.white.withAlpha(102),
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.share_outlined, size: 14, color: Colors.white60),
                  ],
                ),
                const SizedBox(height: 24),
                
                // MAIN HEADLINE (Gradient)
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Colors.white, AppColors.electricYellow, AppColors.hotPink],
                    stops: [0.0, 0.4, 1.0],
                  ).createShader(bounds),
                  child: Text(
                    reading.headline.toUpperCase(),
                    style: GoogleFonts.syne(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                
                // SUBHEADLINE
                Text(
                  reading.subheadline,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    color: Colors.white.withAlpha(180),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),
                
                // TAGS / INFO PILLS
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildLuxuryInfoPill(
                      '○', 
                      reading.moonPhase, 
                      AppColors.electricYellow
                    ),
                    if (reading.houseContext.isNotEmpty)
                      _buildLuxuryInfoPill(
                        '⬡', 
                        reading.houseContext.split(' ').last, 
                        AppColors.cosmicPurple
                      ),
                    _buildLuxuryInfoPill(
                      '◈', 
                      reading.dominantElement, 
                      const Color(0xFF00B4D8)
                    ),
                    _buildLuxuryInfoPill(
                      '◎', 
                      reading.focusArea, 
                      AppColors.hotPink
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // THE MESSAGE (HOROSCOPE)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cosmicPurple.withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.cosmicPurple.withAlpha(40)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('✦', style: TextStyle(color: AppColors.cosmicPurple)),
                          const SizedBox(width: 8),
                          Text(
                            'THE MESSAGE',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.cosmicPurple,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        reading.horoscope,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          color: Colors.white.withAlpha(200),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                
                // TODAY'S MOVE (ADVICE)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.electricYellow.withAlpha(15),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.electricYellow.withAlpha(30)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('→', style: TextStyle(color: AppColors.electricYellow)),
                          const SizedBox(width: 8),
                          Text(
                            'TODAY\'S MOVE',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.electricYellow,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '"${reading.actionableAdvice}"',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withAlpha(230),
                          fontStyle: FontStyle.italic,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // ENERGY BAR
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          reading.energyLabel.toUpperCase(),
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withAlpha(100),
                            letterSpacing: 1.5,
                          ),
                        ),
                        Text(
                          '${reading.energyLevel}%',
                          style: GoogleFonts.syne(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getEnergyColor(reading.energyLevel),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 4,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        widthFactor: reading.energyLevel / 100,
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.cosmicPurple,
                                _getEnergyColor(reading.energyLevel),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Cosmic weather technical footer
                Text(
                  reading.cosmicWeather,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    color: Colors.white.withAlpha(100),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  


  /// Build the luxury version of the info pill
  Widget _buildLuxuryInfoPill(String emoji, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(40),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji, 
            style: TextStyle(
              fontSize: emoji.length > 1 ? 10 : 12, 
              color: color
            )
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
  

  
  /// Get color based on energy level
  Color _getEnergyColor(int level) {
    if (level >= 80) return AppColors.electricYellow;
    if (level >= 60) return AppColors.hotPink;
    if (level >= 40) return AppColors.cosmicPurple;
    return const Color(0xFF59A5FF);
  }


  /// Build the header row for Today's Reading section
  Widget _buildReadingHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'TODAY\'S READING',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withAlpha(128),
              letterSpacing: 1.5,
            ),
          ),
          // Moon phase indicator from reading
          if (_dailyReading != null)
            Text(
              _dailyReading!.moonPhaseEmoji,
              style: const TextStyle(fontSize: 16),
            ),
        ],
      ),
    );
  }

  /// Build a single signal card for the horizontal carousel with 3-part messages
  Widget _buildCarouselSignalCard(DailySignal signal) {
    // Color based on signal type
    Color accentColor;
    String iconSymbol;
    
    switch (signal.signalType) {
      case 'resonance':
        accentColor = const Color(0xFF00D4AA); // Teal green
        iconSymbol = '✓';
        break;
      case 'feedback':
        accentColor = const Color(0xFFFAFF0E); // Yellow
        iconSymbol = '⚠';
        break;
      case 'dissonance':
        accentColor = const Color(0xFFE84855); // Red
        iconSymbol = '✕';
        break;
      default:
        accentColor = Colors.white.withAlpha(128);
        iconSymbol = '•';
    }
    
    // Use new 3-part messages if available, fallback to legacy message
    final audioText = signal.audioMessage.isNotEmpty ? signal.audioMessage : signal.message;
    final cosmicText = signal.cosmicMessage;
    final adviceText = signal.adviceMessage;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withAlpha(15)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left colored bar
            Container(
              width: 3,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          // Card content - 3 part layout
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: icon + type + category
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: accentColor.withAlpha(51),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                iconSymbol,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: accentColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            signal.signalType.toUpperCase(),
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      signal.category,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        color: Colors.white.withAlpha(102),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Combined message paragraph with — separator
                Text(
                  _buildCombinedMessage(audioText, cosmicText, adviceText),
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    height: 1.6,
                    color: Colors.white.withAlpha(204),
                  ),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }

  /// Build combined message paragraph with — separator
  String _buildCombinedMessage(String audio, String cosmic, String advice) {
    final parts = <String>[];
    if (audio.isNotEmpty) parts.add(audio);
    if (cosmic.isNotEmpty) parts.add(cosmic);
    if (advice.isNotEmpty) parts.add(advice);
    return parts.join(' — ');
  }

  /// Get mood icon and color based on valence value
  Map<String, dynamic> _getMoodInfo(double valence) {
    if (valence > 0.7) {
      return {'icon': '⚡', 'label': 'Upbeat', 'color': const Color(0xFFFAFF0E)};
    } else if (valence > 0.55) {
      return {'icon': '♪', 'label': 'Groovy', 'color': const Color(0xFFFF59D0)};
    } else if (valence > 0.4) {
      return {'icon': '◐', 'label': 'Chill', 'color': const Color(0xFF7D67FE)};
    } else if (valence > 0.25) {
      return {'icon': '◈', 'label': 'Dreamy', 'color': const Color(0xFF00D4AA)};
    } else {
      return {'icon': '◇', 'label': 'Mellow', 'color': const Color(0xFF7D67FE)};
    }
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
                // Ready status badge (shown when playlist is loaded)
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
              )

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
        // Show error with retry button
        else if (playlistService.error != null)
          GlassCard(
            child: Column(
              children: [
                InlineError(
                  message: playlistService.error!,
                  onRetry: () {
                    _generatePlaylist();
                  },
                ),
              ],
            ),
          )
        // Show empty state
        else if (!playlistService.hasPlaylist)
          GlassCard(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.music_note_rounded,
                      size: 48,
                      color: Colors.white.withAlpha(77),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No playlist yet',
                      style: GoogleFonts.syne(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withAlpha(128),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap "Generate Playlist" to discover\nyour personalized cosmic queue',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        color: Colors.white.withAlpha(102),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        // Show actual playlist
        else
          Column(
            children: [
              // AI Playlist Insight Card
              if (playlistService.isLoadingInsight)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    borderColor: AppColors.cosmicPurple.withAlpha(51),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.cosmicPurple, AppColors.hotPink],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.auto_awesome, size: 12, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    'INSIGHT',
                                    style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 1),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(height: 12, width: double.infinity, decoration: BoxDecoration(color: Colors.white.withAlpha(20), borderRadius: BorderRadius.circular(6))),
                        const SizedBox(height: 8),
                        Container(height: 12, width: 200, decoration: BoxDecoration(color: Colors.white.withAlpha(20), borderRadius: BorderRadius.circular(6))),
                      ],
                    ),
                  ),
                )
              else if (playlistService.playlistInsight != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    borderColor: AppColors.cosmicPurple.withAlpha(51),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with AI badge and share
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [AppColors.cosmicPurple, AppColors.hotPink],
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.auto_awesome, size: 12, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    'WHY THIS PLAYLIST',
                                    style: GoogleFonts.spaceGrotesk(fontSize: 9, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: 1),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: _sharePlaylistInsight,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white.withAlpha(13),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.share_rounded, size: 16, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        // Insight text
                        Text(
                          playlistService.playlistInsight!.insight,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            height: 1.5,
                            color: Colors.white.withAlpha(230),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Stats row
                        Row(
                          children: [
                            _buildStatPill('\u2728 ${playlistService.playlistInsight!.astroHighlight}', AppColors.cosmicPurple),
                            const SizedBox(width: 8),
                            _buildStatPill('\u26a1 ${playlistService.playlistInsight!.energyPercent}%', AppColors.electricYellow),
                            const SizedBox(width: 8),
                            _buildStatPill('\ud83c\udfad ${playlistService.playlistInsight!.dominantMood}', AppColors.hotPink),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              
              // Song list - Show Spotify tracks if available
              GlassCard(
                padding: const EdgeInsets.all(8),
                child: Column(
                  children: playlistService.cosmicPlaylist != null
                    ? playlistService.cosmicPlaylist!.tracks.asMap().entries.map((entry) {
                        final index = entry.key;
                        final track = entry.value;
                        return _buildCosmicTrackItem(track, index);
                      }).toList()
                    : playlistService.datasetPlaylist != null
                    ? playlistService.datasetPlaylist!.tracks.asMap().entries.map((entry) {
                        final index = entry.key;
                        final track = entry.value;
                        return _buildDatasetTrackItem(track, index);
                      }).toList()
                    : playlistService.spotifyLibraryTracks.isNotEmpty
                      ? playlistService.spotifyLibraryTracks.asMap().entries.map((entry) {
                          final index = entry.key;
                          final track = entry.value;
                          return _buildSpotifyTrackItem(track, index);
                        }).toList()
                      : playlistService.generatedPlaylist != null 
                        ? playlistService.generatedPlaylist!.songs.asMap().entries.map((entry) {
                            final index = entry.key;
                            final song = entry.value;
                            return _buildPlaylistItem(song, index);
                          }).toList()
                        : [], // Empty if neither has data (shouldn't happen due to else condition)
                ),
              ),
            ],
          ),
      ],
    );
  }

  /// Build a dataset track item for display in the Cosmic Queue
  Widget _buildDatasetTrackItem(DatasetTrack track, int index) {
    final moodInfo = _getMoodInfo(track.valence);
    final moodColor = moodInfo['color'] as Color;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: index > 0 ? Border(top: BorderSide(color: Colors.white.withAlpha(13))) : null,
      ),
      child: Row(
        children: [
          // Track number
          SizedBox(
            width: 24,
            child: Text(
              '${index + 1}',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                color: Colors.white.withAlpha(102),
              ),
            ),
          ),
          // Track info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.trackName,
                  style: GoogleFonts.syne(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      track.artists,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: Colors.white.withAlpha(153),
                      ),
                    ),
                    if (track.mainGenre != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.cosmicPurple.withAlpha(51),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          track.mainGenre!,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 9,
                            color: AppColors.cosmicPurple,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Duration and mood pill
          Row(
            children: [
              Text(
                track.formattedDuration,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  color: Colors.white.withAlpha(128),
                ),
              ),
              const SizedBox(width: 8),
              // Colored mood pill with icon
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: moodColor.withAlpha(38),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      moodInfo['icon'] as String,
                      style: TextStyle(fontSize: 12, color: moodColor),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      moodInfo['label'] as String,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: moodColor,
                      ),
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

  /// Build a cosmic track item for display in the Cosmic Queue
  Widget _buildCosmicTrackItem(CosmicTrack track, int index) {
    return GestureDetector(
      onTap: () async {
        // Open track in Spotify
        if (track.url.isNotEmpty) {
          await _spotifyService.openPlaylist(track.url);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: index > 0 ? Border(top: BorderSide(color: Colors.white.withAlpha(13))) : null,
        ),
        child: Row(
          children: [
            // Album art or track number
            if (track.albumArt != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  track.albumArt!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.cosmicPurple.withAlpha(51),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: Colors.white.withAlpha(128),
                        ),
                      ),
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                width: 24,
                child: Text(
                  '${index + 1}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: Colors.white.withAlpha(102),
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
                    track.name,
                    style: GoogleFonts.syne(
                      fontSize: 14,
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
                      fontSize: 12,
                      color: Colors.white.withAlpha(153),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Spotify icon to indicate playable
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF1DB954).withAlpha(38),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                size: 16,
                color: Color(0xFF1DB954),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build a Spotify track item for display in the Cosmic Queue
  Widget _buildSpotifyTrackItem(SpotifyTrack track, int index) {
    final moodInfo = _getMoodInfo(track.valence ?? 0.5);
    final moodColor = moodInfo['color'] as Color;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        border: index > 0 ? Border(top: BorderSide(color: Colors.white.withAlpha(13))) : null,
      ),
      child: Row(
        children: [
          // Track number
          SizedBox(
            width: 24,
            child: Text(
              '${index + 1}',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.hotPink,
              ),
            ),
          ),
          // Track info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  track.name,
                  style: GoogleFonts.syne(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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
                ),
              ],
            ),
          ),
          // Mood pill with icon
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: moodColor.withAlpha(38),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  moodInfo['icon'] as String,
                  style: TextStyle(fontSize: 12, color: moodColor),
                ),
                const SizedBox(width: 4),
                Text(
                  moodInfo['label'] as String,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: moodColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatPill(String text, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withAlpha(51)),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: color,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildPlaylistItem(Song song, int index) {
    final colors = index % 2 == 0
        ? [AppColors.hotPink, AppColors.cosmicPurple]
        : [AppColors.cosmicPurple, AppColors.electricYellow];

    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: LinearGradient(colors: colors),
            ),
            child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  style: GoogleFonts.syne(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  song.artist,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: Colors.white.withAlpha(128),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                LinearProgressIndicator(
                  value: song.energy / 100,
                  backgroundColor: Colors.white.withAlpha(26),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Color.lerp(AppColors.hotPink, AppColors.electricYellow, song.energy / 100)!,
                  ),
                  minHeight: 3,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Text(
            song.formattedDuration,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 12,
              color: Colors.white.withAlpha(102),
            ),
          ),
        ],
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Gradient gradient;
  final Color textColor;
  final VoidCallback? onPressed;

  const _CtaButton({
    required this.label,
    required this.icon,
    required this.gradient,
    this.textColor = Colors.white,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (gradient as LinearGradient).colors.first.withAlpha(77),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: textColor, size: 20),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: GoogleFonts.syne(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
