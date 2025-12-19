import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import '../config/design_tokens.dart';
import '../widgets/glass_card.dart';
import '../widgets/sound_orb.dart';
import '../widgets/bottom_nav_bar.dart';
import '../models/friend_data.dart';
import '../models/ai_responses.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../data/test_users.dart';

/// Friend Profile detail screen.
class FriendProfileScreen extends StatefulWidget {
  final FriendData friend;

  const FriendProfileScreen({super.key, required this.friend});

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> {
  bool _showMenu = false;
  bool _isPlayingSound = false;
  
  // AI Compatibility State
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  CompatibilityResult? _aiCompatibility;
  bool _isLoadingCompatibility = true;
  String? _compatibilityError;

  @override
  void initState() {
    super.initState();
    _loadCompatibilityData();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _loadCompatibilityData() async {
    setState(() {
      _isLoadingCompatibility = true;
      _compatibilityError = null;
    });

    try {
      // Load user's birth data
      final userBirthData = await _storageService.loadBirthData();

      // Get user birth data (from storage or test default)
      final String userDatetime;
      final double userLatitude;
      final double userLongitude;
      
      if (userBirthData != null) {
        userDatetime = userBirthData.datetime;
        userLatitude = userBirthData.latitude;
        userLongitude = userBirthData.longitude;
      } else {
        // Use test default
        userDatetime = defaultTestBirthData['datetime'] as String;
        userLatitude = defaultTestBirthData['latitude'] as double;
        userLongitude = defaultTestBirthData['longitude'] as double;
      }

      // Get friend birth data (from friend object or generate mock from sign)
      final String friendDatetime;
      final double friendLatitude;
      final double friendLongitude;
      
      if (widget.friend.hasBirthData) {
        friendDatetime = widget.friend.birthDatetime!;
        friendLatitude = widget.friend.birthLatitude!;
        friendLongitude = widget.friend.birthLongitude!;
      } else {
        // Generate mock birth data based on their sun sign
        final mockData = _getMockBirthDataForSign(widget.friend.sunSign);
        friendDatetime = mockData['datetime'] as String;
        friendLatitude = mockData['latitude'] as double;
        friendLongitude = mockData['longitude'] as double;
      }

      // Call AI compatibility API
      final result = await _apiService.getCompatibility(
        userDatetime: userDatetime,
        userLatitude: userLatitude,
        userLongitude: userLongitude,
        friendDatetime: friendDatetime,
        friendLatitude: friendLatitude,
        friendLongitude: friendLongitude,
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

  /// Generate mock birth data for a zodiac sign (approximate date in that sign's period)
  Map<String, dynamic> _getMockBirthDataForSign(String sign) {
    // Map signs to approximate birth dates (middle of the sign)
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
      'latitude': 40.7128, // NYC default
      'longitude': -74.0060,
    };
  }

  // Compatibility data - uses AI result if available, otherwise mock
  Map<String, dynamic> get compatibility {
    final score = _aiCompatibility?.overallScore ?? widget.friend.compatibilityScore;
    
    return {
      'score': score,
      'breakdown': [
        {'symbol': '☽', 'label': 'Moon Harmony', 'value': _calculateBreakdownValue(score, 5), 'color': AppColors.hotPink},
        {'symbol': '☿', 'label': 'Communication', 'value': _calculateBreakdownValue(score, -10), 'color': AppColors.electricYellow},
        {'symbol': '♀', 'label': 'Love Language', 'value': _calculateBreakdownValue(score, 3), 'color': AppColors.cosmicPurple},
        {'symbol': '♂', 'label': 'Energy Sync', 'value': _calculateBreakdownValue(score, -3), 'color': AppColors.teal},
      ],
    };
  }

  /// Calculate breakdown values with some variance around the main score
  int _calculateBreakdownValue(int baseScore, int offset) {
    return (baseScore + offset).clamp(0, 100);
  }

  /// Get the AI-generated narrative or fallback text
  String get _insightText {
    if (_aiCompatibility != null) {
      return _aiCompatibility!.narrative;
    }
    // Fallback text
    return 'Your water signs create deep emotional understanding. ${widget.friend.name.split(' ')[0]}\'s ${widget.friend.sunSign} sun flows naturally with your energy, fostering intuitive connection.';
  }

  /// Get strengths from AI or fallback
  List<String> get _strengths {
    return _aiCompatibility?.strengths ?? ['Emotional connection', 'Shared intuition'];
  }

  /// Get challenges from AI or fallback
  List<String> get _challenges {
    return _aiCompatibility?.challenges ?? ['Different communication styles'];
  }

  /// Get shared genres from AI or fallback
  List<String> get _sharedGenres {
    return _aiCompatibility?.sharedGenres ?? ['Electronic', 'Ambient', 'Indie'];
  }

  Map<String, String> get todaysAlignment => {
    'sharedEnergy': 'Emotional Depth',
    'description': 'Both of your charts are activated by today\'s cosmic transits. Expect heightened intuition and unspoken understanding.',
    'yourMood': 'Reflective',
    'theirMood': 'Dreamy',
  };

  Map<String, String> get friendHoroscope => {
    'sign': widget.friend.sunSign,
    'mood': 'Introspective',
    'energy': 'Flowing → Mystical',
    'reading': 'The cosmos invites diving deep into the subconscious. Creative downloads are available if you slow down enough to receive them.',
  };

  List<Map<String, dynamic>> get friendPlaylists => [
    {'id': 1, 'name': 'Lunar Waves', 'trackCount': 24},
    {'id': 2, 'name': 'Deep Focus Flow', 'trackCount': 18},
    {'id': 3, 'name': 'Midnight Frequencies', 'trackCount': 31},
  ];

  Color _getAvatarColor(int index) {
    if (index < widget.friend.avatarColors.length) {
      return Color(widget.friend.avatarColors[index]);
    }
    return index == 0 ? AppColors.hotPink : AppColors.cosmicPurple;
  }

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
      'Created based on my alignment with ${widget.friend.name.split(' ')[0]}\n'
      'Compatibility: ${widget.friend.compatibilityScore}%\n\n'
      'Discover your cosmic connection at ASTRO.FM!',
    );
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

  void _showRemoveFriendDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundMid,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withAlpha(26)),
        ),
        title: Text(
          'Remove Friend?',
          style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        content: Text(
          'Are you sure you want to remove ${widget.friend.name.split(' ')[0]} from your connections?',
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
              _showComingSoon('Friend management');
            },
            child: Text('Remove', style: GoogleFonts.syne(fontSize: 14, color: AppColors.red)),
          ),
        ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Stack(
          children: [
            // Background glow
            Positioned(
              top: -50,
              left: 0,
              right: 0,
              child: Container(
                height: 400,
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      _getAvatarColor(0).withAlpha(40),
                      _getAvatarColor(1).withAlpha(20),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 16),
                    _buildProfileHeader(),
                    const SizedBox(height: 24),
                    _buildCompatibilityCard(),
                    const SizedBox(height: 16),
                    _buildTodaysAlignment(),
                    const SizedBox(height: 16),
                    _buildTheirHoroscope(),
                    const SizedBox(height: 16),
                    _buildTheirSound(),
                    const SizedBox(height: 16),
                    _buildTheirPlaylists(),
                    const SizedBox(height: 24),
                    _buildCtaButtons(),
                  ],
                ),
              ),
            ),

