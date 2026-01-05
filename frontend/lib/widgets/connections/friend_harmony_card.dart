/// Friend Harmony Card widget - "Listen to Your Friends Blend"
/// 
/// Displays the #1 suggested friend to align with today based on lunar harmony.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/design_tokens.dart';
import '../../models/friend_data.dart';
import '../../models/friend_harmony.dart';
import '../../widgets/glass_card.dart';

class FriendHarmonyCard extends StatefulWidget {
  final FriendHarmonySuggestion suggestion;
  final FriendData? friend;
  final String currentMoonSign;
  final VoidCallback onTap;
  final VoidCallback onAlignTap;
  final bool isLoading;

  const FriendHarmonyCard({
    super.key,
    required this.suggestion,
    required this.friend,
    required this.currentMoonSign,
    required this.onTap,
    required this.onAlignTap,
    this.isLoading = false,
  });

  @override
  State<FriendHarmonyCard> createState() => _FriendHarmonyCardState();
}

class _FriendHarmonyCardState extends State<FriendHarmonyCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _glowAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  Color _parseHexColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _buildSkeleton();
    }

    if (widget.friend == null) {
      return const SizedBox.shrink();
    }

    final glowColor = _parseHexColor(widget.suggestion.glowColor);
    final friend = widget.friend!;

    return GestureDetector(
      onTap: widget.onTap,
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        borderColor: glowColor.withAlpha(77),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Moon badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.cosmicPurple.withAlpha(51),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cosmicPurple.withAlpha(77)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🌙', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Text(
                        widget.currentMoonSign,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.cosmicPurple,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  '${widget.suggestion.score}% aligned',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: glowColor,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Title
            Text(
              'Listen to Your Friends Blend',
              style: GoogleFonts.syne(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Featured Friend Row
            Row(
              children: [
                // Avatar with glow
                AnimatedBuilder(
                  animation: _glowAnimation,
                  builder: (context, child) {
                    return Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: glowColor.withAlpha((100 * _glowAnimation.value).toInt()),
                            blurRadius: 16 * _glowAnimation.value,
                            spreadRadius: 4 * _glowAnimation.value,
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: friend.avatarColors.map((c) => Color(c)).toList(),
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          border: Border.all(color: Colors.white.withAlpha(51), width: 2),
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
                    );
                  },
                ),
                
                const SizedBox(width: 12),
                
                // Friend name and context
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        friend.name.split(' ').first,
                        style: GoogleFonts.syne(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.suggestion.contextString,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 12,
                          color: Colors.white.withAlpha(179),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 14),
            
            // Align Now button
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: widget.onAlignTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [glowColor, glowColor.withAlpha(179)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Align Now',
                      style: GoogleFonts.syne(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skeleton header
          Row(
            children: [
              Container(
                width: 80,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const Spacer(),
              Container(
                width: 60,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(26),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Skeleton title
          Container(
            width: 180,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(26),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          
          // Skeleton avatar row
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(26),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 80,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(26),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(26),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          
          // Skeleton button
          Container(
            width: double.infinity,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}
