import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/design_tokens.dart';
import '../../models/friend_data.dart';
import '../../models/friend_connection.dart';
import '../../services/synastry_service.dart';

/// Detail card shown when a friend is selected in the constellation.
/// Enhanced with synastry data including shared frequency, aspect info, and cosmic genre.
class FriendDetailCard extends StatefulWidget {
  final FriendData friend;
  final List<FriendData> connectedFriends;
  final VoidCallback onProfileTap;
  final VoidCallback onAlignTap;
  final Function(FriendData) onConnectedFriendTap;
  
  /// User's dominant element (defaults to Water for demo).
  final String userElement;

  const FriendDetailCard({
    super.key,
    required this.friend,
    required this.connectedFriends,
    required this.onProfileTap,
    required this.onAlignTap,
    required this.onConnectedFriendTap,
    this.userElement = 'Water',
  });

  @override
  State<FriendDetailCard> createState() => _FriendDetailCardState();
}

class _FriendDetailCardState extends State<FriendDetailCard>
    with SingleTickerProviderStateMixin {
  late FriendConnection _connection;
  final _synastryService = SynastryService();
  late AnimationController _floatController;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _calculateConnection();
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FriendDetailCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.friend.id != widget.friend.id) {
      _calculateConnection();
    }
  }

  void _calculateConnection() {
    final mutuals = widget.connectedFriends.take(3).map((f) => MutualFriend(
      id: f.id.toString(),
      initials: f.initials,
      colorValue: f.primaryColorValue,
    )).toList();

    _connection = _synastryService.calculateConnection(
      userElement: widget.userElement,
      friendElement: widget.friend.element,
      friendSunSign: widget.friend.sunSign,
      mutualPlanets: widget.friend.mutualPlanets,
      mutualFriends: mutuals,
    );
  }

  Color get _friendColor => Color(widget.friend.primaryColorValue);
  
  Color get _secondaryColor => Color(
    widget.friend.avatarColors.length > 1 
        ? widget.friend.avatarColors[1] 
        : widget.friend.primaryColorValue
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0F),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background glow
            Positioned(
              top: -40,
              right: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _friendColor.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with floating avatar
                  _buildHeader(),
                  const SizedBox(height: 12),
                  
                  // Connection insight
                  _buildInsight(),
                  const SizedBox(height: 16),
                  
                  // Shared frequency
                  _buildFrequency(),
                  const SizedBox(height: 16),
                  
                  // Strongest aspect (two-column)
                  _buildStrongestConnection(),
                  const SizedBox(height: 16),
                  
                  // Element match + Shared genre row
                  _buildElementAndGenre(),
                  const SizedBox(height: 16),
                  
                  // Shared songs (no playback)
                  _buildSharedSongs(),
                  
                  // Shared planets
                  if (widget.friend.mutualPlanets != null && widget.friend.mutualPlanets!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSharedPlanets(),
                  ],
                  
                  // Connected friends
                  if (widget.connectedFriends.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildMutuals(),
                  ],
                  
                  const SizedBox(height: 16),
                  // Action buttons
                  _buildActionButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Floating Avatar with glow
        AnimatedBuilder(
          animation: _floatController,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, -5 * _floatController.value),
              child: child,
            );
          },
          child: Stack(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_friendColor, _secondaryColor],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _friendColor.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    widget.friend.initials,
                    style: GoogleFonts.syne(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Online indicator
              if (widget.friend.status == 'online')
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D4AA),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF0A0A0F),
                        width: 3,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(width: 16),

        // Name & Info (no compatibility percentage)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.friend.name,
                style: GoogleFonts.syne(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  Text(
                    widget.friend.sunSign,
                    style: GoogleFonts.syne(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _friendColor,
                    ),
                  ),
                  Text(
                    '•',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '☽',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.friend.lastAligned ?? 'Not aligned yet',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInsight() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: _friendColor, width: 3),
        ),
      ),
      child: Text(
        '"${_connection.insight}"',
        style: GoogleFonts.spaceGrotesk(
          fontSize: 14,
          fontStyle: FontStyle.italic,
          color: Colors.white.withValues(alpha: 0.8),
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildFrequency() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YOUR SHARED FREQUENCY',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.4),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [_friendColor, _secondaryColor],
                    ).createShader(bounds),
                    child: Text(
                      '${_connection.sharedFrequency.hz}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Hz',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      color: Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                _connection.sharedFrequency.description,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),

          // Static frequency indicator (no waveform animation)
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_friendColor, _secondaryColor],
              ),
              boxShadow: [
                BoxShadow(
                  color: _friendColor.withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: Icon(
                Icons.waves_rounded,
                color: Colors.white.withValues(alpha: 0.9),
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStrongestConnection() {
    final aspect = _connection.primaryAspect;
    final isHarmonious = aspect.quality == 'harmonious';
    final isTense = aspect.quality == 'tense';
    final qualityColor = isHarmonious
        ? const Color(0xFF00D4AA)
        : isTense
            ? const Color(0xFFE84855)
            : const Color(0xFFFAFF0E);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with aspect badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STRONGEST CONNECTION',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.4),
                  letterSpacing: 1.5,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: qualityColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: qualityColor.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      aspect.aspectSymbol,
                      style: TextStyle(
                        fontSize: 14,
                        color: qualityColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      aspect.aspect,
                      style: GoogleFonts.syne(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: qualityColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Two-column planet connection visual
          Row(
            children: [
              // Your Planet
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.hotPink.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.hotPink.withValues(alpha: 0.3),
                              AppColors.hotPink.withValues(alpha: 0.15),
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.hotPink.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            aspect.yourSymbol,
                            style: const TextStyle(
                              fontSize: 18,
                              color: AppColors.hotPink,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'You',
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 10,
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              aspect.yourPlanet,
                              style: GoogleFonts.syne(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Connection Line
              Container(
                width: 20,
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.hotPink, _friendColor],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),

              // Their Planet
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _friendColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              _friendColor.withValues(alpha: 0.3),
                              _friendColor.withValues(alpha: 0.15),
                            ],
                          ),
                          border: Border.all(
                            color: _friendColor.withValues(alpha: 0.5),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            aspect.theirSymbol,
                            style: TextStyle(
                              fontSize: 18,
                              color: _friendColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.friend.name.split(' ').first,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 10,
                                color: Colors.white.withValues(alpha: 0.4),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              aspect.theirPlanet,
                              style: GoogleFonts.syne(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Aspect Meaning
          Text(
            aspect.meaning,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.6),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElementAndGenre() {
    final elementMatch = _connection.elementMatch;
    final genre = _connection.sharedGenre;

    return Row(
      children: [
        // Element Match
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'ELEMENT',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.4),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${elementMatch.symbol} ${elementMatch.yours} × ${elementMatch.theirs}',
                  style: GoogleFonts.syne(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: elementMatch.compatibilityColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  elementMatch.meaning,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Shared Genre
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'SHARED GENRE',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.4),
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.music_note_rounded,
                      size: 14,
                      color: _friendColor,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        genre.displayText,
                        style: GoogleFonts.syne(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _friendColor,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  genre.description,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSharedSongs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SONGS YOU\'D BOTH LOVE',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.4),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _connection.sharedVibes.map((song) {
            return Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      gradient: LinearGradient(
                        colors: [
                          _friendColor.withValues(alpha: 0.4),
                          _secondaryColor.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.music_note_rounded,
                        color: Colors.white70,
                        size: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        song.title,
                        style: GoogleFonts.syne(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        song.artist,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 10,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSharedPlanets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SHARED PLANETS',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.4),
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _connection.sharedPlanets.map((planet) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: planet.color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: planet.color.withValues(alpha: 0.4),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  planet.symbol,
                  style: TextStyle(fontSize: 12, color: planet.color),
                ),
                const SizedBox(width: 6),
                Text(
                  planet.name,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildMutuals() {
    return Row(
      children: [
        Text(
          'Also aligned with',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.4),
          ),
        ),
        const SizedBox(width: 10),
        ...widget.connectedFriends.take(5).toList().asMap().entries.map((entry) {
          final index = entry.key;
          final friend = entry.value;
          final friendColor = Color(friend.primaryColorValue);
          return Transform.translate(
            offset: Offset(-8.0 * index, 0),
            child: GestureDetector(
              onTap: () => widget.onConnectedFriendTap(friend),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: friendColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF0A0A0F),
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    friend.initials,
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
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Profile Button
        Expanded(
          child: GestureDetector(
            onTap: widget.onProfileTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    color: Colors.white.withValues(alpha: 0.7),
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Profile',
                    style: GoogleFonts.syne(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Align Now Button
        Expanded(
          flex: 2,
          child: GestureDetector(
            onTap: widget.onAlignTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_friendColor, _secondaryColor],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: _friendColor.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Align Now',
                    style: GoogleFonts.syne(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