            // Bottom navigation
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BottomNavBar(
                activeTab: 'friends',
                onTabChanged: (tab) {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  // Navigate via the main shell by using named route
                  if (tab != 'friends') {
                    Navigator.pushReplacementNamed(context, '/$tab');
                  }
                },
              ),
            ),

            // Menu overlay
            if (_showMenu) _buildMenuOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIconButton(Icons.arrow_back_ios_rounded, () {
             if (Navigator.of(context).canPop()) {
               Navigator.of(context).pop();
             }
          }),
          Text(
            'Friend Profile',
            style: GoogleFonts.spaceGrotesk(fontSize: 14, color: Colors.white.withAlpha(128)),
          ),
          _buildIconButton(Icons.more_vert_rounded, () => setState(() => _showMenu = true)),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return Material(
      color: Colors.white.withAlpha(13),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Column(
      children: [
        // Profile Orb
        SoundOrb(
          size: 100,
          colors: [_getAvatarColor(0), _getAvatarColor(1), _getAvatarColor(0)],
          animate: true,
          showWaveform: false,
          child: Text(
            widget.friend.name.split(' ').map((n) => n[0]).join(''),
            style: GoogleFonts.syne(fontSize: 36, fontWeight: FontWeight.w800, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),

        // Name & Username
        Text(
          widget.friend.name,
          style: GoogleFonts.syne(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
        ),
        Text(
          widget.friend.username,
          style: GoogleFonts.spaceGrotesk(fontSize: 14, color: Colors.white.withAlpha(128)),
        ),
        const SizedBox(height: 16),

        // Big Three Tags
        Wrap(
          spacing: 10,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            _buildSignTag('☉', widget.friend.sunSign, AppColors.electricYellow),
            _buildSignTag('☽', widget.friend.moonSign, AppColors.hotPink),
            _buildSignTag('↑', widget.friend.risingSign, AppColors.cosmicPurple),
          ],
        ),
      ],
    );
  }

  Widget _buildSignTag(String symbol, String sign, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        border: Border.all(color: color.withAlpha(51)),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(symbol, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(sign, style: GoogleFonts.syne(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
        ],
      ),
    );
  }

  Widget _buildCompatibilityCard() {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Score Display
          Text(
            'COMPATIBILITY',
            style: GoogleFonts.spaceGrotesk(fontSize: 11, color: Colors.white.withAlpha(128), letterSpacing: 2),
          ),
          const SizedBox(height: 8),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.electricYellow, AppColors.hotPink, AppColors.cosmicPurple],
            ).createShader(bounds),
            child: Text(
              '${compatibility['score']}%',
              style: GoogleFonts.syne(fontSize: 56, fontWeight: FontWeight.w800, color: Colors.white),
            ),
          ),
          const SizedBox(height: 20),

          // Breakdown Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.5,
            children: (compatibility['breakdown'] as List).map((item) => _buildBreakdownChip(item)).toList(),
          ),
          const SizedBox(height: 20),

          // AI Insight Section
          _buildInsightSection(),
        ],
      ),
    );
  }

  /// Build the AI-powered insight section with loading/error states
  Widget _buildInsightSection() {
    if (_isLoadingCompatibility) {
      // Shimmer loading state
      return _buildShimmerInsight();
    }

    if (_compatibilityError != null) {
      // Error state with retry
      return _buildErrorInsight();
    }

    // Success state - show AI insight
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(8),
            borderRadius: BorderRadius.circular(12),
            border: const Border(left: BorderSide(color: AppColors.cosmicPurple, width: 3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // AI badge
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                          'AI INSIGHT',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _insightText,
                style: GoogleFonts.spaceGrotesk(fontSize: 13, color: Colors.white.withAlpha(179), height: 1.6),
              ),
            ],
          ),
        ),
        
        // Strengths & Challenges (if AI data available)
        if (_aiCompatibility != null) ...[
          const SizedBox(height: 16),
          _buildStrengthsChallenges(),
          const SizedBox(height: 12),
          _buildSharedGenres(),
        ],
      ],
    );
  }

  /// Shimmer loading placeholder for insight
  Widget _buildShimmerInsight() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: AppColors.cosmicPurple, width: 3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Shimmer lines
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
      onEnd: () => setState(() {}), // Restart animation
    );
  }

  /// Error state with retry button
  Widget _buildErrorInsight() {
    return GestureDetector(
      onTap: _loadCompatibilityData,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.red.withAlpha(20),
          borderRadius: BorderRadius.circular(12),
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

  /// Build strengths and challenges pills
  Widget _buildStrengthsChallenges() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Strengths
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'STRENGTHS',
                style: GoogleFonts.spaceGrotesk(fontSize: 9, color: Colors.white.withAlpha(102), letterSpacing: 1),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _strengths.map((s) => _buildPill(s, AppColors.teal)).toList(),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Challenges
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CHALLENGES',
                style: GoogleFonts.spaceGrotesk(fontSize: 9, color: Colors.white.withAlpha(102), letterSpacing: 1),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _challenges.map((c) => _buildPill(c, AppColors.electricYellow)).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build shared genres section
  Widget _buildSharedGenres() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SHARED MUSIC VIBES',
          style: GoogleFonts.spaceGrotesk(fontSize: 9, color: Colors.white.withAlpha(102), letterSpacing: 1),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: _sharedGenres.map((g) => _buildPill(g, AppColors.hotPink)).toList(),
        ),
      ],
    );
  }

  Widget _buildPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        border: Border.all(color: color.withAlpha(51)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: GoogleFonts.spaceGrotesk(fontSize: 11, color: color),
      ),
    );
  }

  Widget _buildBreakdownChip(Map<String, dynamic> item) {
    final color = item['color'] as Color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        border: Border.all(color: color.withAlpha(77)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(item['symbol'] as String, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item['label'] as String, style: GoogleFonts.spaceGrotesk(fontSize: 11, color: Colors.white.withAlpha(128))),
                Text('${item['value']}%', style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w700, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodaysAlignment() {
    final firstName = widget.friend.name.split(' ')[0];
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'TODAY\'S ALIGNMENT',
            style: GoogleFonts.spaceGrotesk(fontSize: 11, color: Colors.white.withAlpha(128), letterSpacing: 2),
          ),
          const SizedBox(height: 16),

          // Dual Orbs
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildMiniOrb('You', todaysAlignment['yourMood']!, [AppColors.hotPink, AppColors.cosmicPurple]),
              const SizedBox(width: 16),
              _buildConnectionLine(),
              const SizedBox(width: 16),
              _buildMiniOrb(firstName, todaysAlignment['theirMood']!, [_getAvatarColor(0), _getAvatarColor(1)]),
            ],
          ),
          const SizedBox(height: 16),

          // Shared Energy
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cosmicPurple.withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text('SHARED ENERGY', style: GoogleFonts.spaceGrotesk(fontSize: 10, color: Colors.white.withAlpha(128), letterSpacing: 1)),
                const SizedBox(height: 4),
                Text(todaysAlignment['sharedEnergy']!, style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.cosmicPurple)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Text(
            todaysAlignment['description']!,
            textAlign: TextAlign.center,
            style: GoogleFonts.spaceGrotesk(fontSize: 12, color: Colors.white.withAlpha(153), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniOrb(String label, String mood, List<Color> colors) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(colors: colors),
            boxShadow: [BoxShadow(color: colors[0].withAlpha(77), blurRadius: 15)],
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.spaceGrotesk(fontSize: 10, color: Colors.white.withAlpha(128))),
        Text(mood, style: GoogleFonts.syne(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
      ],
    );
  }

  Widget _buildConnectionLine() {
    return SizedBox(
      width: 40,
      height: 2,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.hotPink, AppColors.electricYellow]),
            ),
          ),
          Positioned(
            left: 16,
            top: -3,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.electricYellow,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: AppColors.electricYellow.withAlpha(179), blurRadius: 10)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTheirHoroscope() {
    final firstName = widget.friend.name.split(' ')[0];
    return GlassCard(
      padding: const EdgeInsets.all(20),
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
                    '$firstName\'s Horoscope'.toUpperCase(),
                    style: GoogleFonts.spaceGrotesk(fontSize: 11, color: Colors.white.withAlpha(128), letterSpacing: 2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    friendHoroscope['sign']!,
                    style: GoogleFonts.syne(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.hotPink),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.hotPink.withAlpha(38),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(friendHoroscope['mood']!, style: GoogleFonts.syne(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.hotPink)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(8),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ENERGY', style: GoogleFonts.spaceGrotesk(fontSize: 10, color: Colors.white.withAlpha(102), letterSpacing: 1)),
                const SizedBox(height: 2),
                Text(friendHoroscope['energy']!, style: GoogleFonts.syne(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.electricYellow)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          Text(
            friendHoroscope['reading']!,
            style: GoogleFonts.spaceGrotesk(fontSize: 13, color: Colors.white.withAlpha(179), height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildTheirSound() {
    final firstName = widget.friend.name.split(' ')[0];
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$firstName\'s Sound'.toUpperCase(),
            style: GoogleFonts.spaceGrotesk(fontSize: 11, color: Colors.white.withAlpha(128), letterSpacing: 2),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              // Sound Orb
              GestureDetector(
                onTap: () => setState(() => _isPlayingSound = !_isPlayingSound),
                child: SoundOrb(
                  size: 80,
                  colors: [_getAvatarColor(0), _getAvatarColor(1), _getAvatarColor(0)],
                  animate: _isPlayingSound,
                  showWaveform: _isPlayingSound,
                ),
              ),
              const SizedBox(width: 20),

              // Sound Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildSoundTag(widget.friend.dominantFrequency, AppColors.electricYellow),
                        _buildSoundTag(widget.friend.element, AppColors.cosmicPurple),
                        _buildSoundTag(widget.friend.modality, AppColors.hotPink),
                      ],
                    ),
                    const SizedBox(height: 12),

                    ElevatedButton.icon(
                      onPressed: () => setState(() => _isPlayingSound = !_isPlayingSound),
                      icon: Icon(_isPlayingSound ? Icons.pause_rounded : Icons.play_arrow_rounded, size: 18),
                      label: Text(_isPlayingSound ? 'Pause Sound' : 'Listen to $firstName\'s Sound'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isPlayingSound ? Colors.white.withAlpha(26) : null,
                        foregroundColor: _isPlayingSound ? Colors.white : Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        textStyle: GoogleFonts.syne(fontSize: 12, fontWeight: FontWeight.w600),
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

  Widget _buildSoundTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        border: Border.all(color: color.withAlpha(51)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text, style: GoogleFonts.syne(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
    );
  }

  Widget _buildTheirPlaylists() {
    final firstName = widget.friend.name.split(' ')[0];
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$firstName\'s Playlists'.toUpperCase(),
              style: GoogleFonts.spaceGrotesk(fontSize: 11, color: Colors.white.withAlpha(128), letterSpacing: 2),
            ),
            GestureDetector(
              onTap: () => _showComingSoon('All playlists'),
              child: Text('See All', style: GoogleFonts.syne(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.cosmicPurple)),
            ),
          ],
        ),
        const SizedBox(height: 12),

        GlassCard(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: friendPlaylists.asMap().entries.map((entry) {
              final index = entry.key;
              final playlist = entry.value;
              return _buildPlaylistItem(playlist, index < friendPlaylists.length - 1);
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaylistItem(Map<String, dynamic> playlist, bool showDivider) {
    return Container(
      decoration: BoxDecoration(
        border: showDivider ? Border(bottom: BorderSide(color: Colors.white.withAlpha(15))) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showComingSoon('Playlist details'),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(colors: [_getAvatarColor(0).withAlpha(153), _getAvatarColor(1).withAlpha(153)]),
                  ),
                  child: const Icon(Icons.music_note_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(playlist['name'] as String, style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white)),
                      Text('${playlist['trackCount']} tracks', style: GoogleFonts.spaceGrotesk(fontSize: 12, color: Colors.white.withAlpha(128))),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.white.withAlpha(77), size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCtaButtons() {
    final firstName = widget.friend.name.split(' ')[0];
    return Column(
      children: [
        _buildPrimaryButton(
          'Align with $firstName',
          Icons.access_time_rounded,
          const LinearGradient(colors: [AppColors.cosmicPurple, AppColors.hotPink]),
          Colors.white,
          _alignWithFriend,
        ),
        const SizedBox(height: 12),
        _buildPrimaryButton(
          'Share Your Day\'s Playlist',
          Icons.music_note_rounded,
          const LinearGradient(colors: [AppColors.electricYellow, Color(0xFFE5EB0D)]),
          AppColors.background,
          _sharePlaylist,
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(String label, IconData icon, Gradient gradient, Color textColor, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: (gradient as LinearGradient).colors[0].withAlpha(77), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: textColor, size: 20),
                const SizedBox(width: 10),
                Text(label, style: GoogleFonts.syne(fontSize: 16, fontWeight: FontWeight.w700, color: textColor)),
              ],
            ),
          ),
        ),
      ),
    );
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
                      _buildMenuItem('Remove Friend', false, () {
                        setState(() => _showMenu = false);
                        _showRemoveFriendDialog();
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
}
