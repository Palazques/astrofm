import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../config/design_tokens.dart';
import 'main_shell.dart';
import '../widgets/app_header.dart';
import '../widgets/glass_card.dart';
import '../widgets/daily_sound_wheel/daily_sound_wheel.dart';
import '../widgets/birth_chart_wheel/birth_chart_wheel.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/inline_error.dart';
import '../services/audio_service.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/session_cache_service.dart';
import '../models/sonification.dart';
import '../models/ai_responses.dart';
import '../models/birth_data.dart';
import '../services/playlist_service.dart';
import '../data/test_users.dart';

/// Home screen with sound orbs, alignment score, and cosmic queue.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioService _audioService = AudioService();
  final ApiService _apiService = ApiService();
  
  bool _isPlayingDailySound = false;
  bool _isPlayingNatalSound = false;
  ChartSonification? _userSonification;
  ChartSonification? _dailySonification;
  DailyReading? _dailyReading;
  bool _isLoadingReading = false;
  String? _readingError;
  bool _isLoadingSonification = true;
  
  // Chart mode toggle: 'my_chart' or 'sky_mode'
  String _chartMode = 'my_chart';
  
  // Carousel state for Today's Reading (Old) - Removed as redundant with new card layout
  

  

  
  // Birth data from storage (or fallback to test data)
  BirthData? _birthData;
  
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
    
    // PERFORMANCE OPTIMIZATION: Fire AI reading immediately (slowest API call)
    // This runs in parallel with everything else below
    _loadDailyReading();
    
    // Load cached playlist state and Spotify status
    await playlistService.init();
    
    // Load sonification data
    _loadSonificationData();
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



  void _shareHoroscope() {
    if (_dailyReading == null) return;
    
    final reading = _dailyReading!;
    final text = '''✨ ${reading.headline.toUpperCase()}

${reading.subheadline}

🌙 ${reading.moonPhase} • ${reading.dominantElement} Energy

📖 THE MESSAGE
${reading.horoscope}

→ TODAY'S MOVE
"${reading.actionableAdvice}"

🌌 ${reading.cosmicWeather}

— Generated by Astro.FM''';
    
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
            const AppHeader(
              showBackButton: false,
              showMenuButton: false,
              showSettingsButton: true,
            ),
            const SizedBox(height: 16),

            // Today's Resonance (Daily Reading at top)
            _buildTodaysResonance(),
            const SizedBox(height: 24),

            // Mode Toggle
            _buildModeToggle(),
            const SizedBox(height: 20),

            // Sound/Chart Section based on mode
            if (_chartMode == 'my_chart')
              _buildMyChartSection()
            else
              _buildSoundOrbsSection(),
            const SizedBox(height: 20),

            // CTA Buttons
            _buildCtaButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(10),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _chartMode = 'my_chart'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _chartMode == 'my_chart' 
                      ? AppColors.cosmicPurple.withAlpha(77) 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                  border: _chartMode == 'my_chart' 
                      ? Border.all(color: AppColors.cosmicPurple.withAlpha(128)) 
                      : null,
                ),
                child: Center(
                  child: Text(
                    'MY CHART',
                    style: GoogleFonts.syne(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _chartMode == 'my_chart' 
                          ? Colors.white 
                          : Colors.white.withAlpha(128),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _chartMode = 'sky_mode'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _chartMode == 'sky_mode' 
                      ? AppColors.electricYellow.withAlpha(77) 
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(26),
                  border: _chartMode == 'sky_mode' 
                      ? Border.all(color: AppColors.electricYellow.withAlpha(128)) 
                      : null,
                ),
                child: Center(
                  child: Text(
                    'SKY MODE',
                    style: GoogleFonts.syne(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _chartMode == 'sky_mode' 
                          ? Colors.white 
                          : Colors.white.withAlpha(128),
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyChartSection() {
    // Show loading state
    if (_isLoadingSonification && _userSonification == null) {
      return Column(
        children: [
          SkeletonLoader(
            width: 280,
            height: 280,
            borderRadius: BorderRadius.circular(140),
            color: Colors.white.withAlpha(15),
          ),
          const SizedBox(height: 16),
          SkeletonLoader(
            width: 200,
            height: 20,
            borderRadius: BorderRadius.circular(10),
            color: Colors.white.withAlpha(10),
          ),
        ],
      );
    }
    
    // Show chart wheel when data is available
    if (_userSonification != null) {
      return Column(
        children: [
          // Play button for natal sound
          _buildNatalPlayButton(),
          const SizedBox(height: 20),
          
          // Birth Chart Wheel
          Center(
            child: BirthChartWheel(
              sonification: _userSonification!,
              audioService: _audioService,
              onPlanetSelected: (planet) {
                if (planet != null) {
                  setState(() => _isPlayingNatalSound = true);
                }
              },
            ),
          ),
        ],
      );
    }
    
    // Fallback
    return const SizedBox.shrink();
  }

  Widget _buildNatalPlayButton() {
    final isDisabled = _isLoadingSonification || _userSonification == null;
    
    return GestureDetector(
      onTap: isDisabled ? null : _toggleNatalPlayback,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          gradient: _isPlayingNatalSound || isDisabled
              ? null
              : const LinearGradient(colors: [AppColors.hotPink, AppColors.cosmicPurple]),
          color: _isPlayingNatalSound 
              ? AppColors.hotPink.withAlpha(51) 
              : (isDisabled ? Colors.grey.withAlpha(51) : null),
          borderRadius: BorderRadius.circular(30),
          border: _isPlayingNatalSound 
              ? Border.all(color: AppColors.hotPink, width: 2) 
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isPlayingNatalSound ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _isPlayingNatalSound ? 'Pause My Sound' : 'Play My Sound',
              style: GoogleFonts.syne(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleNatalPlayback() {
    if (_isPlayingNatalSound) {
      _audioService.stop();
      setState(() => _isPlayingNatalSound = false);
    } else if (_userSonification != null) {
      _audioService.stop();
      _audioService.playChartSound(_userSonification!);
      setState(() {
        _isPlayingNatalSound = true;
        _isPlayingDailySound = false;
      });
    }
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
            onPressed: () => MainShellController.of(context)?.switchTab('align'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _CtaButton(
            label: 'Discover',
            icon: Icons.music_note_rounded,
            gradient: const LinearGradient(
              colors: [AppColors.electricYellow, Color(0xFFE5EB0D)],
            ),
            textColor: AppColors.background,
            onPressed: () => MainShellController.of(context)?.switchTab('soundscape'),
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
                    GestureDetector(
                      onTap: () => _shareHoroscope(),
                      child: const Icon(Icons.share_outlined, size: 14, color: Colors.white60),
                    ),
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

  /// Build the header row for Today's Reading section
  Widget _buildReadingHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'TODAY\'S READING',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white.withAlpha(128),
              letterSpacing: 2,
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
