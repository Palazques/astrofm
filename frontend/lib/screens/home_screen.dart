import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../config/design_tokens.dart';
import '../widgets/app_header.dart';
import '../widgets/glass_card.dart';
import '../widgets/sound_orb.dart';
import '../widgets/skeleton_loader.dart';
import '../widgets/inline_error.dart';
import '../services/audio_service.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../services/spotify_service.dart';
import '../models/sonification.dart';
import '../models/ai_responses.dart';
import '../models/playlist.dart';
import '../models/friend_data.dart';
import '../models/birth_data.dart';
import '../models/monthly_zodiac.dart';
import '../widgets/zodiac_playlist_card.dart';
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
  final SpotifyService _spotifyService = SpotifyService();
  
  bool _isPlayingUserSound = false;
  bool _isPlayingDailySound = false;
  ChartSonification? _userSonification;
  ChartSonification? _dailySonification;
  DailyReading? _dailyReading;
  bool _isLoadingReading = false;
  String? _readingError;
  PlaylistResult? _generatedPlaylist;
  DatasetPlaylistResult? _datasetPlaylist; // New dataset-based playlist
  bool _isGeneratingPlaylist = false;
  String? _playlistError;
  PlaylistInsight? _playlistInsight;
  bool _isLoadingPlaylistInsight = false;
  bool _isLoadingSonification = true;
  
  // User's genre preferences from onboarding
  List<String> _userMainGenres = [];
  List<String> _userSubgenres = [];
  
  // Spotify playlist data
  String? _spotifyPlaylistUrl;
  bool _isCreatingSpotifyPlaylist = false;
  bool _isSpotifyConnected = false;
  List<SpotifyTrack> _spotifyLibraryTracks = [];  // Tracks from user's library
  
  // Alignment data
  int? _alignmentScore;
  String? _dominantEnergy;
  bool _isLoadingAlignment = true;
  String? _alignmentError;
  
  // Monthly zodiac playlist data
  MonthlyZodiacPlaylist? _monthlyZodiacPlaylist;
  bool _isLoadingMonthlyZodiac = false;
  String? _monthlyZodiacError;
  
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
    'energy': _dominantEnergy ?? _dailyReading?.energyLabel ?? 'Loading...',
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
    _audioService.playingStream.listen((isPlaying) {
      if (mounted && !isPlaying) {
        setState(() {
          _isPlayingUserSound = false;
          _isPlayingDailySound = false;
        });
      }
    });
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
        _userSubgenres = genrePrefs.subgenres;
      });
    }
    
    // PERFORMANCE OPTIMIZATION: Fire AI reading immediately (slowest API call)
    // This runs in parallel with everything else below
    _loadDailyReading();
    
    // Load local cache and Spotify status in parallel
    await Future.wait([
      _checkSpotifyConnection(),
      _loadCachedPlaylist(),
    ]);
    
    // Load all API data in parallel (no dependencies between these)
    Future.wait([
      _loadAlignmentScore(),
      _loadSonificationData(),
      _loadMonthlyZodiacPlaylist(),
    ]);
  }
  
  /// Load cached daily playlist if available for today.
  Future<void> _loadCachedPlaylist() async {
    final cached = await storageService.loadDailyPlaylist();
    if (cached != null && mounted) {
      setState(() {
        _spotifyLibraryTracks = cached.tracks
            .map((t) => SpotifyTrack.fromJson(t))
            .toList();
        _spotifyPlaylistUrl = cached.playlistUrl;
      });
    }
  }
  
  Future<void> _checkSpotifyConnection() async {
    final status = await _spotifyService.getConnectionStatus();
    if (mounted) {
      setState(() => _isSpotifyConnected = status.connected);
    }
  }

  Future<void> _loadAlignmentScore() async {
    try {
      setState(() {
        _isLoadingAlignment = true;
        _alignmentError = null;
      });
      
      final result = await _apiService.getDailyAlignment(
        datetime: _birthDataMap['datetime'] as String,
        latitude: _birthDataMap['latitude'] as double,
        longitude: _birthDataMap['longitude'] as double,
        timezone: _birthDataMap['timezone'] as String,
      );
      
      if (mounted) {
        setState(() {
          _alignmentScore = result.score;
          _dominantEnergy = result.dominantEnergy;
          _isLoadingAlignment = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _alignmentError = e.toString();
          _isLoadingAlignment = false;
        });
      }
    }
  }

  /// Load monthly zodiac playlist from user's Spotify library.
  /// Uses cache to avoid reloading every time user navigates.
  /// Only regenerates once per month.
  Future<void> _loadMonthlyZodiacPlaylist() async {
    if (_isLoadingMonthlyZodiac) return;
    
    // If we already have the playlist loaded in memory, skip
    if (_monthlyZodiacPlaylist != null) return;
    
    // Check for cached playlist from current month
    final cached = await storageService.loadMonthlyZodiacPlaylist();
    if (cached != null && mounted) {
      setState(() {
        _monthlyZodiacPlaylist = MonthlyZodiacPlaylist.fromJson(cached);
        _monthlyZodiacError = null;
      });
      return; // Use cached version
    }
    
    // Check if Spotify is connected first
    if (!_isSpotifyConnected) {
      setState(() {
        _monthlyZodiacError = 'Connect Spotify to see your monthly playlist';
      });
      return;
    }
    
    setState(() {
      _isLoadingMonthlyZodiac = true;
      _monthlyZodiacError = null;
    });
    
    try {
      final data = await _spotifyService.getMonthlyZodiacPlaylist();
      if (mounted) {
        setState(() {
          _monthlyZodiacPlaylist = MonthlyZodiacPlaylist.fromJson(data);
          _isLoadingMonthlyZodiac = false;
        });
        
        // Save to cache for the month
        await storageService.saveMonthlyZodiacPlaylist(data);
      }
    } catch (e) {
      if (mounted) {
        String error = 'Failed to load zodiac playlist';
        if (e is SpotifyException) {
          error = e.message;
        }
        setState(() {
          _monthlyZodiacError = error;
          _isLoadingMonthlyZodiac = false;
        });
      }
    }
  }

  /// Open the monthly zodiac playlist in Spotify.
  Future<void> _openMonthlyZodiacPlaylist() async {
    if (_monthlyZodiacPlaylist?.playlistUrl != null) {
      await _spotifyService.openPlaylist(_monthlyZodiacPlaylist!.playlistUrl!);
    }
  }

  @override
  void dispose() {
    _audioService.dispose();
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _loadSonificationData() async {
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

  Future<void> _generatePlaylist() async {
    if (_isGeneratingPlaylist) return;
    
    setState(() {
      _isGeneratingPlaylist = true;
      _playlistError = null;
      _datasetPlaylist = null;
      _spotifyPlaylistUrl = null; // Reset Spotify URL
    });
    
    // Generate playlist from 114K music dataset with genre preferences
    try {
      final result = await _apiService.generateFromDataset(
        datetime: _birthDataMap['datetime'] as String,
        latitude: _birthDataMap['latitude'] as double,
        longitude: _birthDataMap['longitude'] as double,
        timezone: _birthDataMap['timezone'] as String,
        playlistSize: 20,
        mainGenres: _userMainGenres,
        subgenres: _userSubgenres,
        includeRelated: true,
      );
      
      if (mounted) {
        setState(() {
          _datasetPlaylist = result;
          _isGeneratingPlaylist = false;
        });
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Generated ${result.trackCount} tracks based on your cosmic profile ✨'),
            backgroundColor: const Color(0xFF7D67FE),
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Auto-create Spotify playlist if connected
        if (_isSpotifyConnected) {
          await _createSpotifyFromDataset(result);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGeneratingPlaylist = false;
          _playlistError = e is ApiException ? e.message : 'Failed to generate playlist';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_playlistError ?? 'Failed to generate playlist'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }
  
  /// Generate zodiac-themed playlist name for Spotify
  String _getZodiacPlaylistName() {
    final zodiacSign = _getCurrentZodiacSign();
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final dateStr = '${months[now.month - 1]} ${now.day}, ${now.year}';
    return 'Astro.FM - $zodiacSign Season - $dateStr';
  }
  
  /// Create Spotify playlist from dataset tracks
  Future<void> _createSpotifyFromDataset(DatasetPlaylistResult playlist) async {
    if (_isCreatingSpotifyPlaylist) return;
    
    setState(() => _isCreatingSpotifyPlaylist = true);
    
    try {
      // Convert DatasetTracks to song list for Spotify search
      final songs = playlist.tracks.map((track) => {
        'title': track.trackName,
        'artist': track.artists.split(',').first.trim(), // Use primary artist
      }).toList();
      
      // Create playlist with zodiac-themed name
      final playlistName = _getZodiacPlaylistName();
      
      final result = await _spotifyService.createPlaylist(
        name: playlistName,
        songs: songs,
        description: 'Your cosmic vibe for today ✨🌟 Generated by Astro.FM',
      );
      
      if (mounted && result.success && result.playlistUrl != null) {
        setState(() {
          _spotifyPlaylistUrl = result.playlistUrl;
          _isCreatingSpotifyPlaylist = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Created Spotify playlist with ${result.tracksAdded} tracks 🎵'),
            backgroundColor: const Color(0xFF1DB954),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCreatingSpotifyPlaylist = false);
        // Show error but don't block - the dataset playlist is still available
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e is SpotifyException ? e.message : 'Could not create Spotify playlist'),
            backgroundColor: Colors.orange.shade700,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  
  Future<void> _createSpotifyPlaylist(PlaylistResult playlist) async {
    if (_isCreatingSpotifyPlaylist) return;
    
    setState(() => _isCreatingSpotifyPlaylist = true);
    
    try {
      // Extract cosmic parameters from playlist for filtering
      // Energy: use vibe match score (0-100 -> 0-1)
      final energyTarget = (playlist.vibeMatchScore / 100).clamp(0.0, 1.0);
      
      // Mood: map dominant mood to valence (0-1 scale)
      final dominantMood = playlist.moodDistribution.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      // Map moods to valence: higher = happier
      final moodToValence = {
        'energetic': 0.8,
        'happy': 0.9,
        'uplifting': 0.85,
        'calm': 0.5,
        'peaceful': 0.6,
        'melancholic': 0.2,
        'introspective': 0.4,
        'intense': 0.6,
        'mysterious': 0.35,
      };
      final moodTarget = moodToValence[dominantMood.toLowerCase()] ?? 0.5;
      
      // Get BPM range from playlist songs
      final bpms = playlist.songs.map((s) => s.bpm).toList();
      final tempoMin = bpms.isNotEmpty ? bpms.reduce((a, b) => a < b ? a : b) : 80;
      final tempoMax = bpms.isNotEmpty ? bpms.reduce((a, b) => a > b ? a : b) : 160;
      
      // Generate playlist from user's library using cosmic parameters
      final result = await _spotifyService.generateFromLibrary(
        name: 'Cosmic Queue - ${DateTime.now().toString().split(' ')[0]}',
        energyTarget: energyTarget,
        moodTarget: moodTarget,
        tempoMin: tempoMin,
        tempoMax: tempoMax,
        playlistSize: 20,
        description: 'Personalized from your library by Astro.FM 🌟✨',
      );
      
      if (mounted && result.success && result.playlistUrl != null) {
        setState(() {
          _spotifyPlaylistUrl = result.playlistUrl;
          _spotifyLibraryTracks = result.tracks;  // Store the tracks for display
          _isCreatingSpotifyPlaylist = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isCreatingSpotifyPlaylist = false);
        // Show error for library-based playlists
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e is SpotifyException ? e.message : 'Failed to create playlist'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }
  
  Future<void> _openSpotifyPlaylist() async {
    if (_spotifyPlaylistUrl != null) {
      await _spotifyService.openPlaylist(_spotifyPlaylistUrl!);
    }
  }

  Future<void> _loadPlaylistInsight(PlaylistResult playlist) async {
    setState(() => _isLoadingPlaylistInsight = true);
    
    try {
      // Extract dominant mood and element from playlist
      final dominantMood = playlist.moodDistribution.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      final dominantElement = playlist.elementDistribution.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      
      // Get BPM range from songs
      final bpms = playlist.songs.map((s) => s.bpm).toList();
      final bpmMin = bpms.isNotEmpty ? bpms.reduce((a, b) => a < b ? a : b) : 100;
      final bpmMax = bpms.isNotEmpty ? bpms.reduce((a, b) => a > b ? a : b) : 130;
      
      final insight = await _apiService.getPlaylistInsight(
        datetime: _birthDataMap['datetime'] as String,
        latitude: _birthDataMap['latitude'] as double,
        longitude: _birthDataMap['longitude'] as double,
        energyPercent: playlist.vibeMatchScore.round(),
        dominantMood: dominantMood,
        dominantElement: dominantElement,
        bpmMin: bpmMin,
        bpmMax: bpmMax,
      );
      
      if (mounted) {
        setState(() {
          _playlistInsight = insight;
          _isLoadingPlaylistInsight = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingPlaylistInsight = false);
      }
    }
  }

  void _sharePlaylistInsight() {
    if (_playlistInsight == null) return;
    
    final text = '''🎵 My Cosmic Playlist

${_playlistInsight!.insight}

✨ ${_playlistInsight!.astroHighlight}
⚡ Energy: ${_playlistInsight!.energyPercent}%
🎭 Mood: ${_playlistInsight!.dominantMood}

Generated by Astro.FM''';
    
    Share.share(text);
  }

  void _playUserSound() {
    if (_isPlayingUserSound) {
      _audioService.stop();
      setState(() => _isPlayingUserSound = false);
    } else if (_userSonification != null) {
      _audioService.stop();
      _audioService.playChartSound(_userSonification!);
      setState(() {
        _isPlayingUserSound = true;
        _isPlayingDailySound = false;
      });
    }
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
        _isPlayingUserSound = false;
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

            // Monthly Zodiac Playlist Card
            ZodiacPlaylistCard(
              playlist: _monthlyZodiacPlaylist,
              isLoading: _isLoadingMonthlyZodiac,
              errorMessage: _monthlyZodiacError,
              onRetry: _loadMonthlyZodiacPlaylist,
              onOpenSpotify: _openMonthlyZodiacPlaylist,
            ),
            const SizedBox(height: 20),

            // CTA Buttons
            _buildCtaButtons(),
            const SizedBox(height: 24),

            // Today's Resonance
            _buildTodaysResonance(),
            const SizedBox(height: 24),

            // Cosmic Queue
            _buildCosmicQueue(),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundOrbsSection() {
    return GlassCard(
      child: Column(
        children: [
          // Today's Sound Orb - centered
          GestureDetector(
            onTap: _dailySonification != null ? _playDailySound : null,
            child: Column(
              children: [
                if (_isLoadingSonification)
                  const SkeletonOrb(size: 120)
                else
                  SoundOrb(
                    size: 120,
                    colors: const [AppColors.electricYellow, AppColors.hotPink, AppColors.cosmicPurple],
                    animate: _isPlayingDailySound,
                  ),
                const SizedBox(height: 16),
                Text(
                  'TODAY\'S SOUND',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    color: Colors.white.withAlpha(128),
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isLoadingSonification 
                    ? 'Loading...'
                    : (_isPlayingDailySound ? 'Playing...' : 'Tap to Play'),
                  style: GoogleFonts.syne(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.electricYellow,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlignmentScoreWidget() {
    if (_isLoadingAlignment) {
      return const SizedBox(
        width: 40,
        height: 40,
        child: CircularProgressIndicator(
          strokeWidth: 3,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.electricYellow),
        ),
      );
    }
    
    if (_alignmentError != null || _alignmentScore == null) {
      return SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          children: [
            CircularProgressIndicator(
              value: 0,
              backgroundColor: Colors.white.withAlpha(26),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.grey),
              strokeWidth: 3,
            ),
            Center(
              child: Text(
                '—',
                style: GoogleFonts.syne(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: _alignmentScore! / 100,
            backgroundColor: Colors.white.withAlpha(26),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.electricYellow),
            strokeWidth: 3,
          ),
          Center(
            child: Text(
              '$_alignmentScore%',
              style: GoogleFonts.syne(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.electricYellow,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToFriendProfile(Map<String, dynamic> friend, int index) {
    final friendData = FriendData(
      id: index + 1,
      name: friend['name'] as String,
      username: '@${(friend['name'] as String).toLowerCase()}',
      avatarColors: [(friend['color1'] as Color).value, (friend['color2'] as Color).value],
      sunSign: 'Pisces',
      moonSign: 'Cancer',
      risingSign: 'Scorpio',
      dominantFrequency: '432 Hz',
      element: 'Water',
      modality: 'Mutable',
      compatibilityScore: 85,
      status: 'online',
    );
    Navigator.pushNamed(context, '/friend-profile', arguments: friendData);
  }

  Widget _buildFriendAvatars() {
    return Row(
      children: [
        ...alignedFriends.asMap().entries.map((entry) {
          final friend = entry.value;
          return Transform.translate(
            offset: Offset(-8.0 * entry.key, 0),
            child: GestureDetector(
              onTap: () => _navigateToFriendProfile(friend, entry.key),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [friend['color1'] as Color, friend['color2'] as Color],
                  ),
                  border: Border.all(color: AppColors.backgroundMid, width: 2),
                ),
                child: Center(
                  child: Text(
                    (friend['name'] as String)[0],
                    style: GoogleFonts.syne(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
        Transform.translate(
          offset: Offset(-8.0 * alignedFriends.length, 0),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withAlpha(26),
              border: Border.all(color: AppColors.backgroundMid, width: 2),
            ),
            child: Center(
              child: Text(
                '+5',
                style: GoogleFonts.syne(
                  fontSize: 10,
                  color: Colors.white.withAlpha(153),
                ),
              ),
            ),
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
            label: 'Generate Playlist',
            icon: Icons.music_note_rounded,
            gradient: const LinearGradient(
              colors: [AppColors.electricYellow, Color(0xFFE5EB0D)],
            ),
            textColor: AppColors.background,
            onPressed: _isGeneratingPlaylist ? null : () { _generatePlaylist(); },
          ),
        ),
      ],
    );
  }

  Widget _buildTodaysResonance() {
    // Show error state with retry
    if (_readingError != null) {
      return GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TODAY\'S RESONANCE',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 11,
                color: Colors.white.withAlpha(128),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 16),
            InlineError(
              message: _readingError!,
              onRetry: _loadDailyReading,
            ),
          ],
        ),
      );
    }
    
    // Show skeleton while loading
    if (_isLoadingReading && _dailyReading == null) {
      return GlassCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TODAY\'S RESONANCE',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        color: Colors.white.withAlpha(128),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SkeletonLoader(
                      width: 100,
                      height: 24,
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.white.withAlpha(25),
                    ),
                  ],
                ),
                SkeletonLoader(
                  width: 70,
                  height: 24,
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white.withAlpha(25),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SkeletonLoader(
                    width: double.infinity,
                    height: 50,
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white.withAlpha(15),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SkeletonLoader(
                    width: double.infinity,
                    height: 50,
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white.withAlpha(15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SkeletonText(lines: 2, lastLineWidth: 150),
          ],
        ),
      );
    }
    
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TODAY\'S RESONANCE',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      color: Colors.white.withAlpha(128),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [AppColors.electricYellow, AppColors.hotPink],
                    ).createShader(bounds),
                    child: Text(
                      todaysReading['sign'] as String,
                      style: GoogleFonts.syne(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.electricYellow.withAlpha(38),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.electricYellow.withAlpha(77)),
                ),
                child: Text(
                  todaysReading['energy'] as String,
                  style: GoogleFonts.syne(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.electricYellow,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(13),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'MOOD',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          color: Colors.white.withAlpha(102),
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        todaysReading['mood'] as String,
                        style: GoogleFonts.syne(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.hotPink,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(13),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'BPM',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          color: Colors.white.withAlpha(102),
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        todaysReading['bpm'] as String,
                        style: GoogleFonts.syne(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.cosmicPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            todaysReading['vibe'] as String,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              height: 1.6,
              color: Colors.white.withAlpha(179),
            ),
          ),
        ],
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
            if (_datasetPlaylist != null)
                  Text(
                    '${_datasetPlaylist!.trackCount} tracks • ${_datasetPlaylist!.formattedDuration}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      color: Colors.white.withAlpha(128),
                    ),
                  )
            else if (_generatedPlaylist != null)
                  Text(
                    '${_generatedPlaylist!.songCount} songs • ${_generatedPlaylist!.formattedDuration}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      color: Colors.white.withAlpha(128),
                    ),
                  ),
              ],
            ),
            // Open in Spotify button
            if (_spotifyPlaylistUrl != null)
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
            else if (_isCreatingSpotifyPlaylist)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(13),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1DB954)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Creating...',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        color: Colors.white.withAlpha(128),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        // Show skeleton cards while generating
        if (_isGeneratingPlaylist)
          GlassCard(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: List.generate(3, (index) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: SkeletonCard(height: 64),
              )),
            ),
          )
        // Show error with retry button
        else if (_playlistError != null)
          GlassCard(
            child: Column(
              children: [
                InlineError(
                  message: _playlistError!,
                  onRetry: () {
                    setState(() => _playlistError = null);
                    _generatePlaylist();
                  },
                ),
              ],
            ),
          )
        // Show empty state
        else if (_datasetPlaylist == null && _spotifyLibraryTracks.isEmpty && _generatedPlaylist == null)
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
              if (_isLoadingPlaylistInsight)
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
              else if (_playlistInsight != null)
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
                          _playlistInsight!.insight,
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
                            _buildStatPill('\u2728 ${_playlistInsight!.astroHighlight}', AppColors.cosmicPurple),
                            const SizedBox(width: 8),
                            _buildStatPill('\u26a1 ${_playlistInsight!.energyPercent}%', AppColors.electricYellow),
                            const SizedBox(width: 8),
                            _buildStatPill('\ud83c\udfad ${_playlistInsight!.dominantMood}', AppColors.hotPink),
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
                  children: _datasetPlaylist != null
                    ? _datasetPlaylist!.tracks.asMap().entries.map((entry) {
                        final index = entry.key;
                        final track = entry.value;
                        return _buildDatasetTrackItem(track, index);
                      }).toList()
                    : _spotifyLibraryTracks.isNotEmpty
                      ? _spotifyLibraryTracks.asMap().entries.map((entry) {
                          final index = entry.key;
                          final track = entry.value;
                          return _buildSpotifyTrackItem(track, index);
                        }).toList()
                      : _generatedPlaylist != null 
                        ? _generatedPlaylist!.songs.asMap().entries.map((entry) {
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
    final energyPercent = track.energy * 100;
    final moodLabel = track.valence > 0.6 ? 'Upbeat' : track.valence > 0.4 ? 'Neutral' : 'Mellow';
    
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
          // Duration and stats
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                track.formattedDuration,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  color: Colors.white.withAlpha(128),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bolt,
                    size: 10,
                    color: energyPercent > 60 ? AppColors.electricYellow : Colors.white.withAlpha(102),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${energyPercent.round()}%',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      color: Colors.white.withAlpha(102),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    moodLabel,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 10,
                      color: AppColors.hotPink.withAlpha(179),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build a Spotify track item for display in the Cosmic Queue
  Widget _buildSpotifyTrackItem(SpotifyTrack track, int index) {
    final energyPercent = (track.energy ?? 0.5) * 100;
    final moodLabel = (track.valence ?? 0.5) > 0.6 ? 'Upbeat' : (track.valence ?? 0.5) > 0.4 ? 'Neutral' : 'Mellow';
    
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
          // Energy & Mood pills
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.electricYellow.withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${energyPercent.round()}%',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.electricYellow,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.cosmicPurple.withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  moodLabel,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.cosmicPurple,
                  ),
                ),
              ),
            ],
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
