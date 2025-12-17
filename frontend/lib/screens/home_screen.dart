import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/design_tokens.dart';
import '../widgets/app_header.dart';
import '../widgets/glass_card.dart';
import '../widgets/sound_orb.dart';
import '../services/audio_service.dart';
import '../services/api_service.dart';
import '../models/sonification.dart';
import '../models/ai_responses.dart';
import '../models/playlist.dart';

/// Home screen with sound orbs, alignment score, and cosmic queue.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioService _audioService = AudioService();
  final ApiService _apiService = ApiService();
  
  bool _isPlayingUserSound = false;
  bool _isPlayingDailySound = false;
  ChartSonification? _userSonification;
  ChartSonification? _dailySonification;
  DailyReading? _dailyReading;
  bool _isLoadingReading = false;
  PlaylistResult? _generatedPlaylist;
  bool _isGeneratingPlaylist = false;

  // Mock birth data - in production, this would come from user profile
  final _birthData = {
    'datetime': '1990-07-15T15:42:00',
    'latitude': 34.0522,
    'longitude': -118.2437,
    'timezone': 'America/Los_Angeles',
  };

  // Fallback data when API is unavailable
  Map<String, String> get todaysReading => {
    'sign': 'Scorpio',
    'date': _formatCurrentDate(),
    'energy': _dailyReading?.energyLabel ?? 'Transformative',
    'mood': _dailyReading?.mood ?? 'Loading...',
    'bpm': _dailyReading?.playlistParams.bpmRange ?? '---',
    'vibe': _dailyReading?.reading ?? 'Connecting to the cosmos...',
  };
  
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

  final alignmentScore = 78;

  @override
  void initState() {
    super.initState();
    _loadSonificationData();
    _audioService.playingStream.listen((isPlaying) {
      if (mounted && !isPlaying) {
        setState(() {
          _isPlayingUserSound = false;
          _isPlayingDailySound = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _audioService.dispose();
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _loadSonificationData() async {
    try {
      // Load user's sound
      final userSonification = await _apiService.getUserSonification(
        datetime: _birthData['datetime'] as String,
        latitude: _birthData['latitude'] as double,
        longitude: _birthData['longitude'] as double,
        timezone: _birthData['timezone'] as String,
      );
      
      // Load daily sound
      final dailySonification = await _apiService.getDailySonification(
        latitude: _birthData['latitude'] as double,
        longitude: _birthData['longitude'] as double,
      );
      
      if (mounted) {
        setState(() {
          _userSonification = userSonification;
          _dailySonification = dailySonification;
        });
      }
    } catch (e) {
      // Silently fail - orbs will just be decorative if API fails
    }
    
    // Load AI-generated daily reading
    _loadDailyReading();
  }
  
  Future<void> _loadDailyReading() async {
    if (_isLoadingReading) return;
    
    setState(() => _isLoadingReading = true);
    
    try {
      final reading = await _apiService.getDailyReading(
        datetime: _birthData['datetime'] as String,
        latitude: _birthData['latitude'] as double,
        longitude: _birthData['longitude'] as double,
        timezone: _birthData['timezone'] as String,
      );
      
      if (mounted) {
        setState(() {
          _dailyReading = reading;
          _isLoadingReading = false;
        });
      }
    } catch (e) {
      // Log error for debugging
      print('Error loading daily reading: $e');
      // Keep fallback data on error
      if (mounted) {
        setState(() => _isLoadingReading = false);
      }
    }
  }

  Future<void> _generatePlaylist() async {
    if (_isGeneratingPlaylist) return;
    
    setState(() => _isGeneratingPlaylist = true);
    
    try {
      final playlist = await _apiService.generatePlaylist(
        datetime: _birthData['datetime'] as String,
        latitude: _birthData['latitude'] as double,
        longitude: _birthData['longitude'] as double,
        timezone: _birthData['timezone'] as String,
        playlistSize: 20,
      );
      
      if (mounted) {
        setState(() {
          _generatedPlaylist = playlist;
          _isGeneratingPlaylist = false;
        });
      }
    } catch (e) {
      print('Error generating playlist: $e');
      if (mounted) {
        setState(() => _isGeneratingPlaylist = false);
        // Show error snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate playlist: ${e.toString()}'),
            backgroundColor: Colors.red.shade900,
          ),
        );
      }
    }
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
            const AppHeader(),
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
          // Orbs row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Your Sound Orb
              GestureDetector(
                onTap: _playUserSound,
                child: Column(
                  children: [
                    SoundOrb(
                      size: 100,
                      colors: const [AppColors.hotPink, AppColors.cosmicPurple, AppColors.teal],
                      animate: _isPlayingUserSound,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'YOUR SOUND',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        color: Colors.white.withAlpha(128),
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      _isPlayingUserSound ? 'Playing...' : 'Tap to Play',
                      style: GoogleFonts.syne(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.hotPink,
                      ),
                    ),
                  ],
                ),
              ),

              // Connection indicator
              Column(
                children: [
                  Container(
                    width: 60,
                    height: 2,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.hotPink, AppColors.electricYellow],
                      ),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: 26,
                          top: -3,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.electricYellow,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.electricYellow.withAlpha(179),
                                  blurRadius: 10,
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

              // Today's Sound Orb
              GestureDetector(
                onTap: _playDailySound,
                child: Column(
                  children: [
                    SoundOrb(
                      size: 100,
                      colors: const [AppColors.electricYellow, AppColors.hotPink, AppColors.cosmicPurple],
                      animate: _isPlayingDailySound,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'TODAY\'S SOUND',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        color: Colors.white.withAlpha(128),
                        letterSpacing: 2,
                      ),
                    ),
                    Text(
                      _isPlayingDailySound ? 'Playing...' : 'Tap to Play',
                      style: GoogleFonts.syne(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.electricYellow,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Alignment Score Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(13),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(color: Colors.white.withAlpha(26)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCircularProgress(alignmentScore),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aligned Today',
                      style: GoogleFonts.syne(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'High resonance day',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        color: Colors.white.withAlpha(128),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Friends aligned
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Friends aligned today:',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 12,
                  color: Colors.white.withAlpha(128),
                ),
              ),
              const SizedBox(width: 8),
              _buildFriendAvatars(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCircularProgress(int score) {
    return SizedBox(
      width: 40,
      height: 40,
      child: Stack(
        children: [
          CircularProgressIndicator(
            value: score / 100,
            backgroundColor: Colors.white.withAlpha(26),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.electricYellow),
            strokeWidth: 3,
          ),
          Center(
            child: Text(
              '$score%',
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

  Widget _buildFriendAvatars() {
    return Row(
      children: [
        ...alignedFriends.asMap().entries.map((entry) {
          final friend = entry.value;
          return Transform.translate(
            offset: Offset(-8.0 * entry.key, 0),
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
            onPressed: () {},
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
            if (_generatedPlaylist != null)
                  Text(
                    '${_generatedPlaylist!.songCount} songs • ${_generatedPlaylist!.formattedDuration}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      color: Colors.white.withAlpha(128),
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isGeneratingPlaylist)
          GlassCard(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.electricYellow),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Generating your cosmic playlist...',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        color: Colors.white.withAlpha(179),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else if (_generatedPlaylist == null)
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
        else
          GlassCard(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: _generatedPlaylist!.songs.asMap().entries.map((entry) {
                final index = entry.key;
                final song = entry.value;
                return _buildPlaylistItem(song, index);
              }).toList(),
            ),
          ),
      ],
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
