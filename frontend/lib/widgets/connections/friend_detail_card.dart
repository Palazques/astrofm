import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/design_tokens.dart';
import '../../models/friend_data.dart';
import '../../models/constellation_connection.dart';
import '../../services/compatibility_service.dart';

/// Detail card shown when a friend is selected in the constellation.
class FriendDetailCard extends StatelessWidget {
  final FriendData friend;
  final List<FriendData> connectedFriends;
  final VoidCallback onProfileTap;
  final VoidCallback onAlignTap;
  final Function(FriendData) onConnectedFriendTap;

  const FriendDetailCard({
    super.key,
    required this.friend,
    required this.connectedFriends,
    required this.onProfileTap,
    required this.onAlignTap,
    required this.onConnectedFriendTap,
  });

  Color get _compatibilityColor => 
      Color(CompatibilityService.getCompatibilityColorValue(friend.compatibilityScore));

  String _getPlanetSymbol(String planet) {
    const symbols = {
      'Sun': '☉', 'Moon': '☽', 'Mercury': '☿', 'Venus': '♀',
      'Mars': '♂', 'Jupiter': '♃', 'Saturn': '♄', 'Uranus': '♅',
      'Neptune': '♆', 'Pluto': '♇',
    };
    return symbols[planet] ?? '★';
  }

  @override
  Widget build(BuildContext context) {
    final friendColor = Color(friend.primaryColorValue);
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        // Accent left border
        boxShadow: [
          BoxShadow(
            color: friendColor.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(-3, 0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              // Avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    center: const Alignment(-0.3, -0.3),
                    colors: [friendColor, friendColor.withValues(alpha: 0.6)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: friendColor.withValues(alpha: 0.5),
                      blurRadius: 25,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    friend.initials,
                    style: GoogleFonts.syne(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              
              // Name and info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            friend.name,
                            style: GoogleFonts.syne(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (friend.status == 'online') ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00D4AA),
                              shape: BoxShape.circle,
                              boxShadow: [BoxShadow(color: const Color(0xFF00D4AA), blurRadius: 6)],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${friend.sunSign} · ${friend.lastAligned ?? "Not aligned yet"}',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Compatibility score
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${friend.compatibilityScore}%',
                    style: GoogleFonts.syne(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: _compatibilityColor,
                      height: 1,
                    ),
                  ),
                  Text(
                    'ALIGNED',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 9,
                      color: Colors.white.withValues(alpha: 0.4),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Shared planets
          if (friend.mutualPlanets != null && friend.mutualPlanets!.isNotEmpty) ...[
            Text(
              'SHARED PLANETS',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.4),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: friend.mutualPlanets!.map((planet) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getPlanetSymbol(planet),
                      style: TextStyle(fontSize: 14, color: friendColor),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      planet,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
            const SizedBox(height: 16),
          ],
          
          // Compatible with (connected friends)
          if (connectedFriends.isNotEmpty) ...[
            Text(
              'COMPATIBLE WITH',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 10,
                color: Colors.white.withValues(alpha: 0.4),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: connectedFriends.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final connFriend = connectedFriends[index];
                  final connColor = Color(connFriend.primaryColorValue);
                  
                  return GestureDetector(
                    onTap: () => onConnectedFriendTap(connFriend),
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            center: const Alignment(-0.3, -0.3),
                            colors: [connColor, connColor.withValues(alpha: 0.6)],
                          ),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        ),
                        child: Center(
                          child: Text(
                            connFriend.initials,
                            style: GoogleFonts.syne(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.person_outline_rounded,
                  label: 'Profile',
                  isOutlined: true,
                  onTap: onProfileTap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionButton(
                  icon: Icons.access_time_rounded,
                  label: 'Align Now',
                  color: friendColor,
                  onTap: onAlignTap,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final bool isOutlined;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.color,
    this.isOutlined = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isOutlined ? Colors.white.withValues(alpha: 0.05) : color,
          borderRadius: BorderRadius.circular(14),
          border: isOutlined 
              ? Border.all(color: Colors.white.withValues(alpha: 0.1))
              : null,
          boxShadow: !isOutlined && color != null ? [
            BoxShadow(
              color: color!.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.syne(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
