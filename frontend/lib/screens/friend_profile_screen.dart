import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math' as math;
import '../config/design_tokens.dart';
import 'main_shell.dart';
import '../widgets/bottom_nav_bar.dart';
import '../models/friend_data.dart';
import '../models/ai_responses.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../data/test_users.dart';

/// Redesigned Friend Profile Page
/// Focuses on cosmic/sonic connection rather than clinical percentages
class FriendProfileScreen extends StatefulWidget {
  final FriendData friend;

  const FriendProfileScreen({super.key, required this.friend});

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen>
    with TickerProviderStateMixin {
  // Animation Controllers
  late AnimationController _floatController;
  late AnimationController _waveformController;
  late AnimationController _pulseController;
  late ScrollController _scrollController;

  bool _showMenu = false;
  bool _isPlayingSound = false;
  double _headerOpacity = 1.0;

  // AI Compatibility State
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  CompatibilityResult? _aiCompatibility;
  bool _isLoadingCompatibility = true;
  String? _compatibilityError;

  // Current user mood (would come from user profile in real app)
  final String _currentUserMood = 'Reflective';

  @override
  void initState() {
    super.initState();
    
    // Float animation for avatar (4s cycle)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    // Waveform animation (0.8s cycle)
    _waveformController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);

    // Pulse animation for rings and blobs (2s cycle)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Scroll controller for header fade
    _scrollController = ScrollController()
      ..addListener(() {
        setState(() {
          _headerOpacity = 1.0 - (_scrollController.offset / 200).clamp(0.0, 0.6);
        });
      });

    _loadCompatibilityData();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _waveformController.dispose();
    _pulseController.dispose();
    _scrollController.dispose();
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _loadCompatibilityData() async {
    setState(() {
      _isLoadingCompatibility = true;
      _compatibilityError = null;
    });

    try {
      final userBirthData = await _storageService.loadBirthData();

      final String userDatetime;
      final double userLatitude;
      final double userLongitude;

      if (userBirthData != null) {
        userDatetime = userBirthData.datetime;
        userLatitude = userBirthData.latitude;
        userLongitude = userBirthData.longitude;
      } else {
        userDatetime = defaultTestBirthData['datetime'] as String;
        userLatitude = defaultTestBirthData['latitude'] as double;
        userLongitude = defaultTestBirthData['longitude'] as double;
      }

      final String friendDatetime;
      final double friendLatitude;
      final double friendLongitude;

      if (widget.friend.hasBirthData) {
        friendDatetime = widget.friend.birthDatetime!;
        friendLatitude = widget.friend.birthLatitude!;
        friendLongitude = widget.friend.birthLongitude!;
      } else {
        final mockData = _getMockBirthDataForSign(widget.friend.sunSign);
        friendDatetime = mockData['datetime'] as String;
        friendLatitude = mockData['latitude'] as double;
        friendLongitude = mockData['longitude'] as double;
      }

      final friendFirstName = widget.friend.name.split(' ')[0];
      final result = await _apiService.getCompatibility(
        userDatetime: userDatetime,
        userLatitude: userLatitude,
        userLongitude: userLongitude,
        friendDatetime: friendDatetime,
        friendLatitude: friendLatitude,
        friendLongitude: friendLongitude,
        friendName: friendFirstName,
      );

      if (mounted) {
        setState(() {
          _aiCompatibility = result;
          _isLoadingCompatibility = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _compatibilityError = 'Unable to load AI analysis. Tap to retry.';
          _isLoadingCompatibility = false;
        });
      }
    }
  }

  Map<String, dynamic> _getMockBirthDataForSign(String sign) {
    final signDates = {
      'Aries': '1990-04-05T12:00:00',
      'Taurus': '1990-05-05T12:00:00',
      'Gemini': '1990-06-05T12:00:00',
      'Cancer': '1990-07-05T12:00:00',
      'Leo': '1990-08-05T12:00:00',
      'Virgo': '1990-09-05T12:00:00',
      'Libra': '1990-10-05T12:00:00',
      'Scorpio': '1990-11-05T12:00:00',
      'Sagittarius': '1990-12-05T12:00:00',
      'Capricorn': '1990-01-05T12:00:00',
      'Aquarius': '1990-02-05T12:00:00',
      'Pisces': '1990-03-05T12:00:00',
    };

    return {
      'datetime': signDates[sign] ?? '1990-07-15T12:00:00',
      'latitude': 40.7128,
      'longitude': -74.0060,
    };
  }

  Color _getAvatarColor(int index) {
    if (index < widget.friend.avatarColors.length) {
      return Color(widget.friend.avatarColors[index]);
    }
    return index == 0 ? AppColors.hotPink : AppColors.cosmicPurple;
  }

  // Connection data - computed from AI result or mocked
  int get _sharedFrequency => 176; // Would be computed from charts
  String get _connectionType => 'Emotional Depth';
  String get _connectionDescription => _aiCompatibility?.narrative ?? 
      "Both of your charts are activated by today's cosmic transits. Expect heightened intuition and unspoken understanding.";
  String get _aspectSymbol => '△';
  Color get _aspectColor => AppColors.teal;
  String get _aiInsight => _aiCompatibility?.narrative ?? 
      "Your Aries Sun's raw 126.22 Hz carrier wave meets ${widget.friend.name.split(' ')[0]}'s ${widget.friend.sunSign} Sun's expansive, dreamy frequencies. Together you create a unique harmonic that balances action with intuition.";
  List<String> get _strengths => _aiCompatibility?.strengths ?? ['Complementary energies', 'Shared curiosity', 'Emotional safety'];
  List<String> get _challenges => _aiCompatibility?.challenges ?? ['Different communication rhythms', 'Pacing differences'];
  List<String> get _sharedGenres => _aiCompatibility?.sharedGenres ?? ['Electronic', 'Ambient', 'Indie'];

  List<Map<String, dynamic>> get _friendPlaylists => [
    {'id': 1, 'name': 'Lunar Waves', 'trackCount': 24},
    {'id': 2, 'name': 'Deep Focus Flow', 'trackCount': 18},
    {'id': 3, 'name': 'Midnight Frequencies', 'trackCount': 31},
  ];

  void _alignWithFriend() {
    Navigator.pushNamed(
      context,
      '/align',
      arguments: {
        'targetType': 'friend',
        'friendId': widget.friend.id,
        'friendName': widget.friend.name,
      },
    );
  }

  Future<void> _sharePlaylist() async {
    await Share.share(
      '🌟 Check out my cosmic playlist! 🎶\n\n'
      'Created based on my alignment with ${widget.friend.name.split(' ')[0]}\n\n'
      'Discover your cosmic connection at ASTRO.FM!',
    );
  }

  void _shareCosmicConnection() {
    final firstName = widget.friend.name.split(' ')[0];
    
    final text = '''✨ COSMIC CONNECTION

🌌 Me + $firstName
⚡ Shared Frequency: $_sharedFrequency Hz
💫 Connection Type: $_connectionType

$_connectionDescription

🎯 Strengths: ${_strengths.join(' • ')}

🎵 Shared Genres: ${_sharedGenres.join(' • ')}

— Discover your cosmic connections at Astro.FM''';
    
    Share.share(text);
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature coming soon!'),
        backgroundColor: AppColors.cosmicPurple,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: Stack(
        children: [
          // Background gradient blobs
          _buildBackground(),

          // Main content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App Bar
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                pinned: true,
                expandedHeight: 0,
                leading: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(13),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
                title: Text(
                  'Friend Profile',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: Colors.white.withAlpha(128),
                  ),
                ),
                centerTitle: true,
                actions: [
                  GestureDetector(
                    onTap: () => setState(() => _showMenu = true),
                    child: Container(
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(13),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.more_vert_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ],
              ),

              // Profile Header
              SliverToBoxAdapter(
                child: Opacity(
                  opacity: _headerOpacity,
                  child: _buildProfileHeader(),
                ),
              ),

              // Cosmic Connection Section (Hero)
              SliverToBoxAdapter(child: _buildCosmicConnection()),

              // Their Sound Section
              SliverToBoxAdapter(child: _buildTheirSound()),

              // AI Insight
              SliverToBoxAdapter(child: _buildAIInsight()),

              // Synastry Highlights
              SliverToBoxAdapter(child: _buildSynastryHighlights()),

              // Shared Vibes
              SliverToBoxAdapter(child: _buildSharedVibes()),

              // Their Playlists
              SliverToBoxAdapter(child: _buildTheirPlaylists()),

              // Action Buttons
              SliverToBoxAdapter(child: _buildActionButtons()),

              // Bottom padding for nav bar
              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),

          // Bottom navigation
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: BottomNavBar(
              activeTab: 'friends',
              onTabChanged: (tab) {
                // Pop back to MainShell first
                Navigator.of(context).popUntil((route) => route.isFirst);
                // Then switch to the selected tab if not already on friends
                if (tab != 'friends') {
                  // Use a post-frame callback to ensure we're back at MainShell
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    MainShellController.of(context)?.switchTab(tab);
                  });
                }
              },
            ),
          ),

