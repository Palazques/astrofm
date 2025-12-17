import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/design_tokens.dart';
import '../widgets/glass_card.dart';
import '../widgets/sound_orb.dart';
import '../models/friend_data.dart';

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

  // Mock compatibility data (in future, fetch from backend)
  Map<String, dynamic> get compatibility => {
    'score': widget.friend.compatibilityScore,
    'breakdown': [
      {'symbol': '☽', 'label': 'Moon Harmony', 'value': 92, 'color': AppColors.hotPink},
      {'symbol': '☿', 'label': 'Communication', 'value': 78, 'color': AppColors.electricYellow},
      {'symbol': '♀', 'label': 'Love Language', 'value': 91, 'color': AppColors.cosmicPurple},
      {'symbol': '♂', 'label': 'Energy Sync', 'value': 84, 'color': AppColors.teal},
    ],
    'insight': 'Your water signs create deep emotional understanding. ${widget.friend.name.split(' ')[0]}\'s ${widget.friend.sunSign} sun flows naturally with your energy, fostering intuitive connection.',
  };

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
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
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

          // AI Insight
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(8),
              borderRadius: BorderRadius.circular(12),
              border: Border(left: BorderSide(color: AppColors.cosmicPurple, width: 3)),
            ),
            child: Text(
              compatibility['insight'] as String,
              style: GoogleFonts.spaceGrotesk(fontSize: 13, color: Colors.white.withAlpha(179), height: 1.6),
            ),
          ),
        ],
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
            Text('See All', style: GoogleFonts.syne(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.cosmicPurple)),
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
          onTap: () {},
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
          () {},
        ),
        const SizedBox(height: 12),
        _buildPrimaryButton(
          'Share Your Day\'s Playlist',
          Icons.music_note_rounded,
          const LinearGradient(colors: [AppColors.electricYellow, Color(0xFFE5EB0D)]),
          AppColors.background,
          () {},
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
            padding: const EdgeInsets.all(18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: textColor, size: 20),
                const SizedBox(width: 10),
                Text(label, style: GoogleFonts.syne(fontSize: 15, fontWeight: FontWeight.w700, color: textColor)),
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
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 80, 20, 0),
            child: Material(
              color: AppColors.backgroundMid,
              borderRadius: BorderRadius.circular(16),
              child: IntrinsicWidth(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildMenuItem('Remove Friend', false),
                    _buildMenuItem('Block', true),
                    _buildMenuItem('Report', true),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(String label, bool isDestructive) {
    return InkWell(
      onTap: () => setState(() => _showMenu = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.white.withAlpha(15))),
        ),
        child: Text(
          label,
          style: GoogleFonts.syne(fontSize: 14, fontWeight: FontWeight.w500, color: isDestructive ? AppColors.red : Colors.white),
        ),
      ),
    );
  }
}
