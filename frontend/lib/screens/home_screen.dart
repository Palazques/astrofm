import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../config/design_tokens.dart';
import 'main_shell.dart';
import '../widgets/app_header.dart';
import '../widgets/daily_sound_wheel/daily_sound_wheel.dart';
import '../widgets/birth_chart_wheel/birth_chart_wheel.dart';
import '../widgets/skeleton_loader.dart';
import '../services/audio_service.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/session_cache_service.dart';
import '../models/sonification.dart';
import '../models/ai_responses.dart';
import '../models/birth_data.dart';
import '../models/sound_recommendation.dart';
import '../services/playlist_service.dart';
import '../widgets/sound_recommendation_card.dart';
import '../data/test_users.dart';
// New modular components
import '../widgets/home/daily_essence_card.dart';
import '../widgets/home/full_reading_modal.dart';
import '../widgets/home/mode_toggle.dart';
import '../widgets/home/cta_button_group.dart';

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
  
  // Sound recommendations
  SoundRecommendationsResponse? _soundRecommendations;
  bool _isLoadingRecommendations = false;
  
  // Chart mode toggle: 'my_chart' or 'sky_mode'
  String _chartMode = 'my_chart';
  
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
    
    // Load sound recommendations (in parallel)
    _loadSoundRecommendations();
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

            // Compact Daily Essence Card (collapsible horoscope)
            DailyEssenceCard(
              reading: _dailyReading,
              isLoading: _isLoadingReading,
              error: _readingError,
              onRetry: _loadDailyReading,
              onExpand: () {
                if (_dailyReading != null) {
                  FullReadingModal.show(
                    context, 
                    _dailyReading!,
                    onShare: _shareHoroscope,
                  );
                }
              },
              onShare: _shareHoroscope,
            ),
            const SizedBox(height: 20),

            // CTA Buttons (elevated position - above the fold)
            CtaButtonGroup(
              onAlignTap: () => MainShellController.of(context)?.switchTab('align'),
              onDiscoverTap: () => MainShellController.of(context)?.switchTab('soundscape'),
            ),
            const SizedBox(height: 24),

            // Mode Toggle
            ChartModeToggle(
              activeMode: _chartMode,
              onModeChanged: (mode) => setState(() => _chartMode = mode),
            ),
            const SizedBox(height: 20),

            // Sound/Chart Section based on mode
            if (_chartMode == 'my_chart')
              _buildMyChartSection()
            else
              _buildSoundOrbsSection(),
            const SizedBox(height: 20),
            
            // Simplified Sound Recommendation (primary only)
            if (_soundRecommendations != null)
              _buildSoundRecommendationSection(),
          ],
        ),
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

  Future<void> _loadSoundRecommendations() async {
    if (_isLoadingRecommendations) return;
    
    setState(() => _isLoadingRecommendations = true);
    
    try {
      final recommendations = await _apiService.getSoundRecommendations(
        datetime: _birthDataMap['datetime'] as String,
        latitude: _birthDataMap['latitude'] as double,
        longitude: _birthDataMap['longitude'] as double,
        timezone: _birthDataMap['timezone'] as String,
      );
      
      if (mounted) {
        setState(() {
          _soundRecommendations = recommendations;
          _isLoadingRecommendations = false;
        });
      }
    } catch (e) {
      // Silently fail - card just won't show
      if (mounted) {
        setState(() => _isLoadingRecommendations = false);
      }
    }
  }
  
  Widget _buildSoundRecommendationSection() {
    if (_soundRecommendations == null) {
      return const SizedBox.shrink();
    }
    
    return SoundRecommendationCard(
      recommendations: _soundRecommendations!,
      onPrimaryTap: () {
        // Play the primary recommendation sound
        final primary = _soundRecommendations!.primaryRecommendation;
        if (primary != null) {
          _audioService.playFrequency(primary.frequency);
        }
      },
      onLifeAreaSelect: (lifeAreaKey) async {
        // Load specific life area recommendation
        try {
          final rec = await _apiService.getSoundRecommendationByLifeArea(
            datetime: _birthDataMap['datetime'] as String,
            latitude: _birthDataMap['latitude'] as double,
            longitude: _birthDataMap['longitude'] as double,
            lifeAreaKey: lifeAreaKey,
            timezone: _birthDataMap['timezone'] as String,
          );
          // Play it
          _audioService.playFrequency(rec.frequency);
        } catch (e) {
          // Silently handle
        }
      },
      onSecondaryTap: (rec) {
        // Play the tapped secondary recommendation
        _audioService.playFrequency(rec.frequency);
      },
    );
  }
}