          // Menu overlay
          if (_showMenu) _buildMenuOverlay(),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        // Top gradient blob
        Positioned(
          top: -100,
          left: -50,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _getAvatarColor(0).withAlpha((40 + 13 * _pulseController.value).toInt()),
                      _getAvatarColor(1).withAlpha(20),
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        // Bottom accent
        Positioned(
          bottom: 200,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  _getAvatarColor(1).withAlpha(26),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        children: [
          // Avatar with rings - wrapped in fixed size container to prevent layout shifts
          SizedBox(
            width: 160,
            height: 160,
            child: AnimatedBuilder(
              animation: _floatController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, -8 * _floatController.value),
                  child: child,
                );
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ring (pulsing with scale, not size change)
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + 0.07 * _pulseController.value,
                        child: Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _getAvatarColor(0).withAlpha(51),
                              width: 1,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  // Middle ring
                  Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _getAvatarColor(1).withAlpha(38),
                        width: 1,
                      ),
                    ),
                  ),
                  // Avatar orb
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [_getAvatarColor(0), _getAvatarColor(1)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _getAvatarColor(0).withAlpha(102),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        widget.friend.initials,
                        style: GoogleFonts.syne(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  // Online indicator
                  if (widget.friend.status == 'online')
                    Positioned(
                      bottom: 15,
                      right: 15,
                      child: Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.teal,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF0A0A0F),
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.teal.withAlpha(128),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Name
          Text(
            widget.friend.name,
            style: GoogleFonts.syne(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 4),

          // Username
          Text(
            widget.friend.username,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              color: Colors.white.withAlpha(102),
            ),
          ),

          const SizedBox(height: 16),

          // Sign Pills (horizontal row)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSignPill('☉', widget.friend.sunSign, AppColors.electricYellow),
              const SizedBox(width: 8),
              _buildSignPill('☽', widget.friend.moonSign, const Color(0xFFC0C0C0)),
              const SizedBox(width: 8),
              _buildSignPill('↑', widget.friend.risingSign, AppColors.hotPink),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSignPill(String symbol, String sign, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withAlpha(77),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            symbol,
            style: TextStyle(fontSize: 12, color: color),
          ),
          const SizedBox(width: 6),
          Text(
            sign,
            style: GoogleFonts.syne(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCosmicConnection() {
    final firstName = widget.friend.name.split(' ')[0];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withAlpha(13),
            Colors.white.withAlpha(5),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withAlpha(20),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Section Label with Share
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'YOUR COSMIC CONNECTION',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withAlpha(102),
                  letterSpacing: 2,
                ),
              ),
              GestureDetector(
                onTap: () => _shareCosmicConnection(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(13),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.share_outlined,
                    size: 14,
                    color: Colors.white.withAlpha(153),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Dual Orbs Alignment Visual
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Your Orb
              Column(
                children: [
                  // Fixed size container to prevent layout shifts
                  SizedBox(
                    width: 88,
                    height: 80,
                    child: AnimatedBuilder(
                      animation: _floatController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(4 * _floatController.value, 0),
                          child: child,
                        );
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.hotPink, AppColors.cosmicPurple],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.hotPink.withAlpha(77),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Center(child: _buildMiniWaveform(Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'You',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      color: Colors.white.withAlpha(179),
                    ),
                  ),
                  Text(
                    _currentUserMood,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      color: Colors.white.withAlpha(102),
                    ),
                  ),
                ],
              ),

              // Connection Line with Frequency
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: SizedBox(
                  width: 80,
                  child: Column(
                    children: [
                      // Frequency Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.electricYellow.withAlpha(38),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.electricYellow.withAlpha(77),
                          ),
                        ),
                        child: Text(
                          '$_sharedFrequency Hz',
                          style: GoogleFonts.syne(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.electricYellow,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Animated connection line
                      AnimatedBuilder(
                        animation: _pulseController,
                        builder: (context, child) {
                          return Container(
                            height: 3,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.hotPink,
                                  Color.lerp(
                                    AppColors.electricYellow,
                                    _getAvatarColor(0),
                                    _pulseController.value,
                                  )!,
                                  _getAvatarColor(0),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(2),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.electricYellow.withAlpha(
                                    (77 + 51 * _pulseController.value).toInt(),
                                  ),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Their Orb
              Column(
                children: [
                  // Fixed size container to prevent layout shifts
                  SizedBox(
                    width: 88,
                    height: 80,
                    child: AnimatedBuilder(
                      animation: _floatController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(-4 * _floatController.value, 0),
                          child: child,
                        );
                      },
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [_getAvatarColor(0), _getAvatarColor(1)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _getAvatarColor(0).withAlpha(77),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Center(child: _buildMiniWaveform(Colors.white)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    firstName,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      color: Colors.white.withAlpha(179),
                    ),
                  ),
                  Text(
                    widget.friend.currentMood ?? 'Dreamy',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 11,
                      color: Colors.white.withAlpha(102),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Connection Description
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(51),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Aspect badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _aspectColor.withAlpha(38),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _aspectSymbol,
                        style: TextStyle(fontSize: 14, color: _aspectColor),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _connectionType,
                        style: GoogleFonts.syne(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _aspectColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _connectionDescription,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    color: Colors.white.withAlpha(179),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniWaveform(Color color) {
    return AnimatedBuilder(
      animation: _waveformController,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(5, (index) {
            final heights = [0.4, 0.8, 0.5, 0.9, 0.6];
            final delay = index * 0.15;
            final value = math.sin((_waveformController.value + delay) * math.pi);
            return Container(
              width: 3,
              height: 20 * heights[index] * (0.6 + 0.4 * value),
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              decoration: BoxDecoration(
                color: color.withAlpha(204),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildTheirSound() {
    final firstName = widget.friend.name.split(' ')[0];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                "${firstName.toUpperCase()}'S SOUND",
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withAlpha(102),
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              // Element badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getElementColor(widget.friend.element).withAlpha(38),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getElementEmoji(widget.friend.element),
                      style: const TextStyle(fontSize: 10),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.friend.element,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 11,
                        color: _getElementColor(widget.friend.element),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              // Sound Orb
              GestureDetector(
                onTap: () => setState(() => _isPlayingSound = !_isPlayingSound),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        _getAvatarColor(0).withAlpha(102),
                        _getAvatarColor(1).withAlpha(51),
                      ],
                    ),
                    border: Border.all(
                      color: _getAvatarColor(0).withAlpha(128),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: _isPlayingSound
                        ? _buildMiniWaveform(_getAvatarColor(0))
                        : Icon(
                            Icons.play_arrow_rounded,
                            color: _getAvatarColor(0),
                            size: 28,
                          ),
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Sound Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [_getAvatarColor(0), _getAvatarColor(1)],
                          ).createShader(bounds),
                          child: Text(
                            widget.friend.dominantFrequency,
                            style: GoogleFonts.syne(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(26),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            widget.friend.modality,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              color: Colors.white.withAlpha(153),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Flowing, intuitive waves with deep emotional resonance',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: Colors.white.withAlpha(128),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Listen Button
          GestureDetector(
            onTap: () => setState(() => _isPlayingSound = !_isPlayingSound),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _getAvatarColor(0).withAlpha(38),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _getAvatarColor(0).withAlpha(77),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isPlayingSound ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: _getAvatarColor(0),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isPlayingSound
                        ? "Playing $firstName's Sound"
                        : "Listen to $firstName's Sound",
                    style: GoogleFonts.syne(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _getAvatarColor(0),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIInsight() {
    if (_isLoadingCompatibility) {
      return _buildLoadingInsight();
    }

    if (_compatibilityError != null) {
      return _buildErrorInsight();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.electricYellow.withAlpha(38),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '✦',
                  style: TextStyle(fontSize: 14, color: AppColors.electricYellow),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'INSIGHT',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withAlpha(102),
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.cosmicPurple.withAlpha(38),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('✦', style: TextStyle(fontSize: 8, color: AppColors.cosmicPurple)),
                    const SizedBox(width: 4),
                    Text(
                      'AI',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 10,
                        color: Colors.white.withAlpha(128),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            _aiInsight,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 15,
              color: Colors.white.withAlpha(217),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingInsight() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withAlpha(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildShimmerLine(width: 120),
          const SizedBox(height: 12),
          _buildShimmerLine(width: double.infinity),
          const SizedBox(height: 8),
          _buildShimmerLine(width: double.infinity),
          const SizedBox(height: 8),
          _buildShimmerLine(width: 200),
        ],
      ),
    );
  }

  Widget _buildShimmerLine({required double width}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 0.6),
      duration: const Duration(milliseconds: 1000),
      builder: (context, value, child) {
        return Container(
          height: 12,
          width: width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withAlpha((value * 40).toInt()),
                Colors.white.withAlpha((value * 60).toInt()),
                Colors.white.withAlpha((value * 40).toInt()),
              ],
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        );
      },
      onEnd: () => setState(() {}),
    );
  }

  Widget _buildErrorInsight() {
    return GestureDetector(
      onTap: _loadCompatibilityData,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.red.withAlpha(20),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.red.withAlpha(51)),
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.red, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _compatibilityError!,
                style: GoogleFonts.spaceGrotesk(fontSize: 13, color: AppColors.red),
              ),
            ),
            const Icon(Icons.refresh, color: AppColors.red, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSynastryHighlights() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SYNASTRY HIGHLIGHTS',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white.withAlpha(102),
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              // Strengths
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.teal.withAlpha(51)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.teal,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'STRENGTHS',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withAlpha(102),
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._strengths.map((s) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          s,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: AppColors.teal,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Challenges
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.red.withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.red.withAlpha(51)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'GROWTH EDGES',
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withAlpha(102),
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ..._challenges.map((c) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text(
                          c,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 12,
                            color: AppColors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSharedVibes() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SHARED MUSIC VIBES',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.white.withAlpha(102),
              letterSpacing: 2,
            ),
          ),

          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _sharedGenres.map((genre) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: _getAvatarColor(0).withAlpha(26),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _getAvatarColor(0).withAlpha(64)),
                ),
                child: Text(
                  genre,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _getAvatarColor(0),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTheirPlaylists() {
    final firstName = widget.friend.name.split(' ')[0];
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${firstName.toUpperCase()}'S PLAYLISTS",
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withAlpha(102),
                  letterSpacing: 2,
                ),
              ),
              GestureDetector(
                onTap: () => _showComingSoon('All playlists'),
                child: Text(
                  'See All',
                  style: GoogleFonts.syne(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getAvatarColor(0),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Container(
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withAlpha(20)),
            ),
            child: Column(
              children: _friendPlaylists.asMap().entries.map((entry) {
                final index = entry.key;
                final playlist = entry.value;
                final isLast = index == _friendPlaylists.length - 1;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _getAvatarColor(0).withAlpha(77),
                                  _getAvatarColor(1).withAlpha(51),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.music_note_rounded,
                              color: _getAvatarColor(0),
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  playlist['name'] as String,
                                  style: GoogleFonts.syne(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${playlist['trackCount']} tracks',
                                  style: GoogleFonts.spaceGrotesk(
                                    fontSize: 12,
                                    color: Colors.white.withAlpha(102),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white.withAlpha(77),
                          ),
                        ],
                      ),
                    ),
                    if (!isLast)
                      Divider(
                        height: 1,
                        color: Colors.white.withAlpha(15),
                        indent: 76,
                      ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final firstName = widget.friend.name.split(' ')[0];
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          // Align Button
          GestureDetector(
            onTap: _alignWithFriend,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [AppColors.cosmicPurple, _getAvatarColor(0)],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.cosmicPurple.withAlpha(77),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.access_time_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    'Align with $firstName',
                    style: GoogleFonts.syne(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Share Playlist Button
          GestureDetector(
            onTap: _sharePlaylist,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [AppColors.electricYellow, AppColors.hotPink],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.electricYellow.withAlpha(64),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.music_note_rounded, color: Color(0xFF0A0A0F), size: 20),
                  const SizedBox(width: 10),
                  Text(
                    "Share Your Day's Playlist",
                    style: GoogleFonts.syne(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0A0A0F),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getElementColor(String element) {
    switch (element) {
      case 'Fire':
        return AppColors.red;
      case 'Earth':
        return AppColors.teal;
      case 'Air':
        return const Color(0xFF7DD3FC);
      case 'Water':
        return const Color(0xFF00B4D8);
      default:
        return Colors.white;
    }
  }

  String _getElementEmoji(String element) {
    switch (element) {
      case 'Fire':
        return '🔥';
      case 'Earth':
        return '🌍';
      case 'Air':
        return '💨';
      case 'Water':
        return '💧';
      default:
        return '✦';
    }
  }

  Widget _buildMenuOverlay() {
    return GestureDetector(
      onTap: () => setState(() => _showMenu = false),
      child: Container(
        color: Colors.black.withAlpha(128),
        child: Align(
          alignment: Alignment.topRight,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Material(
                color: AppColors.backgroundMid,
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildMenuItem('Share Profile', false, () {
                        setState(() => _showMenu = false);
                        _showComingSoon('Share profile');
                      }),
                      _buildMenuItem('Block', true, () {
                        setState(() => _showMenu = false);
                        _showBlockDialog();
                      }),
                      _buildMenuItem('Report', true, () {
                        setState(() => _showMenu = false);
                        _showReportDialog();
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(String label, bool isDestructive, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: SizedBox(
            width: 140,
            child: Text(
              label,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: isDestructive ? AppColors.red : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundMid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withAlpha(26)),
        ),
        title: Text(
          'Block User?',
          style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        content: Text(
          'Blocking ${widget.friend.name.split(' ')[0]} will prevent them from seeing your profile or contacting you.',
          style: GoogleFonts.spaceGrotesk(fontSize: 14, color: Colors.white.withAlpha(179)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.syne(fontSize: 14, color: Colors.white.withAlpha(128))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon('Block functionality');
            },
            child: Text('Block', style: GoogleFonts.syne(fontSize: 14, color: AppColors.red)),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundMid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withAlpha(26)),
        ),
        title: Text(
          'Report User?',
          style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        content: Text(
          'Report ${widget.friend.name.split(' ')[0]} for inappropriate behavior?',
          style: GoogleFonts.spaceGrotesk(fontSize: 14, color: Colors.white.withAlpha(179)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.syne(fontSize: 14, color: Colors.white.withAlpha(128))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon('Report functionality');
            },
            child: Text('Report', style: GoogleFonts.syne(fontSize: 14, color: AppColors.red)),
          ),
        ],
      ),
    );
  }
}
